import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../data/repositories/lending_repository.dart';
import '../domain/entities/listing.dart';
import '../../auth/presentation/providers/auth_provider.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key});

  @override
  ConsumerState<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  
  // State
  final ListingType _type = ListingType.item;
  String _selectedDuration = '30m';
  
  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController(); // "Optional Note"
  final TextEditingController _locationController = TextEditingController()..text = 'Main Library, Level 2';
  
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleController.text.isEmpty) return; // Basic validation
    
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      // Append duration to description since we don't have a dedicated field yet
      final fullDescription = "${_descController.text.trim()}\n\nDuration: $_selectedDuration";

      final listing = Listing(
        id: const Uuid().v4(),
        ownerId: user.uid,
        type: _type,
        title: _titleController.text.trim(),
        description: fullDescription.trim(),
        category: ListingCategory.other,
        amount: null, // Money requests disabled in this UI flow for now matches "Borrow" request
        locationArea: _locationController.text.trim(),
        status: ListingStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(lendingRepositoryProvider).createListing(listing);
      
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request posted successfully!')),
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

  Widget _timeChip(String label) {
    final bool selected = _selectedDuration == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedDuration = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEF2D2D) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Post a Request',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: const BackButton(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              const Text(
                'Request an Item',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Borrow what you need from your campus community.',
                style: TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 24),

              /// ITEM NAME
              const Text(
                'What do you need?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'e.g. HDMI Cable, Calculator',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search), // Mimic search "look"
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// DURATION
              const Text(
                'How long?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: [
                  _timeChip('30m'),
                  _timeChip('1h'),
                  _timeChip('2h'),
                  _timeChip('1d'),
                  _timeChip('Custom'),
                ],
              ),

              const SizedBox(height: 24),

              /// NOTE
              const Text(
                'Optional note',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "e.g. I'm in Building 3, Room 402. Needed urgently.",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              /// LOCATION CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFFEF2D2D)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pickup near', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(
                            _locationController.text.isEmpty ? 'Select Location' : _locationController.text,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        // Keep simple for redesign demo
                        _locationController.text = "Library";
                        setState((){});
                      },
                      child: const Text(
                        'Change',
                        style: TextStyle(
                          color: Color(0xFFEF2D2D),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 40),

              /// POST BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF2D2D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Post Request',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, color: Colors.white),
                        ],
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
