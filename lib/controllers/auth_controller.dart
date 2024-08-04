// lib/controllers/auth_controller.dart

import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      return null;
    }
  }

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  void signOut() {
    _auth.signOut();
  }
}
