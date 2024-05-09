import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:test1/data/repo/assignment_repository.dart';
import 'package:test1/data/repo/assignment_user_repository.dart';
import 'package:test1/data/repo/course_repository.dart';
import 'package:test1/global/common/toast.dart';

part 'assignment_completion_event.dart';
part 'assignment_completion_state.dart';

class AssignmentCompletionBloc extends Bloc<AssignmentCompletionEvent, AssignmentCompletionState> {
  AssignmentCompletionBloc() : super(AssignmentCompletionInitial()) {
   on<deleteAssignmentEvent>(_onDeleteAssignment);
  }

  FutureOr<void> _onDeleteAssignment(deleteAssignmentEvent event, Emitter<AssignmentCompletionState> emit) async {

     try {
    
      await AssignmentUserRepository().deleteDistributedAssignment(event.assignmentId, event.courseId);
      await CourseRepository().deleteStars(event.courseId, event.assignmentId);
      await AssignmentRepository().deleteAssignment(event.courseId,event.assignmentId );
    
      emit(DeleteAssignmentSuccessState());
    } catch (e) {
     showToast(message: e.toString());
    }
  }
}
