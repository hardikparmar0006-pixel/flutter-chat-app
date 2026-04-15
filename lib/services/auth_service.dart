import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  String get uid => _auth.currentUser!.uid;

  Future<void> register(String email, String password) async {
    final user = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    await _db.collection('users').doc(user.user!.uid).set({
      "uid": user.user!.uid,
      "email": email,
      "createdAt": DateTime.now(),
    });
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }
}