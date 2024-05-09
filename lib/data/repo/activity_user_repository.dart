import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test1/data/model/activity_user_model.dart';

class ActivityUserRepository {
  final CollectionReference activityUserCollection =
      FirebaseFirestore.instance.collection('activity_users');





  Future<void> createActivityUser(ActivityUserModel activityUser) async {
    final id = activityUser.userId.compareTo(activityUser.activityId) < 0
        ? "${activityUser.userId}${activityUser.activityId}"
        : "${activityUser.activityId}${activityUser.userId}";

    try {
      await activityUserCollection
          .doc(id)
          .set(activityUser.toMap());
    } catch (e) {
      print(e.toString());
    }
  }


Future<void> deleteActivityUser(String activityUserId) async {
  try {
    await FirebaseFirestore.instance
        .collection('activity_users')
        .doc(activityUserId)
        .delete();
  } catch (e) {
    print(e.toString());
  }
}

Stream<List<ActivityUserModel>> getActivityUsersByActivity(String activityId) {
  return FirebaseFirestore.instance
      .collection('activity_users')
      .where('ActivityId', isEqualTo: activityId)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => ActivityUserModel.fromFirestore(doc)).toList());
}


Stream<List<ActivityUserModel>> getActivityUsersByUser(String userId) {
  return FirebaseFirestore.instance
      .collection('activity_users')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => ActivityUserModel.fromFirestore(doc)).toList());
}


Stream<ActivityUserModel?> getActivityUser(String activityId, String userId) {

   final id = userId.compareTo(activityId) < 0
        ? "${userId}${activityId}"
        : "${activityId}${userId}";


  return FirebaseFirestore.instance
      .collection('activity_users')
      .doc(id)
      .snapshots()
      .map((snapshot) {
    if (snapshot.exists) {
      return ActivityUserModel.fromFirestore(snapshot);
    }
    return null;
  });

}
}