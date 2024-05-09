part of 'course_detail_bloc.dart';

abstract class CourseDetailState extends Equatable {
   CourseDetailState();

  @override
  List<Object> get props => [];
}

abstract class CourseDetailActionState extends CourseDetailState {

}

abstract class SuccessState extends CourseDetailState {
}


final class CourseDetailInitial extends CourseDetailState {}

final class CourseDetailLoadingState extends CourseDetailState {}

final class CourseDetailSuccessState extends SuccessState {
   final List<AssignmentModel> assignments;
  final CourseModel course;
  CourseDetailSuccessState(this.course, this.assignments);
  List<Object> get props => [course, assignments];
  
}

final class CourseDetailEditingState extends CourseDetailState {
final CourseModel course;
  CourseDetailEditingState(this.course);
  List<Object> get props => [course];
}

final class CourseDetailErrorState extends CourseDetailState {
}

final class CourseDetailEditLoadingState  extends CourseDetailState {
}


final class CourseDetailEditSuccessState extends CourseDetailActionState {
  
}

final class CourseDetailEditErrorState extends CourseDetailActionState {
}