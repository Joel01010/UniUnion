import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/auth_service.dart';

class MockUser implements User {
  @override
  String get uid => 'mock-user-id';

  @override
  String? get email => 'test@vit.ac.in';

  @override
  String? get displayName => 'Mock User';

  @override
  String? get photoURL => 'https://i.pravatar.cc/150?img=11';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAuthRepository implements AuthService {
  final _controller = StreamController<User?>.broadcast();
  bool _isLoggedIn = false;

  MockAuthRepository() {
    _controller.add(null);
  }

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  User? get currentUser => _isLoggedIn ? MockUser() : null;

  @override
  Future<void> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
    _isLoggedIn = true;
    _controller.add(MockUser());
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _isLoggedIn = true;
    _controller.add(MockUser());
  }

  @override
  Future<void> signUpWithEmailAndPassword(String email, String password) async {
     if (!email.trim().toLowerCase().endsWith('@vitstudent.ac.in')) {
      throw Exception('Registration restricted to VIT Chennai students (@vitstudent.ac.in)');
    }
    await Future.delayed(const Duration(seconds: 1));
    _isLoggedIn = true;
    _controller.add(MockUser());
  }

  @override
  Future<void> signOut() async {
    _isLoggedIn = false;
    _controller.add(null);
  }
  
  bool get mockLoggedIn => _isLoggedIn;
}
