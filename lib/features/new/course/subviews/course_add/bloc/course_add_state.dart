part of 'course_add_bloc.dart';

abstract class CourseAddState extends Equatable {
  const CourseAddState();
  
  @override
  List<Object> get props => [];
}

abstract class CourseAddActionState extends CourseAddState {}

final class CourseAddInitial extends CourseAddState {}

final class CourseAddClickSubmitLoadingState extends CourseAddState {}

final class CourseAddClickSubmitSuccessActionState extends CourseAddActionState {
}

final class CourseAddClickSubmitErrorState extends CourseAddState {
}
