import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../data/repositories/refind_repository.dart';
import '../domain/entities/lost_found_post.dart';
import '../../../../core/presentation/widgets/empty_state_widget.dart';
import 'refind_ai_service.dart';

class ReFindScreen extends ConsumerStatefulWidget {
  const ReFindScreen({super.key});

  @override
  ConsumerState<ReFindScreen> createState() => _ReFindScreenState();
}

class _ReFindScreenState extends ConsumerState<ReFindScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _handleReFindAI() async {
    // 1. Pick Image
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo == null) return;
    
    // 2. Show Loading
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Analyzing image with ReFind AI...')),
    );
    
    try {
        // 3. Process
        final service = ref.read(reFindAIServiceProvider);
        final result = await service.processImage(File(photo.path));
        
        // 4. Navigate to Create with Draft Data
        if (!mounted) return;
        context.push('/refind/create', extra: {
            'imagePath': photo.path,
            'aiDraft': result,
            'type': PostType.found, // Usually photos are for found items
        });
    } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('AI Error: $e')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(reFindFeedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ReFind Lost & Found'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Lost Items'),
            Tab(text: 'Found Items'),
          ],
        ),
      ),
      body: postsAsync.when(
        data: (posts) {
          final lostPosts = posts.where((p) => p.type == PostType.lost).toList();
          final foundPosts = posts.where((p) => p.type == PostType.found).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(lostPosts, 'No lost items report created.'),
              _buildList(foundPosts, 'No found items reported.'),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'ai_scan',
            onPressed: _handleReFindAI,
            icon: const Icon(Icons.camera_alt),
            label: const Text('AI Scan'),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'manual_add',
            onPressed: () {
                context.push('/refind/create');
            },
            child: const Icon(Icons.edit),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<LostFoundPost> posts, String emptyMsg) {
    if (posts.isEmpty) {
      return EmptyStateWidget(message: emptyMsg, icon: Icons.saved_search);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final post = posts[index];
        return Card(
          child: ListTile(
            leading: post.imageUrls.isNotEmpty 
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(post.imageUrls.first, width: 50, height: 50, fit: BoxFit.cover,
                        errorBuilder: (c,e,s) => const Icon(Icons.broken_image))
                  )
                : const Icon(Icons.image_not_supported),
            title: Text(post.title),
            subtitle: Text(post.description, maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: post.status == PostStatus.resolved 
                ? const Chip(label: Text('Resolved', style: TextStyle(fontSize: 10))) 
                : null,
          ),
        );
      },
    );
  }
}
