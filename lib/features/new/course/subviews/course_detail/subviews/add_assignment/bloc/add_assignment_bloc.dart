import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:test1/data/model/assignment_model.dart';
import 'package:test1/data/model/course_model.dart';
import 'package:test1/data/repo/assignment_repository.dart';
import 'package:test1/data/repo/assignment_user_repository.dart';
import 'package:test1/data/repo/course_repository.dart';
import 'package:test1/data/repo/course_user_repository.dart';
import 'package:test1/global/helper/image_picker_uploader_helper.dart';

part 'add_assignment_event.dart';
part 'add_assignment_state.dart';

class AddAssignmentBloc extends Bloc<AddAssignmentEvent, AddAssignmentState> {
  AddAssignmentBloc() : super(AddAssignmentInitial()) {
    on<AddAssignmentSubmitEvent>(_onSubmit);
    on<UpdateAssignmentSubmitEvent>(_onUpdate);
  }

  FutureOr<void> _onSubmit(
      AddAssignmentSubmitEvent event, Emitter<AddAssignmentState> emit) async {
    emit(AddAssignmentSubmitLoadingState());
    try {

      


      final id = await AssignmentRepository()
          .addAssignment(event.courseId, event.assignment);


      AssignmentUserRepository().distributeAssignment(id, event.courseId);

      final image = await ImagePickerUploaderHelper.uploadImage(
          category: 'assignment_cover',
          id: id,
          imageUrl: event.assignment.imageUrl!);
      await AssignmentRepository()
          .updateAssignmentField(event.courseId, id, 'id', id);
      await AssignmentRepository()
          .updateAssignmentField(event.courseId, id, 'imageUrl', image!);

      

      await CourseRepository().configureStars(event.courseId, StarRating(
        name: id,
        rating: 5,
      ));

      await CourseUserRepository().distributeStars(event.courseId, StarRating(
        name: id,
        rating: 0,
      ));




      emit(AddAssignmentSubmitSuccessState());
    } catch (e) {
      emit(AddAssignmentSubmitErrorState());
    }
  }

  FutureOr<void> _onUpdate(UpdateAssignmentSubmitEvent event, Emitter<AddAssignmentState> emit) async {

    emit(AddAssignmentSubmitLoadingState());
    try {
      

      var url = event.assignment.imageUrl!;

                          if (!url.startsWith('http://') &&
                              !url.startsWith('https://')) {
                            url = await ImagePickerUploaderHelper.uploadImage(
                                  category: 'assignment_cover',
                                  id: event.assignment.id,
                                  imageUrl: event.assignment.imageUrl!,
                                ) ??
                                event.assignment.imageUrl!;

                         
                          }

                          await AssignmentRepository().updateAssignment(event.courseId,
                             event.assignment.id, 
                           { 
                              'id': event.assignment.id,
                             ' courseId': event.courseId,
                              'name': event.assignment.name,
                              'description': event.assignment.description,
                              'imageUrl': url,
                              'deadLine': event.assignment.deadLine,
                              'assignedDate': event.assignment.assignedDate,
                              'submissionInstructions':
                                  event.assignment.submissionInstructions,
                                });


      emit(AddAssignmentSubmitSuccessState());
    } catch (e) {
      emit(AddAssignmentSubmitErrorState());
    }
  }
}
