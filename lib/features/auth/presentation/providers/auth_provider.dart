import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/repositories/auth_service.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../data/repositories/mock_auth_repository.dart';

// Flag to switch between Real and Mock.
// In production this should be false.
const bool useMockAuth = false; 

final authServiceProvider = Provider<AuthService>((ref) {
  if (useMockAuth) {
    return MockAuthRepository();
  }
  return FirebaseAuthRepository(
    FirebaseAuth.instance,
    GoogleSignIn(
      clientId: '791985764276-od2560tp00vv34h4p0vkgbr22h357cgt.apps.googleusercontent.com',
      serverClientId: '791985764276-od2560tp00vv34h4p0vkgbr22h357cgt.apps.googleusercontent.com',
      scopes: ['email', 'profile'],
    ),
  );
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});
