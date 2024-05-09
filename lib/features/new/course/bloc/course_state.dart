part of 'course_bloc.dart';

abstract class CourseState extends Equatable {
  const CourseState();
  
  @override
  List<Object> get props => [];
}
abstract class CourseActionState extends CourseState {}


class CourseInitial extends CourseState {}


class CourseLoadingState extends CourseState {}

class CourseErrorState extends CourseState {
}

class CourseSuccessState extends CourseState {
  final List<CourseModel> allCourses;
  final List<CourseModel> myCourses;
  
  
  CourseSuccessState(this.myCourses, this.allCourses);
  List<Object> get props => [allCourses, myCourses];

}



class CourseClickAddActionState extends CourseActionState {}

class CourseEnrollActionState extends CourseActionState {}

class CourseAssignmentLoadingState extends CourseState {
}

class CourseResourceState extends CourseState {

}
