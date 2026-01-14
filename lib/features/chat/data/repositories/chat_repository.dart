import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chat_room.dart';

const bool useMockData = true;

class ChatRepository {
  final FirebaseFirestore? _firestore;

  ChatRepository(this._firestore);

  Stream<List<ChatRoom>> getChatRooms(String userId) {
    if (useMockData) {
      return Stream.value(_getMockChatRooms());
    }
    return _firestore!.collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatRoom.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Stream<List<ChatMessage>> getMessages(String roomId) {
    if (useMockData) {
      return Stream.value(_getMockMessages());
    }
    return _firestore!.collection('chats').doc(roomId).collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatMessage.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> sendMessage(String roomId, String senderId, String text) async {
    if (useMockData) return;
    final firestore = _firestore!;
    final batch = firestore.batch();
    final roomRef = firestore.collection('chats').doc(roomId);
    final messageRef = roomRef.collection('messages').doc();

    final message = ChatMessage(
        id: messageRef.id, 
        senderId: senderId, 
        text: text, 
        createdAt: DateTime.now()
    );

    batch.set(messageRef, message.toMap());
    batch.update(roomRef, {
      'lastMessage': text,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
  
  Future<String> createRoom({
      required List<String> participants, 
      required String listingId,
      required String listingTitle
  }) async {
      if (useMockData) return 'mock_room_id';
      final ref = _firestore!.collection('chats').doc();
      await ref.set({
          'participants': participants,
          'listingId': listingId,
          'listingTitle': listingTitle,
          'lastMessage': 'Chat started',
          'updatedAt': FieldValue.serverTimestamp(),
          'unreadCount': 0,
      });
      return ref.id;
  }

  List<ChatRoom> _getMockChatRooms() {
    final now = DateTime.now();
    return [
      ChatRoom(
        id: 'chat1',
        participants: ['user1', 'user2'],
        listingId: 'mock1',
        listingTitle: 'Scientific Calculator fx-991EX',
        lastMessage: 'Sure, I can lend it to you!',
        updatedAt: now.subtract(const Duration(minutes: 10)),
        unreadCount: 1,
      ),
      ChatRoom(
        id: 'chat2',
        participants: ['user1', 'user3'],
        listingId: 'mock2',
        listingTitle: 'Need Rs. 200 for lunch',
        lastMessage: 'Sent via UPI!',
        updatedAt: now.subtract(const Duration(hours: 1)),
        unreadCount: 0,
      ),
    ];
  }

  List<ChatMessage> _getMockMessages() {
    final now = DateTime.now();
    return [
      ChatMessage(id: 'm1', senderId: 'user2', text: 'Sure, I can lend it to you!', createdAt: now.subtract(const Duration(minutes: 10))),
      ChatMessage(id: 'm2', senderId: 'user1', text: 'Hey, can I borrow your calculator?', createdAt: now.subtract(const Duration(minutes: 15))),
    ];
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(useMockData ? null : FirebaseFirestore.instance);
});

final myChatsProvider = StreamProvider.family<List<ChatRoom>, String>((ref, userId) {
  return ref.watch(chatRepositoryProvider).getChatRooms(userId);
});

final csvMessagesProvider = StreamProvider.family<List<ChatMessage>, String>((ref, roomId) {
  return ref.watch(chatRepositoryProvider).getMessages(roomId);
});
