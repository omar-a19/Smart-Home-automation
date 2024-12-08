import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String email;

  User(this.uid, this.email);

  factory User.fromFirebaseUser(firebase_auth.User firebaseUser) {
    return User(firebaseUser.uid, firebaseUser.email ?? '');
  }

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return User(data['uid'], data['email']);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
    };
  }

}
