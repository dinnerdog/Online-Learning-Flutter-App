part of 'add_assignment_bloc.dart';

sealed class AddAssignmentState extends Equatable {
  const AddAssignmentState();
  
  @override
  List<Object> get props => [];
}

final class AddAssignmentInitial extends AddAssignmentState {}


final class AddAssignmentSubmitLoadingState extends AddAssignmentState {}

final class AddAssignmentSubmitSuccessState extends AddAssignmentState {}

final class AddAssignmentSubmitErrorState extends AddAssignmentState {
}