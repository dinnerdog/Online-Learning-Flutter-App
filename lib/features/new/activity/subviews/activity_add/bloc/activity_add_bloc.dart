import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:test1/data/model/activity_model.dart';
import 'package:test1/data/repo/activity_repository.dart';
import 'package:test1/data/repo/user_repository.dart';
import 'package:test1/global/common/toast.dart';
import 'package:test1/global/helper/image_picker_uploader_helper.dart';

part 'activity_add_event.dart';
part 'activity_add_state.dart';

class ActivityAddBloc extends Bloc<ActivityAddEvent, ActivityAddState> {
  ActivityAddBloc() : super(ActivityAddInitial()) {
    on<ActivityAddInitialEvent>(activityAddInitialEvent);
    on<ActivityAddSubmitEvent>(activityAddSubmitEvent);
  }

  FutureOr<void> activityAddInitialEvent(
      ActivityAddInitialEvent event, Emitter<ActivityAddState> emit) {}

  FutureOr<void> activityAddSubmitEvent(
      ActivityAddSubmitEvent event, Emitter<ActivityAddState> emit) async {
    emit(ActivityAddSubmitLoadingState());
    try {
      final id = await ActivityRepository()
          .createActivity(activity: event.activityModel);
      if (id != null) {
        await ActivityRepository().updateActivityField(id, 'id', id);
        final imageNetUrl = await ImagePickerUploaderHelper.uploadImage(
            category: 'activity_cover',
            id: id,
            imageUrl: event.activityModel.image);

        await ActivityRepository().updateActivityField(id, 'image', imageNetUrl);
        await UserRepository().appendListField(
             'createdActivityIds', id);
      }
      emit(ActivityAddSubmitSuccessState());
    } catch (e) {
      showToast(message: e.toString());
    }
  }
}
