import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:test1/data/model/assignment_user_model.dart';
import 'package:test1/data/model/course_model.dart';
import 'package:test1/data/model/incentives_model.dart';
import 'package:test1/data/repo/assignment_user_repository.dart';
import 'package:test1/data/repo/course_user_repository.dart';
import 'package:test1/data/repo/incentives_repository.dart';

part 'assignment_review_event.dart';
part 'assignment_review_state.dart';

class AssignmentReviewBloc
    extends Bloc<AssignmentReviewEvent, AssignmentReviewState> {



  AssignmentReviewBloc() : super(AssignmentReviewSuccess()) {
    on<FinishGrading>(finishGrading);
    on<AssignmentReviewInitialEvent>(assignmentReviewInitialEvent);
  }



  FutureOr<void> finishGrading(
      FinishGrading event, Emitter<AssignmentReviewState> emit) async {
    emit(AssignmentReviewLoading());
    try {
      final Map<String, dynamic> fieldsToUpdate = {
        'review': event.review,
        'score': event.grade,
      };

      await AssignmentUserRepository()
          .updateSubmissionField(event.assignmentUserModel.id!, fieldsToUpdate)
          .then((value) => IncentiveRepository().addIncentive(
              IncentiveType.badge,
              event.assignmentUserModel.userId,
              event.badges));

      await CourseUserRepository().updateStar(event.assignmentUserModel.courseId, event.assignmentUserModel.userId, 
      StarRating(name: event.assignmentUserModel.assignmentId, rating: event.grade));


      emit(SubmittedReview(
       ));
    } catch (e) {
      emit(AssignmentReviewError());
    }
  }

  FutureOr<void> assignmentReviewInitialEvent(AssignmentReviewInitialEvent event, Emitter<AssignmentReviewState> emit) {
    emit(AssignmentReviewSuccess());


  }
}
