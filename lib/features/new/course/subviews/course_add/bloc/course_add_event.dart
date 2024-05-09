part of 'course_add_bloc.dart';

abstract class CourseAddEvent extends Equatable {
  const CourseAddEvent();

  @override
  List<Object> get props => [];
}

abstract class CourseAddActionEvent extends CourseAddEvent {

}

class CourseAddInitialEvent extends CourseAddEvent {
  
}

class CourseAddClickSubmitEvent extends CourseAddEvent {
  final CourseModel course;
  CourseAddClickSubmitEvent(this.course);
}
