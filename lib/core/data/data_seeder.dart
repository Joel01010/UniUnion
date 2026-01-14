import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:vit_chennai_student_utility/features/auth/presentation/providers/auth_provider.dart';
import 'package:vit_chennai_student_utility/features/lending/data/repositories/lending_repository.dart';
import 'package:vit_chennai_student_utility/features/lending/domain/entities/listing.dart';
import 'package:vit_chennai_student_utility/features/locator/data/repositories/locator_repository.dart';
import 'package:vit_chennai_student_utility/features/locator/domain/entities/class_post.dart';
import 'package:vit_chennai_student_utility/features/refind/data/repositories/refind_repository.dart';
import 'package:vit_chennai_student_utility/features/refind/domain/entities/lost_found_post.dart';

class DataSeeder {
  final Ref ref;

  DataSeeder(this.ref);

  Future<void> seedData() async {
    final user = ref.read(authServiceProvider).currentUser;
    final userId = user?.uid ?? 'demo_user_123';
    final now = DateTime.now();

    // Seed LendLink
    final lendingRepo = ref.read(lendingRepositoryProvider);
    await lendingRepo.createListing(Listing(
      id: const Uuid().v4(),
      ownerId: userId,
      type: ListingType.item,
      title: 'Scientific Calculator fx-991EX',
      description: 'Barely used, need to return by tomorrow evening.',
      category: ListingCategory.stationery,
      locationArea: 'A Block',
      status: ListingStatus.active,
      createdAt: now,
      updatedAt: now,
    ));
    await lendingRepo.createListing(Listing(
      id: const Uuid().v4(),
      ownerId: 'other_user',
      type: ListingType.money,
      title: 'Need ₹500 urgent',
      description: 'Will return via UPI in 2 hours.',
      category: ListingCategory.money,
      amount: 500,
      locationArea: 'Canteen',
      status: ListingStatus.active,
      createdAt: now.subtract(const Duration(minutes: 30)),
      updatedAt: now,
    ));

    // Seed RoomRadar
    final locatorRepo = ref.read(locatorRepositoryProvider);
    await locatorRepo.createPost(ClassPost(
      id: const Uuid().v4(),
      authorId: userId,
      block: 'AB1',
      roomNumber: '304',
      spottedAt: now,
      expiresAt: now.add(const Duration(minutes: 45)),
      notes: 'Empty and AC on.',
    ));

    // Seed ReFind
    final refindRepo = ref.read(reFindRepositoryProvider);
    await refindRepo.createPost(LostFoundPost(
      id: const Uuid().v4(),
      authorId: userId,
      type: PostType.lost,
      title: 'Black Samsonite Bag',
      description: 'Left it near library entrance.',
      category: ItemCategory.other,
      tags: ['bag', 'black', 'samsonite'],
      locationText: 'Library',
      status: PostStatus.open,
      dateTime: now.subtract(const Duration(hours: 2)),
      createdAt: now,
    ));
    
    await refindRepo.createPost(LostFoundPost(
      id: const Uuid().v4(),
      authorId: 'other_user',
      type: PostType.found,
      title: 'Blue Water Bottle',
      description: 'Found at Food Court table.',
      category: ItemCategory.other,
      tags: ['bottle', 'blue'],
      locationText: 'Food Court',
      status: PostStatus.open,
      dateTime: now.subtract(const Duration(minutes: 10)),
      createdAt: now,
    ));
  }
}

final dataSeederProvider = Provider<DataSeeder>((ref) => DataSeeder(ref));
