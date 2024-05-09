import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:test1/data/model/activity_model.dart';
import 'package:test1/data/repo/activity_repository.dart';
import 'package:test1/global/common/toast.dart';
import 'package:test1/global/helper/image_picker_uploader_helper.dart';

part 'activity_detail_event.dart';
part 'activity_detail_state.dart';

class ActivityDetailBloc
    extends Bloc<ActivityDetailEvent, ActivityDetailState> {
  StreamSubscription<ActivityModel?>? _activitySubscription;

  ActivityDetailBloc() : super(ActivityDetailInitial()) {
    on<ActivityDetailInitialEvent>(activityDetailInitialEvent);
    on<ActivityDetailEditClickEvent>(activityDetailEditClickEvent);
    on<ActivityDetailEditQuitClickEvent>(activityDetailEditQuitClickEvent);
    on<ActivityDetailEditSaveClickEvent>(activityDetailEditSaveClickEvent);
    on<ActivitysSubscriptionRequested>(_onSubscriptionRequested);
    on<ActivityUpdated>(_onActivityUpdated);
    on<ActivityDetailEditDeleteEvent>(activityDetailEditDeleteClickEvent);
    on<ActivityDetailEditDeleteCancelEvent>(
        activityDetailEditDeleteCancelEvent);
    on<ActivityDetailEditDeleteConfirmEvent>(
        activityDetailEditDeleteConfirmEvent);
  }

  void _onSubscriptionRequested(
      ActivitysSubscriptionRequested event, Emitter<ActivityDetailState> emit) {
    _activitySubscription?.cancel();
    _activitySubscription =
        ActivityRepository().activityStream(event.activityId).listen(
      (activity) {
  
        if (activity != null) {
          add(ActivityUpdated(activity));
        }
      },
      onError: (error) {
        print(error);
      },
    );
  }

  FutureOr<void> _onActivityUpdated(
      ActivityUpdated event, Emitter<ActivityDetailState> emit) {
    emit(ActivityDetailLoadSuccessState(activity: event.activity));
  }

  @override
  Future<void> close() {
    _activitySubscription?.cancel(); 
    return super.close();
  }

  FutureOr<void> activityDetailInitialEvent(ActivityDetailInitialEvent event,
      Emitter<ActivityDetailState> emit) async {
    final activity = await ActivityRepository().getActivity(event.activity.id);
    emit(ActivityDetailLoadInProgressState());
    try {
      emit(ActivityDetailLoadSuccessState(activity: activity!));
    } catch (e) {
      emit(ActivityDetailLoadErrorState());
      showToast(message: e.toString());
    }
  }

  FutureOr<void> activityDetailEditClickEvent(
      ActivityDetailEditClickEvent event, Emitter<ActivityDetailState> emit) {

    emit(ActivityDetailEditClickActionState());
    showToast(message: "Editing Mode");
    emit(ActivityDetailEditState( activity: event.activity));
  }

  FutureOr<void> activityDetailEditQuitClickEvent(
      ActivityDetailEditQuitClickEvent event,
      Emitter<ActivityDetailState> emit) {
    emit(ActivityDetailEditQuitActionState());
  }

  FutureOr<void> activityDetailEditSaveClickEvent(
      ActivityDetailEditSaveClickEvent event,
      Emitter<ActivityDetailState> emit) async {
    emit(ActivityDetailEditState( activity: event.activityModel));

    try {
      var url = event.activityModel.image;

      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = await ImagePickerUploaderHelper.uploadImage(
              category: 'activity_cover',
              id: event.activityModel.id,
              imageUrl: event.activityModel.image,
            ) ??
            event.activityModel.image;

        event.activityModel.image = url;
      }
      
      await ActivityRepository()
          .updateActivity(event.activityModel.id, event.activityModel);

          
      emit(ActivityDetailEditSaveSuccessState());
      add(ActivityUpdated(event.activityModel));

    } catch (e) {
      emit(ActivityDetailEditSaveErrorState());

      showToast(message: e.toString());
    }
  }

  FutureOr<void> activityDetailEditDeleteClickEvent(
      ActivityDetailEditDeleteEvent event,
      Emitter<ActivityDetailState> emit) async {
    emit(ActivityDetailEditClickDeleteState());
    
  }

  FutureOr<void> activityDetailEditDeleteCancelEvent(
      ActivityDetailEditDeleteCancelEvent event,
      Emitter<ActivityDetailState> emit) {
    emit(ActivityDetailEditState( activity: event.activity));
  }

  FutureOr<void> activityDetailEditDeleteConfirmEvent(
      ActivityDetailEditDeleteConfirmEvent event,
      Emitter<ActivityDetailState> emit) {
    emit(ActivityDetailEditDeleteConfirmState());
    try {
      ActivityRepository().deleteActivity(event.activityId);
      emit(ActivityDetailEditDeleteConfirmSuccessState());
    } catch (e) {
      emit(ActivityDetailEditDeleteConfirmSErrorState());
      showToast(message: e.toString());
    }
  }
}
