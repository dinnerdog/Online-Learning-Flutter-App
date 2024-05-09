import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test1/data/model/assignment_model.dart';
import 'package:test1/data/model/course_model.dart';
import 'package:test1/data/repo/assignment_repository.dart';
import 'package:test1/data/repo/course_repository.dart';

part 'course_progress_event.dart';
part 'course_progress_state.dart';

class CourseProgressBloc
    extends Bloc<CourseProgressEvent, CourseProgressState> {
  CourseProgressBloc() : super(CourseProgressInitial()) {
    

    on<CourseProgressInitialEvent>(courseProgressInitialEvent);
    on<CourseProgressSubscriptionRequest>(courseProgressSubscriptionRequest);
    on<CourseProgressUpdated>(courseProgressUpdated);
    on<CourseProgressStarUpdateEvent>(courseProgressStarUpdateEvent);
    on<CourseProgressResourceStarChangeEvent>(courseProgressResourceStarChangeEvent);
    on<CourseProgressAssignmentStarChangeEvent>(courseProgressAssignmentStarChangeEvent);
  }

  FutureOr<void> courseProgressSubscriptionRequest(
      CourseProgressSubscriptionRequest event,
      Emitter<CourseProgressState> emit) {
    try {
      Rx.combineLatest2(
          CourseRepository().courseStream(event.courseId),
          AssignmentRepository().getAssignmentsForCourse(event.courseId),
          (a, b) => [a, b]).listen(
        (courseAndAssignments) {
          var course = courseAndAssignments[0] as CourseModel;
          var assignments = courseAndAssignments[1] as List<AssignmentModel>;

          add(CourseProgressUpdated(course, assignments));
        },
        onError: (error) {
          print(error);
        },
      );
    } catch (e) {
      print(e);
    }
  }

  FutureOr<void> courseProgressUpdated(
      CourseProgressUpdated event, Emitter<CourseProgressState> emit) {
    emit(CourseProgressSuccessState(event.course, event.assignments));
      }

  FutureOr<void> courseProgressInitialEvent(CourseProgressInitialEvent event, Emitter<CourseProgressState> emit) {
    emit(CourseProgressLoadingState());
    add(CourseProgressSubscriptionRequest(event.courseId));
  }

  FutureOr<void> courseProgressStarUpdateEvent(CourseProgressStarUpdateEvent event, Emitter<CourseProgressState> emit) {

  }

  FutureOr<void> courseProgressResourceStarChangeEvent(CourseProgressResourceStarChangeEvent event, Emitter<CourseProgressState> emit) async {
    try {
      
       await CourseRepository().updateStars(event.courseId, event.name, event.rating);
       add(CourseProgressInitialEvent( event.courseId));
    } catch (e) {
      print(e);
    }

  }

  FutureOr<void> courseProgressAssignmentStarChangeEvent(CourseProgressAssignmentStarChangeEvent event, Emitter<CourseProgressState> emit) async {
    try {
      
       await CourseRepository().updateStars(event.courseId, event.name, event.rating);
       add(CourseProgressInitialEvent( event.courseId));
    } catch (e) {
      print(e);
    }
  }
}
