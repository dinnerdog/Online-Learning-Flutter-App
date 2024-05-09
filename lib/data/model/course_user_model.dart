import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test1/data/model/course_model.dart';

class CourseUserModel {
  final String? id;
  final String courseId;
  final String userId;
 List<StarRating> earnedStars;

  CourseUserModel({this.id, required this.courseId, required this.userId, required this.earnedStars});

  factory CourseUserModel.fromFirestore(DocumentSnapshot doc) {
      Map data = doc.data() as Map;
      return CourseUserModel(
        id: doc.id,
        courseId: data['courseId'],
        userId: data['userId'],
        earnedStars:(data['earnedStars'] as List<dynamic> ?? []).map((starData) => StarRating.fromMap(starData)).toList(),
      );
  }

  Map<String, dynamic> toMap() => {
        'id': '',
        'courseId': courseId,
        'userId': userId,
        'earnedStars':earnedStars.map((star) => star.toMap()).toList(),
      };
}