import 'package:cloud_firestore/cloud_firestore.dart';

enum PostType { lost, found }
enum PostStatus { open, resolved }
enum ItemCategory { electronics, stationery, idCards, accessories, books, other }

class LostFoundPost {
  final String id;
  final String authorId;
  final PostType type;
  final String title;
  final String description;
  final ItemCategory category;
  final List<String> tags;
  final String locationText;
  final GeoPoint? geo; // Using Firestore GeoPoint
  final List<String> imageUrls;
  final PostStatus status;
  final DateTime dateTime; // Lost/Found time
  final DateTime createdAt;

  LostFoundPost({
    required this.id,
    required this.authorId,
    required this.type,
    required this.title,
    required this.description,
    required this.category,
    required this.tags,
    required this.locationText,
    this.geo,
    this.imageUrls = const [],
    required this.status,
    required this.dateTime,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'type': type.name,
      'title': title,
      'description': description,
      'category': category.name,
      'tags': tags,
      'locationText': locationText,
      'geo': geo,
      'imageUrls': imageUrls,
      'status': status.name,
      'dateTime': Timestamp.fromDate(dateTime),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory LostFoundPost.fromMap(Map<String, dynamic> map, String docId) {
    return LostFoundPost(
      id: docId,
      authorId: map['authorId'] ?? '',
      type: PostType.values.firstWhere((e) => e.name == map['type'], orElse: () => PostType.lost),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: ItemCategory.values.firstWhere((e) => e.name == map['category'], orElse: () => ItemCategory.other),
      tags: List<String>.from(map['tags'] ?? []),
      locationText: map['locationText'] ?? '',
      geo: map['geo'] as GeoPoint?,
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      status: PostStatus.values.firstWhere((e) => e.name == map['status'], orElse: () => PostStatus.open),
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
