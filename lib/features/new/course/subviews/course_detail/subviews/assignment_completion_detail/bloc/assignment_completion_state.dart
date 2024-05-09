part of 'assignment_completion_bloc.dart';

abstract class AssignmentCompletionState extends Equatable {
  const AssignmentCompletionState();
  
  @override
  List<Object> get props => [];
}

final class AssignmentCompletionInitial extends AssignmentCompletionState {}

final class DeleteAssignmentSuccessState extends AssignmentCompletionState {}
