part of 'course_bloc.dart';

abstract class CourseEvent extends Equatable {
  const CourseEvent();

  @override
  List<Object> get props => [];
}


class CourseInitialEvent extends CourseEvent {
}


class CourseSubscriptionRequested extends CourseEvent {
}

class CourseUpdated extends CourseEvent {
  final List<CourseModel> courses;
  CourseUpdated(this.courses);
}

class MyCourseSubscriptionRequested extends CourseEvent {
  final String userId;
  MyCourseSubscriptionRequested(this.userId);
}

class MyCourseUpdated extends CourseEvent {

    final List<CourseModel> myCourses;
  MyCourseUpdated(this.myCourses);
}

class CourseClickAddEvent extends CourseEvent {

}

class QueryChangedEvent extends CourseEvent {
  final String query;
  QueryChangedEvent(this.query);
}


class CourseEnrollEvent extends CourseEvent {
  final String courseId;
  final String userId;
  CourseEnrollEvent(this.courseId, this.userId);
}



