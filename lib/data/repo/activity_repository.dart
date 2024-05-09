import 'package:firebase_auth/firebase_auth.dart';
import 'package:test1/global/common/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test1/data/model/activity_model.dart';

class ActivityRepository {
  final CollectionReference activityCollection =
      FirebaseFirestore.instance.collection('activities');

  Stream<List<ActivityModel>> activitiesStream(String sortCondition, bool isAscending) {
    return activityCollection
    .orderBy(sortCondition, descending: isAscending) 
    .snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return ActivityModel.fromFirestore(data);
      }).toList();
    });
  }

  

  Future<String?> createActivity({required ActivityModel activity}) async {
    try {
      final id = activityCollection
          .add(
            activity.toMap(),
          )
          .then((value) => value.id);

      return id;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Stream<ActivityModel?> activityStream(String documentId) {
    return activityCollection.doc(documentId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return ActivityModel.fromFirestore(data);
      }
      return null; 
    });
  }

  Future<void> updateActivityField(
      String documentId, String field, dynamic value) async {
    try {
      await activityCollection.doc(documentId).update({field: value});
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> updateActivity(String documentId, ActivityModel activity) async {
    try {
      final data = activity.toMap();
      await activityCollection.doc(documentId).update(data);
    } catch (e) {
      print(e.toString());
      showToast(message: e.toString());
    }
  }

  // 读取单个活动
  Future<ActivityModel?> getActivity(String documentId) async {
    try {
      var doc = await activityCollection.doc(documentId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return ActivityModel.fromFirestore(data);
      }
      return null;
    } catch (e) {
      print(e.toString());
      showToast(message: e.toString());
      return null;
    }
  }

  // 读取所有活动
  Future<List<ActivityModel>> getAllActivities() async {
    try {
      var querySnapshot = await activityCollection.get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return ActivityModel.fromFirestore(data);
      }).toList();
    } catch (e) {
      showToast(message: e.toString());
      return [];
    }
  }

  Future<void> deleteActivity(String documentId) async {
    try {
      await activityCollection.doc(documentId).delete();
    } catch (e) {
      print(e.toString());
      showToast(message: e.toString());
    }
  }

  Future<void> addParticipant(String activityId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    try {
      await activityCollection.doc(activityId).update({
        'participantIds': FieldValue.arrayUnion([userId])
      });
    } catch (e) {
      print(e.toString());
      showToast(message: e.toString());
    }
  }

  Future<void> removeParticipant(String activityId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    try {
      await activityCollection.doc(activityId).update({
        'participantIds': FieldValue.arrayRemove([userId])
      });
    } catch (e) {
      print(e.toString());
      showToast(message: e.toString());
    }
  }
}
