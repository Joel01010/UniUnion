import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/lost_found_post.dart';

const bool useMockData = false;

class ReFindRepository {
  final FirebaseFirestore? _firestore;

  ReFindRepository(this._firestore);

  Future<void> createPost(LostFoundPost post) async {
    if (useMockData) return;
    final docRef = _firestore!.collection('lost_found_posts').doc(post.id.isEmpty ? null : post.id);
    await docRef.set(post.toMap());
  }

  Stream<List<LostFoundPost>> getPosts() {
    if (useMockData) {
      return Stream.value(_getMockPosts());
    }
    return _firestore!.collection('lost_found_posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => LostFoundPost.fromMap(doc.data(), doc.id)).toList();
    });
  }
  
  Future<void> resolvePost(String id) async {
    if (useMockData) return;
    await _firestore!.collection('lost_found_posts').doc(id).update({
      'status': PostStatus.resolved.name,
    });
  }

  List<LostFoundPost> _getMockPosts() {
    final now = DateTime.now();
    return [
      LostFoundPost(
        id: 'lf1',
        authorId: 'user1',
        type: PostType.lost,
        title: 'Lost Blue Umbrella',
        description: 'Left it in A301 after morning class.',
        category: ItemCategory.accessories,
        tags: ['umbrella', 'blue', 'A block'],
        locationText: 'A Block, 3rd Floor',
        status: PostStatus.open,
        dateTime: now.subtract(const Duration(hours: 3)),
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      LostFoundPost(
        id: 'lf2',
        authorId: 'user2',
        type: PostType.found,
        title: 'Found Student ID Card',
        description: 'Found near Main Canteen. Name: Rahul Sharma',
        category: ItemCategory.idCards,
        tags: ['id card', 'student'],
        locationText: 'Main Canteen',
        status: PostStatus.open,
        dateTime: now.subtract(const Duration(hours: 1)),
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      LostFoundPost(
        id: 'lf3',
        authorId: 'user3',
        type: PostType.lost,
        title: 'Lost AirPods Pro Case',
        description: 'White case, might be in Library or B Block.',
        category: ItemCategory.electronics,
        tags: ['airpods', 'electronics', 'apple'],
        locationText: 'Library / B Block',
        status: PostStatus.open,
        dateTime: now.subtract(const Duration(minutes: 30)),
        createdAt: now.subtract(const Duration(minutes: 30)),
      ),
    ];
  }
}

final reFindRepositoryProvider = Provider<ReFindRepository>((ref) {
  return ReFindRepository(useMockData ? null : FirebaseFirestore.instance);
});

final reFindFeedProvider = StreamProvider<List<LostFoundPost>>((ref) {
  return ref.watch(reFindRepositoryProvider).getPosts();
});
