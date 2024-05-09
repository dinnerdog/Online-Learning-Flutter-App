part of 'course_progress_bloc.dart';

abstract class CourseProgressEvent extends Equatable {
  const CourseProgressEvent();

  @override
  List<Object> get props => [];
}

class CourseProgressInitialEvent extends CourseProgressEvent {
  final String courseId;

  CourseProgressInitialEvent(this.courseId);

  @override
  List<Object> get props => [courseId];
}


class CourseProgressSubscriptionRequest extends CourseProgressEvent {
  final String courseId;


  CourseProgressSubscriptionRequest(this.courseId);

  @override
  List<Object> get props => [courseId];
}


class CourseProgressUpdated extends CourseProgressEvent {
  final CourseModel course;
  final List<AssignmentModel> assignments;


  CourseProgressUpdated(this.course, this.assignments);

  @override
  List<Object> get props => [course,assignments];
}

class CourseProgressStarUpdateEvent extends CourseProgressEvent {
  final String courseId;
  final int rating;
  final String name;

  CourseProgressStarUpdateEvent({required this.courseId, required this.rating, required this.name});

  @override
  List<Object> get props => [courseId, rating, name];
}


class CourseProgressResourceStarChangeEvent extends CourseProgressEvent {
  final String courseId;
  
  final int rating;
  final String name;

  CourseProgressResourceStarChangeEvent({required this.courseId,  required this.rating, required this.name});

  @override
  List<Object> get props => [courseId, rating, name];
}

class CourseProgressAssignmentStarChangeEvent extends CourseProgressEvent {
  final String courseId;
  
  final int rating;
  final String name;

  CourseProgressAssignmentStarChangeEvent({required this.courseId,  required this.rating, required this.name});

  @override
  List<Object> get props => [courseId, rating, name];
}


