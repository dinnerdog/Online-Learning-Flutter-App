import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test1/data/model/assignment_model.dart';
import 'package:test1/data/model/course_model.dart';
import 'package:test1/data/model/incentives_model.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:test1/data/repo/assignment_repository.dart';
import 'package:test1/data/repo/assignment_user_repository.dart';
import 'package:test1/data/repo/course_repository.dart';
import 'package:test1/data/repo/course_user_repository.dart';
import 'package:test1/data/repo/incentives_repository.dart';
import 'package:test1/global/common/toast.dart';
import 'package:test1/global/helper/image_picker_uploader_helper.dart';

part 'course_detail_event.dart';
part 'course_detail_state.dart';

class CourseDetailBloc extends Bloc<CourseDetailEvent, CourseDetailState> {
  StreamSubscription<AssignmentModel?>? _AssignmentSubscription;
  StreamSubscription<CourseModel?>? _CourseSubscription;

  Role myRole = Role.teacher;

  CourseDetailBloc() : super(CourseDetailInitial()) {
    on<CourseDetailInitialEvent>(courseDetailInitialEvent);

    on<CourseEditClickEvent>(courseEditClickEvent);

    on<CourseEditQuitClickEvent>(courseEditQuitClickEvent);

    on<CourseEditSaveClickEvent>(courseEditSaveClickEvent);

    on<CourseDeleteClickEvent>(courseDeleteClickEvent);

    on<CourseWithdrawEvent>(courseWithdrawEvent);

    on<CourseDeleteEnrolledUserEvent>(courseDeleteEnrolledUserEvent);

    on<CourseGiveCertificateEvent>(courseGiveCertificateEvent);

    on<CourseRequested>(_onCourseRequested);

    on<CourseUpdated>(_onCourseUpdated);
  }

  FutureOr<void> courseDetailInitialEvent(
      CourseDetailInitialEvent event, Emitter<CourseDetailState> emit) async {
    emit(CourseDetailLoadingState());
    try {
      add(CourseRequested(courseId: event.courseId));
    } catch (e) {
      emit(CourseDetailErrorState());
    }
  }

  FutureOr<void> courseEditClickEvent(
      CourseEditClickEvent event, Emitter<CourseDetailState> emit) async {
    await CourseRepository().getCourse(event.courseId).then((course) {
      if (course != null) {
        emit(CourseDetailEditingState(course));
      } else {
        emit(CourseDetailErrorState());
      }
    });
  }

  FutureOr<void> courseEditQuitClickEvent(
      CourseEditQuitClickEvent event, Emitter<CourseDetailState> emit) async {
    await CourseRepository().getCourse(event.courseId).then((course) {
      if (course != null) {
        add(CourseDetailInitialEvent(courseId: event.courseId));
      } else {
        emit(CourseDetailErrorState());
      }
    });
  }

  FutureOr<void> courseEditSaveClickEvent(
      CourseEditSaveClickEvent event, Emitter<CourseDetailState> emit) async {
    try {
      var url = event.course.imageUrl;

      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = await ImagePickerUploaderHelper.uploadImage(
              category: 'activity_cover',
              id: event.course.id,
              imageUrl: event.course.imageUrl,
            ) ??
            event.course.imageUrl;

        event.course.imageUrl = url;
      }

      emit(CourseDetailEditLoadingState());
      await CourseRepository().updateCourse(event.course.id, event.course);

      emit(CourseDetailEditSuccessState());
      add(CourseDetailInitialEvent(courseId: event.course.id));
    } catch (e) {
      print(e);
      emit(CourseDetailEditErrorState());
    }
  }

  FutureOr<void> courseDeleteClickEvent(
      CourseDeleteClickEvent event, Emitter<CourseDetailState> emit) {
    emit(CourseDetailLoadingState());
    try {
      AssignmentUserRepository().deleteAssignmentByCourseId(event.courseId);
      CourseRepository().deleteCourse(event.courseId);
      emit(CourseDetailErrorState());
    } catch (e) {
      showToast(message: e.toString());
    }
  }

  FutureOr<void> _onCourseUpdated(
      CourseUpdated event, Emitter<CourseDetailState> emit) {
    emit(CourseDetailSuccessState(event.course, event.assignments));
  }

  FutureOr<void> _onCourseRequested(
      CourseRequested event, Emitter<CourseDetailState> emit) {
    _CourseSubscription?.cancel();
    _AssignmentSubscription?.cancel();

    Rx.combineLatest2(
      CourseRepository().courseStream(event.courseId),
      AssignmentRepository().getAssignmentsForCourse(event.courseId),
      (CourseModel? course, List<AssignmentModel> assignments) {
        return CourseUpdated(course!, assignments);
      },
    ).listen((event) {
      add(event);
    });
  }

  FutureOr<void> courseWithdrawEvent(
      CourseWithdrawEvent event, Emitter<CourseDetailState> emit) async {
    try {
      await AssignmentUserRepository()
          .takeAssignmentFromUser(event.courseId, event.userId);
      await CourseUserRepository()
          .removeStudentFromCourse(event.courseId, event.userId);
    } catch (e) {
      showToast(message: e.toString());
    }
  }

  FutureOr<void> courseDeleteEnrolledUserEvent(
      CourseDeleteEnrolledUserEvent event,
      Emitter<CourseDetailState> emit) async {
    try {
      await AssignmentUserRepository()
          .deleteAssignmentsByUserId(event.courseId, event.userId);
      await CourseUserRepository()
          .removeStudentFromCourse(event.courseId, event.userId);
    } catch (e) {
      showToast(message: e.toString());
    }
  }

  FutureOr<void> courseGiveCertificateEvent(
      CourseGiveCertificateEvent event, Emitter<CourseDetailState> emit) {
    try {
      IncentiveRepository()
          .getIncentivesForUserStream(event.userId)
          .listen((incentives) {
        if (incentives.certificates
            .where((element) => element.courseId == event.course.id)
            .isNotEmpty) {
          showToast(message: 'Certificate already given');
          return;
        } else {
          
          IncentiveRepository()
              .addIncentive(IncentiveType.certificate, event.userId, [
            CertificateModel(
              certificateDescription:
                  'Certificate of Completion for ${event.course.name}',
              userId: event.userId,
              courseId: event.course.id,
              certificateName: event.course.name,
              dateEarned: DateTime.now(),
              certificateId: '',
            )
          ]);

          showToast(message: 'Certificate given successfully');
        }
      });
    } catch (e) {
      showToast(message: e.toString());
    }
  }
}
