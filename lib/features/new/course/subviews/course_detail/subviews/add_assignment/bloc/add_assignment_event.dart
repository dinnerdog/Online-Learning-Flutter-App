part of 'add_assignment_bloc.dart';

abstract class AddAssignmentEvent extends Equatable {
  const AddAssignmentEvent();

  @override
  List<Object> get props => [];
}

class AddAssignmentSubmitEvent extends AddAssignmentEvent {
  final String courseId;
  final AssignmentModel assignment;
  

  AddAssignmentSubmitEvent({
    required this.courseId,
    required this.assignment
  });

  @override
  List<Object> get props => [courseId, assignment];
}

class UpdateAssignmentSubmitEvent extends AddAssignmentEvent {
  final String courseId;
  final AssignmentModel assignment;
  

  UpdateAssignmentSubmitEvent({
    required this.courseId,
    required this.assignment
  });

  @override
  List<Object> get props => [courseId, assignment];
}