part of 'assignment_review_bloc.dart';

abstract class AssignmentReviewState extends Equatable {

  const AssignmentReviewState();
  @override
  List<Object> get props => [];
}

abstract class AssignmentReviewActionState extends AssignmentReviewState {

  @override
  List<Object> get props => [];
}


class AssignmentReviewInitial extends AssignmentReviewState {
   @override
  List<Object> get props => [];
}

class AssignmentReviewSuccess extends AssignmentReviewState {
 

  AssignmentReviewSuccess();

     @override
  List<Object> get props => [];
}

class AssignmentReviewLoading extends AssignmentReviewState {
   @override
  List<Object> get props => [];
}




class SubmittedReview extends AssignmentReviewState {
     @override
  List<Object> get props => [];
}

class AssignmentReviewError extends AssignmentReviewState {



       @override
  List<Object> get props => [];
}
