import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_profile.dart';

const bool useMockData = true;

class UserRepository {
  final FirebaseFirestore? _firestore;

  UserRepository(this._firestore);

  Future<void> saveUser(UserProfile user) async {
    if (useMockData) return;
    final docRef = _firestore!.collection('users').doc(user.uid);
    // Use set with merge to update last login etc without overwriting everything if we used a more complex model
    // But here we want to ensure it exists.
    final docString = await docRef.get();
    if (!docString.exists) {
      await docRef.set(user.toMap());
    } else {
      await docRef.update({
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<UserProfile?> getUser(String uid) async {
    if (useMockData) return null;
    final doc = await _firestore!.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserProfile.fromMap(doc.data()!);
    }
    return null;
  }
}
