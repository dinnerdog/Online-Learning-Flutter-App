import 'package:firebase_auth/firebase_auth.dart';
import 'package:test1/data/repo/incentives_repository.dart';
import 'package:test1/global/common/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test1/data/model/user_model.dart';
import 'package:test1/global/helper/image_picker_uploader_helper.dart';

class UserRepository {
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  Stream<UserModel?> getUserByIdStream(String userId) {
    return userCollection.doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromFirestore(snapshot);
      } else {
        showToast(message: 'User not found');
        return null;
      }
      
    });
  }

Stream<List<UserModel>>  getAllStudents() {
    return userCollection.where('role', isEqualTo: 'student').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromFirestore(doc);
      }).toList();
    });
  

  }


Stream<List<UserModel?>> getUsersByIdsStream(List<String> userIds) {
    return userCollection.where(FieldPath.documentId, whereIn: userIds).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromFirestore(doc);
      }).toList();
    });
  }


  Stream<UserModel?> getCurrentUserStream() {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      showToast(message: 'No user logged in');
      return Stream.value(null);
    }

    return userCollection.doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromFirestore(snapshot);
      } else {
        showToast(message: 'User not found');
        return null;
      }
    });
  }

  Stream<List<UserModel>> getAllUsersStream() {
    return userCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromFirestore(doc);
      }).toList();
    });
  }



Future<void> removeListField(String field, dynamic newValue) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      await userCollection.doc(userId).update({
        field: FieldValue.arrayRemove([newValue])
      });
    } on FirebaseAuthException catch (e) {
      showToast(message: e.toString());
    } catch (e) {
      showToast(message: e.toString());
    }
  }
  
  Future<UserModel?> signUpWithEmailAndPassword(
      UserModel user, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: user.email, password: password);

      if (user.avatarUrl != ''){
         final url = await ImagePickerUploaderHelper.uploadImage(category: 'avatar', id: userCredential.user!.uid, imageUrl: user.avatarUrl!);

        user.avatarUrl = url;
      }



     await  FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(
            user.toMap(),
          );

      final newUser = await getUserById(userCredential.user!.uid);
    
      await IncentiveRepository().createIncentive(userCredential.user!.uid);
      return newUser;
    } on FirebaseAuthException catch (e) {
      showToast(message: e.toString());
      return null;
    } catch (e) {
      showToast(message: e.toString());
      return null;
    }
  }



  Future<void> appendListField(String field, dynamic newValue) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      await userCollection.doc(userId).update({
        field: FieldValue.arrayUnion([newValue])
      });
    } on FirebaseAuthException catch (e) {
      showToast(message: e.toString());
    } catch (e) {
      showToast(message: e.toString());
    }
  }

Future<void> appendListFieldWithId(String field, dynamic newValue, String id) async {
    try {
      await userCollection.doc(id).update({
        field: FieldValue.arrayUnion([newValue])
      });
      showToast(message: 'User info updated successfully.');
    } on FirebaseAuthException catch (e) {
      showToast(message: e.toString());
    } catch (e) {
      showToast(message: e.toString());
    }
  }



  Future<void> updateUserField(String field, dynamic newValue) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      await userCollection.doc(userId).update({field: newValue});
      showToast(message: 'User info updated successfully.');
    } on FirebaseAuthException catch (e) {
      showToast(message: e.toString());
    } catch (e) {
      showToast(message: e.toString());
    }
  }

  Future<void> updateUserDynamicField(Map<String, dynamic> fields) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      await userCollection.doc(userId).update(fields);
      showToast(message: 'User info updated successfully.');
    } on FirebaseAuthException catch (e) {
      showToast(message: e.toString());
    } catch (e) {
      showToast(message: e.toString());
    }
  }

  

  Future<void> updateUserFieldWithId(
      String field, dynamic newValue, String id) async {
    try {
      await userCollection.doc(id).update({field: newValue});
      showToast(message: 'User info updated successfully.');
    } on FirebaseAuthException catch (e) {
      showToast(message: e.toString());
    } catch (e) {
      showToast(message: e.toString());
    }
  }

  //get current user by id
  Future<UserModel?> getCurrentUser() async {
    try {
      final uid = await FirebaseAuth.instance.currentUser?.uid;

      final user = await userCollection.doc(uid).get();
      if (user.exists) {
        return UserModel.fromFirestore(user);
      } else {
 
        return null;
      }
    } catch (e) {
      print(e);
      showToast(message: e.toString());
      return null;
    }
  }

  Future<UserModel> getUserById(String UserId) {
    return userCollection
        .doc(UserId)
        .get()
        .then((doc) => UserModel.fromFirestore(doc));
  }
}
