import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vit_chennai_student_utility/features/home/presentation/home_screen.dart';
import 'package:vit_chennai_student_utility/features/lending/presentation/lending_screen.dart';
import 'package:vit_chennai_student_utility/features/lending/presentation/borrow_details_screen.dart';
import 'package:vit_chennai_student_utility/features/lending/domain/entities/listing.dart';
import 'package:vit_chennai_student_utility/features/locator/presentation/locator_screen.dart';
import 'package:vit_chennai_student_utility/features/refind/presentation/refind_screen.dart';
import 'package:vit_chennai_student_utility/features/profile/presentation/profile_screen.dart';
import 'package:vit_chennai_student_utility/features/auth/presentation/login_screen.dart';
import 'package:vit_chennai_student_utility/features/auth/presentation/onboarding_screen.dart';
import 'package:vit_chennai_student_utility/features/auth/presentation/providers/auth_provider.dart';
import 'package:vit_chennai_student_utility/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:vit_chennai_student_utility/features/auth/presentation/providers/onboarding_provider.dart';
import 'package:vit_chennai_student_utility/features/lending/presentation/create_listing_screen.dart';
import 'package:vit_chennai_student_utility/features/locator/presentation/create_class_post_screen.dart';
import 'package:vit_chennai_student_utility/features/refind/presentation/create_refind_post_screen.dart';
import 'package:vit_chennai_student_utility/features/chat/presentation/chat_list_screen.dart';
import 'package:vit_chennai_student_utility/features/chat/presentation/chat_screen.dart';
import 'package:vit_chennai_student_utility/features/chat/domain/entities/chat_room.dart';


final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final seenOnboarding = ref.watch(onboardingProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/lending',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // If onboarding not seen, go to onboarding
      if (!seenOnboarding) {
         return '/onboarding';
      }

      final authService = ref.read(authServiceProvider);
      final isAuthenticated = authState.asData?.value != null || 
          (authService is MockAuthRepository && authService.mockLoggedIn);

      final isLoggingIn = state.uri.toString() == '/login';
      final isOnboarding = state.uri.toString() == '/onboarding';

      if (authState.isLoading) return null;

      // If not authenticated, go to login
      if (!isAuthenticated) {
        return isLoggingIn ? null : '/login';
      }

      // If authenticated and trying to go to login or onboarding, go to lending
      if (isLoggingIn || isOnboarding) {
        return '/lending';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/chats',
        builder: (context, state) => const ChatListScreen(),
        routes: [
           GoRoute(
            path: ':id',
            builder: (context, state) {
              final roomId = state.pathParameters['id']!;
              final chatRoom = state.extra as ChatRoom?;
              return ChatScreen(roomId: roomId, chatRoom: chatRoom);
            },
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/lending',
                builder: (context, state) => const LendingScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    parentNavigatorKey: rootNavigatorKey, // We need to define this key to hide navbar
                    builder: (context, state) => const CreateListingScreen(),
                  ),
                  GoRoute(
                    path: 'details',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final listing = state.extra as Listing;
                      return BorrowDetailsScreen(listing: listing);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/locator',
                builder: (context, state) => const LocatorScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const CreateClassPostScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/refind',
                builder: (context, state) => const ReFindScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>?;
                        return CreateLostFoundScreen(extra: extra);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
