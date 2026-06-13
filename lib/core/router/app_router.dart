import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';
import 'package:sacred_app/features/admin/admin_bookings_screen.dart';
import 'package:sacred_app/features/admin/admin_dashboard_screen.dart';
import 'package:sacred_app/features/admin/admin_finance_screen.dart';
import 'package:sacred_app/features/admin/admin_monks_screen.dart';
import 'package:sacred_app/features/admin/screens/admin_add_monk_screen.dart';
import 'package:sacred_app/features/admin/screens/admin_edit_monk_screen.dart';
import 'package:sacred_app/features/admin/admin_shell.dart';
import 'package:sacred_app/features/admin/admin_users_screen.dart';
import 'package:sacred_app/features/auth/presentation/login_screen.dart';
import 'package:sacred_app/features/auth/presentation/onboarding_screen.dart';
import 'package:sacred_app/features/auth/presentation/signup_screen.dart';
import 'package:sacred_app/features/booking/booking_flow_screen.dart';
import 'package:sacred_app/features/booking/my_bookings_screen.dart';
import 'package:sacred_app/features/home/home_screen.dart';
import 'package:sacred_app/features/home/search_screen.dart';
import 'package:sacred_app/features/messenger/chat_screen.dart';
import 'package:sacred_app/features/messenger/messenger_screen.dart';
import 'package:sacred_app/features/monk_dash/monk_dashboard_screen.dart';
import 'package:sacred_app/features/monk_dash/monk_messenger_screen.dart';
import 'package:sacred_app/features/monk_profile/monk_profile_screen.dart';
import 'package:sacred_app/features/payment/models/qpay_data.dart';
import 'package:sacred_app/features/payment/payment_screen.dart';
import 'package:sacred_app/features/payment/payment_success_screen.dart';
import 'package:sacred_app/features/admin/screens/admin_products_screen.dart';
import 'package:sacred_app/features/profile/presentation/profile_screen.dart';
import 'package:sacred_app/features/shop/cart_screen.dart';
import 'package:sacred_app/features/shop/shop_orders_screen.dart';
import 'package:sacred_app/features/shop/shop_product_detail_screen.dart';
import 'package:sacred_app/features/shop/shop_screen.dart';
import 'package:sacred_app/features/splash/presentation/splash_screen.dart';
import 'package:sacred_app/features/subscription/subscription_screen.dart';
import 'package:sacred_app/features/video_call/video_call_screen.dart';
import 'package:sacred_app/shared/shells/client_shell.dart';
import 'package:sacred_app/shared/shells/monk_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authAsync = ref.watch(authStateProvider);
  final auth = authAsync.valueOrNull ?? const AuthState();

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _RouterRefresh(ref),
    redirect: (context, state) {
      final isLoggedIn = auth.isAuthenticated;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isOnboarding = state.matchedLocation == '/onboarding';
      final isSplash = state.matchedLocation == '/splash';

      final isPublicRoute = isSplash || isOnboarding || isAuthRoute;
      if (authAsync.isLoading &&
          authAsync.valueOrNull == null &&
          !isPublicRoute) {
        return '/splash';
      }

      if (isSplash || isOnboarding) return null;

      if (!isLoggedIn && !isAuthRoute) return '/auth/login';

      if (isLoggedIn && isAuthRoute) {
        return switch (auth.role) {
          'monk' => '/monk/dashboard',
          'admin' => '/admin/dashboard',
          _ => '/home',
        };
      }

      if (isLoggedIn) {
        return _guardRole(state.matchedLocation, auth.role);
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/messenger/:id',
        builder: (context, state) => ChatScreen(
          conversationId: state.pathParameters['id']!,
          title: Uri.decodeComponent(
            state.uri.queryParameters['title'] ?? 'Чат',
          ),
        ),
      ),
      GoRoute(
        path: '/payment/:bookingId',
        builder: (context, state) {
          final extra = state.extra;
          return PaymentScreen(
            bookingId: state.pathParameters['bookingId']!,
            qpayData: extra is QPayData ? extra : null,
            initialMethodTab: extra is int ? extra : 0,
          );
        },
        routes: [
          GoRoute(
            path: 'success',
            builder: (context, state) => PaymentSuccessScreen(
              args: state.extra as PaymentSuccessArgs,
            ),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => ClientShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/monks/:id',
            builder: (context, state) =>
                MonkProfileScreen(monkId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/booking/:monkId',
            builder: (context, state) => BookingFlowScreen(
              monkId: state.pathParameters['monkId']!,
              initialServiceId: state.uri.queryParameters['serviceId'],
              initialDate: state.uri.queryParameters['date'],
              initialSlot: state.uri.queryParameters['slot'],
            ),
          ),
          GoRoute(
            path: '/call/:bookingId',
            builder: (context, state) {
              final auth = ref.read(authStateProvider).valueOrNull;
              final role = state.uri.queryParameters['role'] ??
                  auth?.role ??
                  'client';
              return VideoCallScreen(
                bookingId: state.pathParameters['bookingId']!,
                role: role,
              );
            },
          ),
          GoRoute(
            path: '/bookings',
            builder: (context, state) => const MyBookingsScreen(),
          ),
          GoRoute(
            path: '/shop',
            builder: (context, state) => const ShopScreen(),
            routes: [
              GoRoute(
                path: 'cart',
                builder: (context, state) => const CartScreen(),
              ),
              GoRoute(
                path: 'orders',
                builder: (context, state) => const ShopOrdersScreen(),
              ),
              GoRoute(
                path: 'product/:id',
                builder: (context, state) => ShopProductDetailScreen(
                  productId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/messenger',
            builder: (context, state) => const MessengerScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/subscription',
            builder: (context, state) => const SubscriptionScreen(),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => MonkShell(child: child),
        routes: [
          GoRoute(
            path: '/monk/dashboard',
            builder: (context, state) {
              final tab =
                  int.tryParse(state.uri.queryParameters['tab'] ?? '2') ?? 2;
              return MonkDashboardScreen(initialTab: tab);
            },
          ),
          GoRoute(
            path: '/monk/schedule',
            redirect: (_, __) => '/monk/dashboard?tab=1',
          ),
          GoRoute(
            path: '/monk/bookings',
            redirect: (_, __) => '/monk/dashboard?tab=2',
          ),
          GoRoute(
            path: '/monk/earnings',
            redirect: (_, __) => '/monk/dashboard?tab=3',
          ),
          GoRoute(
            path: '/monk/messenger',
            builder: (context, state) => const MonkMessengerScreen(),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/admin/dashboard',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: '/admin/monks',
            builder: (context, state) => const AdminMonksScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AdminAddMonkScreen(),
              ),
              GoRoute(
                path: 'edit/:monkId',
                builder: (context, state) => AdminEditMonkScreen(
                  monkId: state.pathParameters['monkId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/admin/users',
            builder: (context, state) => const AdminUsersScreen(),
          ),
          GoRoute(
            path: '/admin/bookings',
            builder: (context, state) => const AdminBookingsScreen(),
          ),
          GoRoute(
            path: '/admin/finance',
            builder: (context, state) => const AdminFinanceScreen(),
          ),
          GoRoute(
            path: '/admin/products',
            builder: (context, state) => const AdminProductsScreen(),
          ),
        ],
      ),
    ],
  );
});

String? _guardRole(String location, String? role) {
  final isClientRoute = location == '/home' ||
      location.startsWith('/monks') ||
      location.startsWith('/booking') ||
      location.startsWith('/payment') ||
      location.startsWith('/call') ||
      location.startsWith('/bookings') ||
      location.startsWith('/shop') ||
      location.startsWith('/messenger') ||
      location.startsWith('/profile') ||
      location.startsWith('/subscription');

  if (role == 'monk' &&
      (isClientRoute || location.startsWith('/admin')) &&
      !location.startsWith('/payment') &&
      !location.startsWith('/call')) {
    return '/monk/dashboard';
  }
  if (role == 'admin' &&
      (isClientRoute || location.startsWith('/monk'))) {
    return '/admin/dashboard';
  }
  // `/monk/...` = monk dashboard; `/monks/...` = client monk profile (must not match)
  if (role != 'monk' &&
      role != 'admin' &&
      (location.startsWith('/monk/') || location.startsWith('/admin'))) {
    return '/home';
  }
  return null;
}

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(this._ref) {
    _ref.listen(authStateProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}
