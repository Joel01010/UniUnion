import 'package:cloud_firestore/cloud_firestore.dart';

class ClassPost {
  final String id;
  final String authorId;
  final String block; // e.g. AB1, AB2
  final String roomNumber;
  final DateTime spottedAt;
  final DateTime? freeUntil;
  final String? notes;
  final DateTime expiresAt;
  final int confirmationsCount;
  final int reportsCount;

  ClassPost({
    required this.id,
    required this.authorId,
    required this.block,
    required this.roomNumber,
    required this.spottedAt,
    this.freeUntil,
    this.notes,
    required this.expiresAt,
    this.confirmationsCount = 0,
    this.reportsCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'block': block,
      'roomNumber': roomNumber,
      'spottedAt': Timestamp.fromDate(spottedAt),
      'freeUntil': freeUntil != null ? Timestamp.fromDate(freeUntil!) : null,
      'notes': notes,
      'expiresAt': Timestamp.fromDate(expiresAt),
      'confirmationsCount': confirmationsCount,
      'reportsCount': reportsCount,
    };
  }

  factory ClassPost.fromMap(Map<String, dynamic> map, String docId) {
    return ClassPost(
      id: docId,
      authorId: map['authorId'] ?? '',
      block: map['block'] ?? '',
      roomNumber: map['roomNumber'] ?? '',
      spottedAt: (map['spottedAt'] as Timestamp).toDate(),
      freeUntil: (map['freeUntil'] as Timestamp?)?.toDate(),
      notes: map['notes'],
      expiresAt: (map['expiresAt'] as Timestamp).toDate(),
      confirmationsCount: map['confirmationsCount'] ?? 0,
      reportsCount: map['reportsCount'] ?? 0,
    );
  }
}
