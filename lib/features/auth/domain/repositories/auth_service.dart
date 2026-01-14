import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthService {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  Future<void> signInWithGoogle();
  Future<void> signInWithEmailAndPassword(String email, String password);
  Future<void> signUpWithEmailAndPassword(String email, String password);
  Future<void> signOut();
}
