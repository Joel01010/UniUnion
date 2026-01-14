import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  // Check for mock mode from the repository file
  // Note: Since useMockData is a constant in user_repository.dart, we can use it here
  return UserRepository(useMockData ? null : FirebaseFirestore.instance);
});
