import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/class_post.dart';

const bool useMockData = false;

class LocatorRepository {
  final FirebaseFirestore? _firestore;

  LocatorRepository(this._firestore);

  Future<void> createPost(ClassPost post) async {
    if (useMockData) return;
    final docRef = _firestore!.collection('empty_class_posts').doc(post.id.isEmpty ? null : post.id);
    await docRef.set(post.toMap());
  }

  Stream<List<ClassPost>> getLivePosts() {
    if (useMockData) {
      return Stream.value(_getMockPosts());
    }
    final now = DateTime.now();
    return _firestore!.collection('empty_class_posts')
        .where('expiresAt', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('expiresAt', descending: false)
        .orderBy('spottedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ClassPost.fromMap(doc.data(), doc.id))
          .where((post) => post.expiresAt.isAfter(DateTime.now()))
          .toList();
    });
  }

  Future<void> confirmEmpty(String postId) async {
    if (useMockData) return;
    await _firestore!.collection('empty_class_posts').doc(postId).update({
      'confirmationsCount': FieldValue.increment(1),
    });
  }

  List<ClassPost> _getMockPosts() {
    final now = DateTime.now();
    return [
      ClassPost(
        id: 'loc1',
        authorId: 'user1',
        block: 'A Block',
        roomNumber: 'A301',
        freeUntil: now.add(const Duration(hours: 2)),
        spottedAt: now.subtract(const Duration(minutes: 15)),
        expiresAt: now.add(const Duration(hours: 2)),
        confirmationsCount: 3,
        notes: 'Spotted by Arjun K.',
      ),
      ClassPost(
        id: 'loc2',
        authorId: 'user2',
        block: 'B Block',
        roomNumber: 'B102',
        freeUntil: now.add(const Duration(hours: 1)),
        spottedAt: now.subtract(const Duration(minutes: 5)),
        expiresAt: now.add(const Duration(hours: 1)),
        confirmationsCount: 1,
        notes: 'Spotted by Priya S.',
      ),
    ];
  }
}

final locatorRepositoryProvider = Provider<LocatorRepository>((ref) {
  return LocatorRepository(useMockData ? null : FirebaseFirestore.instance);
});

final locatorFeedProvider = StreamProvider<List<ClassPost>>((ref) {
  return ref.watch(locatorRepositoryProvider).getLivePosts();
});
