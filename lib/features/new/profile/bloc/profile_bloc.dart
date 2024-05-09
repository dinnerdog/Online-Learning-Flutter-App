import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test1/data/model/course_user_model.dart';
import 'package:test1/data/model/incentives_model.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:test1/data/repo/course_repository.dart';
import 'package:test1/data/repo/course_user_repository.dart';
import 'package:test1/data/repo/incentives_repository.dart';
import 'package:test1/data/repo/user_repository.dart';
import 'package:test1/global/common/toast.dart';
import 'package:test1/global/helper/image_picker_uploader_helper.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  StreamSubscription? _userSubscription;
 

  late UserModel _userModel;
  late int _earnStars;
  late IncentiveModel _incentiveModel;
  late List<CourseUserModel> _courseUsers;
  


  ProfileBloc() : super(ProfileInitial()) {
    on<ProfileInitialEvent>(profileInitialEvent);

    on<UserSubscriptionRequested>(userSubscriptionRequested);
    on<ItemsSubscriptionRequested>(itemsSubscriptionRequested);
    
 

    on<UserUpdated>(_onUserUpdated);
    on<ItemsUpdated>(_onItemsUpdated);
    // on<IncentivesUpdated>(_onIncentivesUpdated);

  }

  void userSubscriptionRequested(
      UserSubscriptionRequested event, Emitter<ProfileState> emit) {
    _userSubscription?.cancel();
    _userSubscription = UserRepository().getCurrentUserStream().listen(
      (user) {
        add(UserUpdated(user!));
      },
      onError: (error) {
        print(error);
      },
    );
  }

  FutureOr<void> _onUserUpdated(UserUpdated event, Emitter<ProfileState> emit) {
    

    _userModel = event.user;

    add(ItemsSubscriptionRequested(user: event.user));

   
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }

  FutureOr<void> itemsSubscriptionRequested(
      ItemsSubscriptionRequested event, Emitter<ProfileState> emit) {

      Rx.combineLatest2( CourseUserRepository().getCourseUserByUserId(event.user.id)
    , IncentiveRepository().getIncentivesForUserStream(event.user.id),
     (a, b) => [a,b]).listen((data) {

       _courseUsers = data[0] as List<CourseUserModel>;
      final incentiveModel = data[1] as IncentiveModel;

      add(ItemsUpdated(courseUsers: _courseUsers, incentiveModel: incentiveModel));


     });


      
      
  }

  FutureOr<void> _onItemsUpdated(
      ItemsUpdated event, Emitter<ProfileState> emit) {
   

     _earnStars =  event.courseUsers.isEmpty ? 0 :  event.courseUsers
        .map((e) => e.earnedStars
            .map((e) => e.rating)
            .reduce((value, element) => value + element))
        .reduce((value, element) => value + element);


    _incentiveModel = event.incentiveModel;



    _emitSuccessState(emit);
  }

  FutureOr<void> profileInitialEvent(
      ProfileInitialEvent event, Emitter<ProfileState> emit) {
    add(UserSubscriptionRequested());
  }



void _emitSuccessState(Emitter<ProfileState> emit){


  emit(ProfileSuccessState(_userModel, _earnStars, _incentiveModel, _courseUsers));



}

  

  

}
