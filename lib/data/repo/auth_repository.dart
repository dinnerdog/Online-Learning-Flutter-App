import 'package:firebase_auth/firebase_auth.dart';
import 'package:test1/global/common/toast.dart';


class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<User?> signInWithCredentials(String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      showToast(message: e.toString());
  }
  }


Future<User?> signUpWithEmailAndPassword(String email, String password) async {
  try {
    final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  } on FirebaseAuthException catch (e) {
    print(e);  
  }
}

  Future<void> signOut() async {
    return  await _firebaseAuth.signOut();  
  }

  Future<User?> getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }

  }

