part of 'assignment_completion_bloc.dart';

abstract class AssignmentCompletionEvent extends Equatable {
  const AssignmentCompletionEvent();

  @override
  List<Object> get props => [];
}


class deleteAssignmentEvent extends AssignmentCompletionEvent {
  final String assignmentId;
  final String courseId;
deleteAssignmentEvent({required this.assignmentId, required this.courseId});
}
