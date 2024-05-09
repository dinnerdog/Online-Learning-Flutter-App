import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:test1/data/model/activity_model.dart';
import 'package:test1/data/model/activity_user_model.dart';
import 'package:test1/data/repo/activity_repository.dart';
import 'package:test1/data/repo/activity_user_repository.dart';
import 'package:test1/data/repo/user_repository.dart';

part 'activity_event.dart';
part 'activity_state.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  StreamSubscription? _activitiesSubscription;
  StreamSubscription? _myActivitiesSubscription;
  StreamSubscription? _createdActivitiesSubscription;

  ActivityBloc() : super(ActivityInitial()) {
    on<ActivityInitialEvent>(activityInitialEvent);
    on<ActivityAddEvent>(activityAddEvent);
    on<ActivityInterestEvent>(activityInterestEvent);
    on<ActivityUninterestEvent>(activityUnInterestEvent);
    on<SwitchToMyActivityEvent>(switchToMyActivityEvent);
    on<SwitchToCreatedActivityEvent>(switchToCreatedActivityEvent);
    on<ActivityDeleteEvent>(activityDeleteEvent);
    on<ActivityFilterClickEvent>(activityFilterClickEvent);

    on<ActivitiesSubscriptionRequested>(activitiesSubscriptionRequested);
    on<ActivitiesUpdated>(activitiesUpdated);
    on<MyActivitiesSubscriptionRequested>(myActivitiesSubscriptionRequested);
    on<MyActivitiesUpdated>(myActivitiesUpdated);
    on<CreatedActivitiesSubscriptionRequested>(createdActivitiesSubscriptionRequested);
    on<CreatedActivitiesUpdated>(createdActivitiesUpdated);
  }

  FutureOr<void> activityInitialEvent(
      ActivityInitialEvent event, Emitter<ActivityState> emit) async {
    emit(ActivityLoadingState());

    try {
      add(ActivitiesSubscriptionRequested(sortCondition: event.sortCondition , isAscending: event.isAscending));
    } catch (e) {
      emit(ActivityErrorState());
    }
  }

  FutureOr<void> activityAddEvent(
      ActivityAddEvent event, Emitter<ActivityState> emit) async {
    emit(ActivityNavigateToAddActionState());
  }



  FutureOr<void> activityInterestEvent(
      ActivityInterestEvent event, Emitter<ActivityState> emit) async {

    try {
      await ActivityUserRepository()
          .createActivityUser(event.activityUserModel);
    } catch (e) {
      emit(ActivityErrorState());
    }
  }

  FutureOr<void> activityUnInterestEvent(
      ActivityUninterestEvent event, Emitter<ActivityState> emit) {
        final activityUserId = event.userId.compareTo(event.activityId) < 0
        ? "${event.userId}${event.activityId}"
        : "${event.activityId}${event.userId}";

    try {
      ActivityUserRepository()
          .deleteActivityUser(activityUserId);
    } catch (e) {
      emit(ActivityErrorState());
    }
  }

  FutureOr<void> activitiesUpdated(
      ActivitiesUpdated event, Emitter<ActivityState> emit) {
    emit(ActivitySuccessState(event.activities));
  }

  void activitiesSubscriptionRequested(
      ActivitiesSubscriptionRequested event, Emitter<ActivityState> emit) {
    _myActivitiesSubscription?.cancel();
    _createdActivitiesSubscription?.cancel();
    _activitiesSubscription?.cancel();
    _activitiesSubscription = ActivityRepository().activitiesStream(event.sortCondition, event.isAscending).listen(
      (activities) {
        add(ActivitiesUpdated(activities));
      },
      onError: (error) {
        print(error);
      },
    );
  }

  @override
  Future<void> close() {
    _activitiesSubscription?.cancel();
    return super.close();
  }

  FutureOr<void> switchToMyActivityEvent(
      SwitchToMyActivityEvent event, Emitter<ActivityState> emit) {
    add(MyActivitiesSubscriptionRequested(userId: event.userId, sortCondition: event.sortCondition, isAscending: event.isAscending, ));
  }

  FutureOr<void> switchToCreatedActivityEvent(
      SwitchToCreatedActivityEvent event, Emitter<ActivityState> emit) {
    add(CreatedActivitiesSubscriptionRequested(userId: event.userId, sortCondition: event.sortCondition, isAscending: event.isAscending, ));
  }

  FutureOr<void> myActivitiesSubscriptionRequested(MyActivitiesSubscriptionRequested event, Emitter<ActivityState> emit) {
      _myActivitiesSubscription?.cancel();
    _createdActivitiesSubscription?.cancel();
    _activitiesSubscription?.cancel();
    
    _myActivitiesSubscription = ActivityUserRepository()
      .getActivityUsersByUser(event.userId)
      .asyncMap((activityUserModels) async {
        var activities = await Future.wait(activityUserModels.map((activityUserModel) async {
          return await ActivityRepository().getActivity(activityUserModel.activityId);
        }));
        var activitiesList =  activities.whereType<ActivityModel>().toList();

           
      if (event.sortCondition == 'name') {
        activitiesList.sort((a, b) => a.title.compareTo(b.title));
      } else if (event.sortCondition == 'date') {
        activitiesList.sort((a, b) => a.date.compareTo(b.date));
      } else if (event.sortCondition == 'created date') {
        activitiesList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      }

        if (!event.isAscending) {
        activitiesList = activitiesList.reversed.toList();
      }

        return activitiesList;


      }).listen(
        (List<ActivityModel> activities) {
          add(MyActivitiesUpdated(activities));
        },
        onError: (error) {
          print(error);
        },
      );
  }

  FutureOr<void> myActivitiesUpdated(MyActivitiesUpdated event, Emitter<ActivityState> emit) {
    emit(MyActivityState(event.activities));
  }

  FutureOr<void> createdActivitiesSubscriptionRequested(CreatedActivitiesSubscriptionRequested event, Emitter<ActivityState> emit) {
    _myActivitiesSubscription?.cancel();
    _createdActivitiesSubscription?.cancel();
    _activitiesSubscription?.cancel();
   _createdActivitiesSubscription = UserRepository().getCurrentUserStream()
    .asyncMap((userModel) async {

      if (userModel?.createdActivityIds == null) {
        return <ActivityModel>[];
      }

      var activities = await Future.wait(userModel!.createdActivityIds!.map((activityId) async {
        return await ActivityRepository().getActivity(activityId);
      }));

        var  activitiesList = activities.whereType<ActivityModel>().toList();
      
        if (event.sortCondition == 'name') {
        activitiesList.sort((a, b) => a.title.compareTo(b.title));
      } else if (event.sortCondition == 'date') {
        activitiesList.sort((a, b) => a.date.compareTo(b.date));
      } else if (event.sortCondition == 'created date') {
        activitiesList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      }

        if (!event.isAscending) {
        activitiesList = activitiesList.reversed.toList();
      }

        return activitiesList;


    
    }).listen((List<ActivityModel> activities) {
      add(CreatedActivitiesUpdated(activities));
    }, onError: (error) {
      print(error);
    });

  }


  

  FutureOr<void> createdActivitiesUpdated(CreatedActivitiesUpdated event, Emitter<ActivityState> emit) {
    emit(CreatedActivityState(event.activities));
  }

  FutureOr<void> activityDeleteEvent(ActivityDeleteEvent event, Emitter<ActivityState> emit) {
    try {
      ActivityRepository().deleteActivity(event.activityId);
      UserRepository().removeListField('createdActivityIds', event.activityId);
    } catch (e) {
      emit(ActivityErrorState());
    }

  }

  FutureOr<void> activityFilterClickEvent(ActivityFilterClickEvent event, Emitter<ActivityState> emit) {
    emit(ActivityFilterActionState(sortCondition: event.sortCondition, isAscending: event.isAscending));
  }
}
