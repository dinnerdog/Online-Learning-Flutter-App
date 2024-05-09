part of 'course_progress_bloc.dart';

sealed class CourseProgressState extends Equatable {
  const CourseProgressState();
  
  @override
  List<Object> get props => [];
}

final class CourseProgressInitial extends CourseProgressState {}


final class CourseProgressLoadingState extends CourseProgressState {}

final class CourseProgressSuccessState extends CourseProgressState {
  final List<AssignmentModel> assignments;
  final CourseModel course;
  CourseProgressSuccessState(this.course, this.assignments);
  List<Object> get props => [course, assignments];
  
}
