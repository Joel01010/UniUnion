import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vit_chennai_student_utility/features/auth/presentation/providers/auth_provider.dart';
import '../data/repositories/chat_repository.dart';
// import '../domain/entities/chat_room.dart';
import '../../../../core/presentation/widgets/empty_state_widget.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text('Please login')));

    final chatsAsync = ref.watch(myChatsProvider(user.uid));

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: chatsAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return const EmptyStateWidget(
              message: 'No messages yet', 
              subMessage: 'Start a conversation from a listing.',
              icon: Icons.chat_bubble_outline
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: chats.length,
            separatorBuilder: (c, i) => const Divider(),
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ListTile(
                leading: CircleAvatar(child: Text(chat.participants.firstWhere((id) => id != user.uid).substring(0, 1).toUpperCase())),
                title: Text(chat.listingTitle),
                subtitle: Text(chat.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: chat.unreadCount > 0 
                  ? CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Text(chat.unreadCount.toString(), style: const TextStyle(fontSize: 10, color: Colors.white)))
                  : null,
                onTap: () {
                  context.push('/chats/${chat.id}', extra: chat);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
