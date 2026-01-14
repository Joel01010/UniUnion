import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../data/repositories/refind_repository.dart';
import '../domain/entities/lost_found_post.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../../core/services/location_service.dart';

class CreateLostFoundScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? extra; // Contains aiDraft, imagePath, type

  const CreateLostFoundScreen({super.key, this.extra});

  @override
  ConsumerState<CreateLostFoundScreen> createState() => _CreateLostFoundScreenState();
}

class _CreateLostFoundScreenState extends ConsumerState<CreateLostFoundScreen> {
  final _formKey = GlobalKey<FormState>();
  
  PostType _type = PostType.lost;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  
  String? _imagePath;
  bool _isLoading = false;
  bool _isLoadingLocation = false;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    if (widget.extra != null) {
      if (widget.extra!['type'] != null) {
        _type = widget.extra!['type'];
      }
      if (widget.extra!['imagePath'] != null) {
        _imagePath = widget.extra!['imagePath'];
      }
      if (widget.extra!['aiDraft'] != null) {
        final draft = widget.extra!['aiDraft'] as Map<String, dynamic>;
        _titleController.text = draft['title'] ?? '';
        _descController.text = draft['description'] ?? '';
        final tags = draft['tags'] as List<String>?;
        if (tags != null) {
          _tagsController.text = tags.join(', ');
        }
        if (draft['location'] != null) {
          _locationController.text = draft['location'];
        }
        if (draft['latitude'] != null) {
          _latitude = draft['latitude'];
        }
        if (draft['longitude'] != null) {
          _longitude = draft['longitude'];
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final locationService = ref.read(locationServiceProvider);
      final result = await locationService.getCurrentLocationWithAddress();
      setState(() {
        _locationController.text = result.address;
        _latitude = result.latitude;
        _longitude = result.longitude;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final post = LostFoundPost(
        id: const Uuid().v4(),
        authorId: user.uid,
        type: _type,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: ItemCategory.other,
        tags: _tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        locationText: _locationController.text.trim(),
        geo: _latitude != null && _longitude != null 
            ? GeoPoint(_latitude!, _longitude!) 
            : null,
        imageUrls: _imagePath != null ? [_imagePath!] : [],
        status: PostStatus.open,
        dateTime: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await ref.read(reFindRepositoryProvider).createPost(post);
      
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report posted!')),
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
    const primaryRed = Color(0xFFEF2D2D);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Create Report')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_imagePath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(_imagePath!), height: 200, fit: BoxFit.cover),
              ),
              const SizedBox(height: 16),
            ],
          
            SegmentedButton<PostType>(
              segments: const [
                ButtonSegment(value: PostType.lost, label: Text('Lost')),
                ButtonSegment(value: PostType.found, label: Text('Found')),
              ],
              selected: {_type},
              onSelectionChanged: (newSelection) {
                setState(() => _type = newSelection.first);
              },
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Blue Wallet',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                hintText: 'Where did you lose/find it?',
                border: const OutlineInputBorder(),
                suffixIcon: _isLoadingLocation
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.my_location, color: primaryRed),
                        onPressed: _detectLocation,
                        tooltip: 'Detect my location',
                      ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags',
                hintText: 'wallet, blue, leather',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Report', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
