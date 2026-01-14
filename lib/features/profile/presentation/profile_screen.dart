import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vit_chennai_student_utility/core/data/data_seeder.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: ListView(
        children: [
          // User Info
          UserAccountsDrawerHeader(
            accountName: Text(user?.displayName ?? 'Student'),
            accountEmail: Text(user?.email ?? 'guest@vit.ac.in'),
            currentAccountPicture: CircleAvatar(
              backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null ? const Icon(Icons.person, size: 32) : null,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            otherAccountsPictures: [
                IconButton(
                    onPressed: () {
                        // Edit profile logic
                    }, 
                    icon: const Icon(Icons.edit)
                )
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Theme Settings
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('App Theme'),
            trailing: DropdownButton<ThemeMode>(
              value: themeMode,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
              onChanged: (mode) {
                if (mode != null) {
                  ref.read(themeModeProvider.notifier).setTheme(mode);
                }
              },
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            trailing: Switch(value: true, onChanged: (v) {}), // Mock
          ),
          
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline),
            title: const Text('Messages'),
            onTap: () {
              context.push('/chats');
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('My Listings'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('My Activity'),
            onTap: () {},
          ),
          
          const Divider(),
           ListTile(
            leading: const Icon(Icons.cloud_upload),
            title: const Text('Seed Demo Data'),
            subtitle: const Text('Dev Only - Adds sample posts'),
            onTap: () async {
               await ref.read(dataSeederProvider).seedData();
               if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demo data seeded!')));
               }
            },
          ),
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              ref.read(authServiceProvider).signOut();
              // Router will redirect
            },
          ),
        ],
      ),
    );
  }
}
