import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/repositories/lending_repository.dart';
import '../domain/entities/listing.dart';
import '../../../../core/presentation/widgets/empty_state_widget.dart';

class LendingScreen extends ConsumerStatefulWidget {
  const LendingScreen({super.key});

  @override
  ConsumerState<LendingScreen> createState() => _LendingScreenState();
}

class _LendingScreenState extends ConsumerState<LendingScreen> {
  // Filter state
  ListingType? _selectedType;
  String _activeFilter = 'all'; // 'all', 'nearby', 'urgent'
  // ListingCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(listingsFeedProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F5),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header (Location + Profile)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Color(0xFFEF2D2D)),
                  const SizedBox(width: 8),
                  Text(
                    'VIT Chennai',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {},
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => context.go('/profile'),
                    child: const CircleAvatar(
                      backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'), // Placeholder
                    ),
                  ),
                ],
              ),
            ),
            
            // Search & Filter Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Filter Chips
                  Row(
                    children: [
                      _FilterPill(
                        label: 'All Requests',
                        isSelected: _activeFilter == 'all',
                        onTap: () => setState(() => _activeFilter = 'all'),
                      ),
                      const SizedBox(width: 12),
                      _FilterPill(
                        label: 'Nearby',
                        isSelected: _activeFilter == 'nearby',
                        onTap: () => setState(() => _activeFilter = 'nearby'),
                      ),
                      const SizedBox(width: 12),
                      _FilterPill(
                        label: 'Urgent',
                        isSelected: _activeFilter == 'urgent',
                        onTap: () => setState(() => _activeFilter = 'urgent'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for items...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ],
              ),
            ),

            // Feed
            Expanded(
              child: listingsAsync.when(
                data: (listings) {
                  final filteredListings = listings.where((l) {
                    if (_selectedType != null && l.type != _selectedType) return false;
                    return true;
                  }).toList();

                  if (filteredListings.isEmpty) {
                    return const EmptyStateWidget(
                      message: 'No active requests',
                      subMessage: 'Check back later or post a request!',
                      icon: Icons.inventory_2_outlined,
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    itemCount: filteredListings.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final listing = filteredListings[index];
                      return _ListingCard(listing: listing);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/lending/create'),
        backgroundColor: const Color(0xFFEF2D2D),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterPill({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEF2D2D) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFFEF2D2D).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final Listing listing;

  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    // Generate a placeholder gradient based on title hash for visual variety
    final gradientColors = [
      const Color(0xFF2C3E50),
      const Color(0xFF000000),
    ];

    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Image (if any) or Gradient
          // For now, we use gradient. If we had images:
          // Positioned.fill(child: Image.network(imageUrl, fit: BoxFit.cover)),
          
          // Badge
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                listing.type == ListingType.money ? 'URGENT' : 'ESSENTIALS',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Title
                Text(
                  listing.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // Subtitle/Location
                Text(
                  listing.locationArea,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Footer: Distance + Button
                Row(
                  children: [
                    const Icon(Icons.near_me, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    const Text(
                      '200m away', // Placeholder distance
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const Spacer(),
                    
                    // Accept Button
                    ElevatedButton(
                      onPressed: () {
                        context.push('/lending/details', extra: listing);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF2D2D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Accept',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
