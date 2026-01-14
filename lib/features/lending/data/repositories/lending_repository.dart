import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/listing.dart';

// Flag to use mock data (set to true if Firebase is not configured)
const bool useMockData = false;

class LendingRepository {
  final FirebaseFirestore? _firestore;

  LendingRepository(this._firestore);

  // Create Listing
  Future<void> createListing(Listing listing) async {
    if (useMockData) return; // Skip in mock mode
    final docRef = _firestore!.collection('listings').doc(listing.id.isEmpty ? null : listing.id);
    final data = listing.toMap();
    await docRef.set(data);
  }
  
  // Create with Auto ID
  Future<void> addListing(Map<String, dynamic> data) async {
    if (useMockData) return;
    await _firestore!.collection('listings').add(data);
  }

  // Get Listings Feed
  Stream<List<Listing>> getListings() {
    if (useMockData) {
      return Stream.value(_getMockListings());
    }
    return _firestore!.collection('listings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Listing.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  List<Listing> _getMockListings() {
    final now = DateTime.now();
    return [
      Listing(
        id: 'mock1',
        ownerId: 'user1',
        type: ListingType.item,
        title: 'Scientific Calculator fx-991EX',
        description: 'Barely used, need to return by tomorrow evening.',
        category: ListingCategory.stationery,
        locationArea: 'A Block',
        status: ListingStatus.active,
        createdAt: now,
        updatedAt: now,
      ),
      Listing(
        id: 'mock2',
        ownerId: 'user2',
        type: ListingType.money,
        title: 'Need Rs. 200 for lunch',
        description: 'Will return by 5pm today. UPI preferred.',
        category: ListingCategory.money,
        locationArea: 'Main Canteen',
        status: ListingStatus.active,
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        amount: 200,
      ),
      Listing(
        id: 'mock3',
        ownerId: 'user3',
        type: ListingType.item,
        title: 'USB-C Charger',
        description: 'Need for 2 hours, my laptop is dying!',
        category: ListingCategory.electronics,
        locationArea: 'Library',
        status: ListingStatus.active,
        createdAt: now.subtract(const Duration(hours: 1)),
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
    ];
  }
}

final lendingRepositoryProvider = Provider<LendingRepository>((ref) {
  return LendingRepository(useMockData ? null : FirebaseFirestore.instance);
});

final listingsFeedProvider = StreamProvider<List<Listing>>((ref) {
  return ref.watch(lendingRepositoryProvider).getListings();
});
