import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test1/data/model/incentives_model.dart';
import 'package:test1/global/common/toast.dart';

class IncentiveRepository {
  final db = FirebaseFirestore.instance;



 Future<void> createIncentive(String userId) async { 
  try {
    DocumentReference docRef = db.collection('incentives').doc(userId);

    await docRef.set({
      'userId': userId,
      'badges': [],
      'stars': [],
      'certificates': [],
      'mana': [],
      'achievements': [],
    });


  } catch (e) {
    showToast(message: e.toString());
  }
}


  Future<void> deleteIncentive(String userId) async{
    try {
      await db.collection('incentives').doc(userId).delete();
    } catch (e) {
      showToast(message: e.toString());
    } 
  }


  Future<void> _updateIncentiveField(String userId, String field, dynamic newValue) async {
    try { 
      await db.collection('incentives').doc(userId).update({field: newValue});
    } catch (e) {
      showToast(message: e.toString());
    }
  }

  Future<void> _appendIncentiveField(String userId, String field, dynamic newValue) async {
    try {
      await db.collection('incentives').doc(userId).update({field: FieldValue.arrayUnion([newValue])});
    } catch (e) {
      showToast(message: e.toString());
    }
  }

 
  


  Future<void> addIncentive(
      IncentiveType incentiveType, String userId ,List<dynamic> models) async {
        models = models.map((model) => model.toMap()).toList();
    switch (incentiveType) {
      case IncentiveType.achievement:
       for (var model in models) {
          _appendIncentiveField(userId, 'achievements', model);
       }
      case IncentiveType.badge:
       for (var model in models) {
          _appendIncentiveField(userId, 'badges', model);

       }
      case IncentiveType.certificate:
       for (var model in models) {
          _appendIncentiveField(userId, 'certificates', model);
       }
      case IncentiveType.mana:
       for (var model in models) {
          _appendIncentiveField(userId, 'mana', model);
       }
      case IncentiveType.star:
       for (var model in models) {
          _appendIncentiveField(userId, 'stars', model);
       }
        break;
      default:
        throw Exception('Incentive type not found');
    }
  }


  Stream<IncentiveModel> getIncentivesForUserStream(String userId) {
      return db.collection('incentives').doc(userId).snapshots().map((snapshot) {
        return IncentiveModel.fromFirestore(snapshot);
      });
  }



  
  




}


