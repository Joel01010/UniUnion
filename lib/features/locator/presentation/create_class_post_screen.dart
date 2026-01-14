import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../data/repositories/locator_repository.dart';
import '../domain/entities/class_post.dart';
import '../../auth/presentation/providers/auth_provider.dart';

class CreateClassPostScreen extends ConsumerStatefulWidget {
  const CreateClassPostScreen({super.key});

  @override
  ConsumerState<CreateClassPostScreen> createState() => _CreateClassPostScreenState();
}

class _CreateClassPostScreenState extends ConsumerState<CreateClassPostScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _blockController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  // Default TTL 45 mins
  int _ttlMinutes = 45;
  bool _isLoading = false;

  @override
  void dispose() {
    _blockController.dispose();
    _roomController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final post = ClassPost(
        id: const Uuid().v4(),
        authorId: user.uid,
        block: _blockController.text.trim(),
        roomNumber: _roomController.text.trim(),
        spottedAt: now,
        notes: _notesController.text.trim(),
        expiresAt: now.add(Duration(minutes: _ttlMinutes)),
      );

      await ref.read(locatorRepositoryProvider).createPost(post);
      
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Posted room update!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Room')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _blockController,
              decoration: const InputDecoration(labelText: 'Block/Building', hintText: 'e.g. AB1'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _roomController,
              decoration: const InputDecoration(labelText: 'Room Number', hintText: 'e.g. 304'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes (Optional)', hintText: 'AC is working, quiet spot.'),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('Free for next: '),
                DropdownButton<int>(
                  value: _ttlMinutes,
                  items: const [
                    DropdownMenuItem(value: 30, child: Text('30 mins')),
                    DropdownMenuItem(value: 45, child: Text('45 mins')),
                    DropdownMenuItem(value: 60, child: Text('1 hour')),
                    DropdownMenuItem(value: 90, child: Text('1.5 hours')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _ttlMinutes = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Share Location'),
            ),
          ],
        ),
      ),
    );
  }
}
