import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildPage(
        context,
        title: 'LendLink',
        description: 'Borrow or lend small items and cash safely within campus.',
        icon: Icons.handshake,
      ),
      _buildPage(
        context,
        title: 'RoomRadar',
        description: 'Find empty classrooms for group studies or chilling.',
        icon: Icons.meeting_room,
      ),
      _buildPage(
        context,
        title: 'ReFind AI',
        description: 'Lost something? Find it fast with AI-powered image matching.',
        icon: Icons.saved_search,
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: pages,
          ),
          
          // Navigation Bottom Bar
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Skip/Back Button
                TextButton(
                  onPressed: () {
                    if (_currentPage > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      ref.read(onboardingProvider.notifier).completeOnboarding();
                    }
                  },
                  child: Text(_currentPage > 0 ? 'BACK' : 'SKIP'),
                ),

                // Indicator Dots
                Row(
                  children: List.generate(
                    pages.length,
                    (index) => Container(
                      margin: const EdgeInsets.all(4),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? Theme.of(context).primaryColor
                            : Colors.grey.withAlpha(100),
                      ),
                    ),
                  ),
                ),

                // Next/Done Button
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage < pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      ref.read(onboardingProvider.notifier).completeOnboarding();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(_currentPage == pages.length - 1 ? 'GET STARTED' : 'NEXT'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 140, color: Theme.of(context).primaryColor),
          const SizedBox(height: 64),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 100), // Space for bottom buttons
        ],
      ),
    );
  }
}
