import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../domain/entities/listing.dart';
import '../../../core/services/location_service.dart';

class BorrowDetailsScreen extends ConsumerStatefulWidget {
  final Listing listing;

  const BorrowDetailsScreen({super.key, required this.listing});

  @override
  ConsumerState<BorrowDetailsScreen> createState() => _BorrowDetailsScreenState();
}

class _BorrowDetailsScreenState extends ConsumerState<BorrowDetailsScreen> {
  String? _detectedLocation;
  double? _latitude;
  double? _longitude;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final locationService = ref.read(locationServiceProvider);
      final result = await locationService.getCurrentLocationWithAddress();
      if (mounted) {
        setState(() {
          _detectedLocation = result.address;
          _latitude = result.latitude;
          _longitude = result.longitude;
        });
      }
    } catch (e) {
      // Silently fail - use listing location as fallback
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _openMaps() async {
    final lat = _latitude;
    final lng = _longitude;
    
    if (lat != null && lng != null) {
      final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryRed = Color(0xFFEF2D2D);
    final listing = widget.listing;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Borrow Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Badge
                const Text(
                  'ACTIVE BORROW',
                  style: TextStyle(
                    color: primaryRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  listing.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),

                // Subtitle
                Text(
                  listing.description.length > 50 
                      ? '${listing.description.substring(0, 50)}...' 
                      : listing.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),

                // Status Chips
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: primaryRed.withAlpha(25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inventory_2, size: 16, color: primaryRed),
                          const SizedBox(width: 6),
                          Text(
                            'Borrowed',
                            style: TextStyle(
                              color: primaryRed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Due in 3 days',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Participants Section
                const Text(
                  'Participants',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Owner
                _ParticipantTile(
                  name: 'Item Owner',
                  role: 'Lender (Owner)',
                  avatarColor: Colors.orange,
                  trailing: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: primaryRed,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.chat_bubble, color: Colors.white, size: 16),
                  ),
                ),
                const SizedBox(height: 12),

                // Borrower
                _ParticipantTile(
                  name: 'You',
                  role: 'Borrower (You)',
                  avatarColor: Colors.blue,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('ME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                const SizedBox(height: 32),

                // Timeline Section
                const Text(
                  'Timeline',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Borrowed Date
                _TimelineItem(
                  icon: Icons.circle,
                  iconColor: primaryRed,
                  title: 'Borrowed on ${_formatDate(listing.createdAt)}',
                  subtitle: 'Handover completed at ${listing.locationArea}',
                  isCompleted: true,
                ),
                const SizedBox(height: 16),

                // Due Date
                _TimelineItem(
                  icon: Icons.radio_button_unchecked,
                  iconColor: primaryRed,
                  title: 'Due ${_formatDueDate(listing.dueDate ?? listing.createdAt.add(const Duration(days: 3)))}',
                  subtitle: 'Expected return at ${listing.locationArea}',
                  isCompleted: false,
                ),
                const SizedBox(height: 32),

                // Handover Location
                const Text(
                  'Handover Location',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Map Container
                GestureDetector(
                  onTap: _latitude != null ? _openMaps : null,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: _isLoadingLocation
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : _latitude != null && _longitude != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Static map image from OpenStreetMap
                                    Image.network(
                                      'https://staticmap.openstreetmap.de/staticmap.php?center=$_latitude,$_longitude&zoom=15&size=600x300&markers=$_latitude,$_longitude,red-pushpin',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return _buildMapPlaceholder(listing.locationArea);
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                    ),
                                    // Overlay with location text
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              Colors.black.withAlpha(180),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.location_on, color: Colors.white, size: 16),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                _detectedLocation ?? listing.locationArea,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const Icon(Icons.open_in_new, color: Colors.white, size: 14),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : _buildMapPlaceholder(listing.locationArea),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item marked as returned!')),
                );
                context.pop();
              },
              icon: const Icon(Icons.check_circle),
              label: const Text(
                'Mark as Returned',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder(String locationArea) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            locationArea,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  static String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now).inDays;
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day} ($diff days left)';
  }
}

class _ParticipantTile extends StatelessWidget {
  final String name;
  final String role;
  final Color avatarColor;
  final Widget trailing;

  const _ParticipantTile({
    required this.name,
    required this.role,
    required this.avatarColor,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: avatarColor.withAlpha(50),
          child: Icon(Icons.person, color: avatarColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                role,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ),
        trailing,
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isCompleted;

  const _TimelineItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? Colors.black : iconColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
