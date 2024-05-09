part of 'course_detail_bloc.dart';

abstract class CourseDetailEvent extends Equatable {

 
  @override
  List<Object> get props => [];
}


class CourseDetailInitialEvent extends CourseDetailEvent {
  final String courseId;

  CourseDetailInitialEvent({required this.courseId});
}

class CourseEditClickEvent extends CourseDetailEvent {
  final String courseId;
  CourseEditClickEvent(this.courseId);
}

class CourseEditQuitClickEvent extends CourseDetailEvent {
    final String courseId;

  CourseEditQuitClickEvent({required this.courseId});
}

class CourseEditSaveClickEvent extends CourseDetailEvent {
  final CourseModel course;

  CourseEditSaveClickEvent({required this.course});
}
class CourseDeleteClickEvent extends CourseDetailEvent {
  final String courseId;

  CourseDeleteClickEvent({required this.courseId});
}


class CourseWithdrawEvent extends CourseDetailEvent {
  final String courseId;
  final String userId;

  CourseWithdrawEvent({required this.courseId, required this.userId});
}

class CourseDeleteEnrolledUserEvent extends CourseDetailEvent {
  final String courseId;
  final String userId;

  CourseDeleteEnrolledUserEvent({required this.courseId, required this.userId});
}


class CourseGiveCertificateEvent extends CourseDetailEvent {
  final CourseModel course;
  final String userId;

  CourseGiveCertificateEvent({required this.course, required this.userId});
}



class CourseRequested extends CourseDetailEvent {
  final String courseId;
  CourseRequested({required this.courseId});
}

class CourseUpdated extends CourseDetailEvent {
  final CourseModel course;
  final List<AssignmentModel> assignments;

  CourseUpdated(this.course, this.assignments);
}
