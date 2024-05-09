import 'package:cloud_firestore/cloud_firestore.dart';

class  ActivityUserModel {
  String  activityUserId;
  String activityId;
  String userId;
  DateTime joinedAt;

  ActivityUserModel(
      {required this.activityUserId,
      required this.activityId,
      required this.userId,
      required this.joinedAt});


  factory ActivityUserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return ActivityUserModel(
      activityUserId: doc.id,
      activityId: data['ActivityId'],
      userId: data['userId'],
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'ActivityUserId': activityUserId,
        'ActivityId': activityId,
        'userId': userId,
        'joinedAt': joinedAt,
      };

    
}