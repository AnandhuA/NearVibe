import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:near_vibe/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
    FirebaseFirestore.instance;

  Future<UserCredential> createAccount({
    required String email,
    required String password,
    required String name
  }) async{
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
      await _firestore
      .collection('users')
      .doc(credential.user!.uid)
      .set({
    'uid': credential.user!.uid,
    'name': name,
    'email': email,
    'balance': 0,
    'createdAt': FieldValue.serverTimestamp(),
  });
 return credential;
  }


   Future<UserCredential> login({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }



Future<UserModel> getCurrentUser(String uid) async {
  final doc = await _firestore
      .collection('users')
      .doc(uid)
      .get();

  return UserModel.fromDocument(doc);
}
}