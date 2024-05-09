import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:test1/data/model/course_model.dart';
import 'package:test1/data/repo/course_repository.dart';
import 'package:test1/global/helper/image_picker_uploader_helper.dart';

part 'course_add_event.dart';
part 'course_add_state.dart';

class CourseAddBloc extends Bloc<CourseAddEvent, CourseAddState> {
  CourseAddBloc() : super(CourseAddInitial()) {
    on<CourseAddInitialEvent>(courseAddInitialEvent);
    on<CourseAddClickSubmitEvent>(courseAddClickSubmitEvent);
  }

  FutureOr<void> courseAddInitialEvent(CourseAddInitialEvent event, Emitter<CourseAddState> emit) {
  }

  FutureOr<void> courseAddClickSubmitEvent(CourseAddClickSubmitEvent event, Emitter<CourseAddState> emit)async {
    emit(CourseAddClickSubmitLoadingState());
    try {
       final id = await CourseRepository().createCourse(course: event.course);
       if (id != null) {
          await CourseRepository().updateCourseField(id, 'id', id);

         final imageNetUrl = await ImagePickerUploaderHelper.uploadImage(category: 'course_cover', id: id, imageUrl: event.course.imageUrl!);

         //update activity with image url
         await CourseRepository().updateCourseField(id, 'imageUrl', imageNetUrl);
       }
      emit(CourseAddClickSubmitSuccessActionState());
    } catch (e) {
      emit(CourseAddClickSubmitErrorState());
    }
    


  }
}
