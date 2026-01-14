import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String id;
  final List<String> participants;
  final String listingId; // Or null if general, but prompt says tied to listing
  final String listingTitle; 
  final String lastMessage;
  final DateTime updatedAt;
  final int unreadCount; 

  ChatRoom({
    required this.id,
    required this.participants,
    required this.listingId,
    required this.listingTitle,
    required this.lastMessage,
    required this.updatedAt,
    this.unreadCount = 0,
  });

  factory ChatRoom.fromMap(Map<String, dynamic> map, String docId) {
    return ChatRoom(
      id: docId,
      participants: List<String>.from(map['participants'] ?? []),
      listingId: map['listingId'] ?? '',
      listingTitle: map['listingTitle'] ?? 'Listing',
      lastMessage: map['lastMessage'] ?? '',
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      unreadCount: map['unreadCount'] ?? 0,
    );
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map, String docId) {
    return ChatMessage(
      id: docId,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
