import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart'; // Your custom User model

class AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final firebase_auth.UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebase_auth.User firebaseUser = userCredential.user!;
      final DocumentSnapshot userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      return User.fromFirestore(userDoc);
    } catch (e) {
      throw Exception('Sign-in failed: $e');
    }
  }

  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final firebase_auth.UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebase_auth.User firebaseUser = userCredential.user!;
      final User user = User(firebaseUser.uid, email);
      await _firestore.collection('users').doc(firebaseUser.uid).set(user.toMap());
      return user;
    } catch (e) {
      throw Exception('Sign-up failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Sign-out failed: $e');
    }
  }
}
