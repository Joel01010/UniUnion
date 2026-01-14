import 'package:cloud_firestore/cloud_firestore.dart';

enum ListingType { item, money }
enum ListingStatus { active, paused, closed }
enum ListingCategory { electronics, stationery, clothing, accessories, books, money, other }

class Listing {
  final String id;
  final String ownerId;
  final ListingType type;
  final String title;
  final String description;
  final ListingCategory category;
  final double? amount; // For money
  final double? deposit;
  final DateTime? dueDate;
  final String locationArea;
  final List<String> imageUrls;
  final ListingStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Listing({
    required this.id,
    required this.ownerId,
    required this.type,
    required this.title,
    required this.description,
    required this.category,
    this.amount,
    this.deposit,
    this.dueDate,
    required this.locationArea,
    this.imageUrls = const [],
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'type': type.name,
      'title': title,
      'description': description,
      'category': category.name,
      'amount': amount,
      'deposit': deposit,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'locationArea': locationArea,
      'imageUrls': imageUrls,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory Listing.fromMap(Map<String, dynamic> map, String docId) {
    return Listing(
      id: docId,
      ownerId: map['ownerId'] ?? '',
      type: ListingType.values.firstWhere((e) => e.name == map['type'], orElse: () => ListingType.item),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: ListingCategory.values.firstWhere((e) => e.name == map['category'], orElse: () => ListingCategory.other),
      amount: (map['amount'] as num?)?.toDouble(),
      deposit: (map['deposit'] as num?)?.toDouble(),
      dueDate: (map['dueDate'] as Timestamp?)?.toDate(),
      locationArea: map['locationArea'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      status: ListingStatus.values.firstWhere((e) => e.name == map['status'], orElse: () => ListingStatus.active),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
}
