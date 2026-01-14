import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../data/repositories/locator_repository.dart';
import '../domain/entities/class_post.dart';
import '../../../../core/presentation/widgets/empty_state_widget.dart';

class LocatorScreen extends ConsumerWidget {
  const LocatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(locatorFeedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('RoomRadar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: postsAsync.when(
        data: (posts) {
          if (posts.isEmpty) {
            return const EmptyStateWidget(
              message: 'No empty rooms reported nearby',
              subMessage: 'Found one? Tap + to share!',
              icon: Icons.meeting_room_outlined,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _ClassPostCard(post: posts[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/locator/create'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About RoomRadar'),
        content: const Text(
          'This is a live feed of empty rooms reported by students. '
          'Posts automatically expire after a set time (e.g. 45 mins) to keep data fresh.'
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it')),
        ],
      ),
    );
  }
}

class _ClassPostCard extends ConsumerWidget {
  final ClassPost post;

  const _ClassPostCard({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeFormatter = DateFormat.jm();
    final remaining = post.expiresAt.difference(DateTime.now());
    final remainingMinutes = remaining.inMinutes;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    post.block,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  post.roomNumber,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Expires in ${remainingMinutes}m',
                      style: TextStyle(
                        color: remainingMinutes < 10 ? Colors.red : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (post.notes != null && post.notes!.isNotEmpty)
              Text(
                post.notes!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spotted: ${timeFormatter.format(post.spottedAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(locatorRepositoryProvider).confirmEmpty(post.id);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanks for verifying!')));
                  },
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: Text(
                    post.confirmationsCount > 0
                        ? 'Still Empty (${post.confirmationsCount})'
                        : 'Still Empty',
                  ),
                  style: ElevatedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: Colors.green.withAlpha(26),
                    foregroundColor: Colors.green,
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
