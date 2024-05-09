part of 'assignment_review_bloc.dart';

abstract class AssignmentReviewEvent extends Equatable {
  const AssignmentReviewEvent();

  @override
  List<Object> get props => [];
}


final class AssignmentReviewInitialEvent extends AssignmentReviewEvent {}



final class FinishGrading extends AssignmentReviewEvent {
  final AssignmentUserModel assignmentUserModel;
  final String review;
  final int grade;
  final List<BadgeModel> badges;

  FinishGrading({required this.assignmentUserModel, required this.review, required this.grade, required this.badges});

  List<Object> get props => [assignmentUserModel, review, grade, badges];


}