import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentUserModel {
  String assignmentId;
  String userId;
  String courseId;
  String? id = '';
  bool isSubmitted = false;
  String? submissionUrl;
  String? review;
  int? score;
  DateTime? submittedDate;

  AssignmentUserModel(
      {required this.courseId,
      required this.assignmentId,
      required this.userId,
      required this.isSubmitted,
      this.id,
      this.submissionUrl,
      this.review,
      this.score,
      this.submittedDate});

  factory AssignmentUserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return AssignmentUserModel(
      id: doc.id,
      courseId: data['courseId'],
      assignmentId: data['assignmentId'],
      userId: data['userId'],
      isSubmitted: data['isSubmitted'],
      submissionUrl: data['submissionUrl'],
      review: data['review'],
      score: data['score'],
      submittedDate:  data['submittedDate'] != '' ? (data['submittedDate'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'courseId': courseId,
        'assignmentId': assignmentId,
        'userId': userId,
        'isSubmitted': isSubmitted,
        'submissionUrl': submissionUrl,
        'review': review,
        'score': score,
        'submittedDate': submittedDate,
      };

}
