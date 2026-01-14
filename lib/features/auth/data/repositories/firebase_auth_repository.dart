import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/repositories/auth_service.dart';

class FirebaseAuthRepository implements AuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthRepository(this._firebaseAuth, this._googleSignIn);

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // User canceled

      // Domain Restriction Check
      if (!googleUser.email.endsWith('vitstudent.ac.in')) {
        await _googleSignIn.signOut();
        throw Exception('Access restricted to VIT Chennai students (@vitstudent.ac.in)');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    // Validate domain before attempting sign-in
    if (!email.trim().toLowerCase().endsWith('@vitstudent.ac.in')) {
      throw Exception('Access restricted to VIT Chennai students (@vitstudent.ac.in)');
    }
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No account found with this email');
        case 'wrong-password':
          throw Exception('Incorrect password');
        case 'invalid-email':
          throw Exception('Invalid email address');
        case 'user-disabled':
          throw Exception('This account has been disabled');
        case 'too-many-requests':
          throw Exception('Too many attempts. Please try again later');
        default:
          throw Exception('Sign in failed: ${e.message}');
      }
    }
  }

  @override
  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    if (!email.trim().toLowerCase().endsWith('@vitstudent.ac.in')) {
      throw Exception('Registration restricted to VIT Chennai students (@vitstudent.ac.in)');
    }
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('An account already exists with this email');
        case 'weak-password':
          throw Exception('Password is too weak. Use at least 6 characters');
        case 'invalid-email':
          throw Exception('Invalid email address');
        default:
          throw Exception('Registration failed: ${e.message}');
      }
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}
