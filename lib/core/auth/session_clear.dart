import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/auth/tier_provider.dart';
import 'package:sacred_app/core/providers/monk_categories_provider.dart';
import 'package:sacred_app/features/admin/providers/admin_providers.dart';
import 'package:sacred_app/features/booking/providers/booking_draft_provider.dart';
import 'package:sacred_app/features/booking/providers/my_bookings_provider.dart';
import 'package:sacred_app/features/home/home_screen.dart';
import 'package:sacred_app/features/home/providers/monks_provider.dart';
import 'package:sacred_app/features/home/providers/search_provider.dart';
import 'package:sacred_app/features/messenger/providers/messenger_provider.dart';
import 'package:sacred_app/features/monk_dash/providers/monk_dashboard_provider.dart';
import 'package:sacred_app/features/monk_dash/providers/monk_earnings_provider.dart';
import 'package:sacred_app/features/monk_dash/providers/monk_profile_edit_provider.dart';
import 'package:sacred_app/features/monk_dash/providers/monk_schedule_manager_provider.dart';
import 'package:sacred_app/features/monk_profile/providers/monk_profile_provider.dart';
import 'package:sacred_app/features/notifications/providers/notifications_provider.dart';
import 'package:sacred_app/features/payment/providers/booking_payment_provider.dart';
import 'package:sacred_app/features/profile/providers/user_profile_provider.dart';
import 'package:sacred_app/features/shop/providers/shop_providers.dart';
import 'package:sacred_app/features/shop/shop_payment_screen.dart';
import 'package:sacred_app/features/video_call/providers/incoming_call_provider.dart';

/// Drop cached user data when logging out or switching accounts.
void clearSessionState(ProviderContainer container) {
  container.read(incomingCallProvider.notifier).state = null;

  container.read(bookingDraftProvider.notifier).reset('');
  container.read(bookingStepProvider.notifier).state = 0;
  container.read(bookingSubmittingProvider.notifier).state = false;
  container.read(cartProvider.notifier).clear();

  container.read(monkCategoryFilterProvider.notifier).state = 'Бүгд';
  container.read(monkSortFilterProvider.notifier).state = 'Үнэлгээ';
  container.read(monkSearchQueryProvider.notifier).state = '';
  container.read(favoriteMonksProvider.notifier).state = {};
  container.read(searchInputProvider.notifier).state = '';
  container.read(debouncedSearchProvider.notifier).state = '';
  container.read(shopCategoryProvider.notifier).state = 'Бүгд';
  container.read(adminMonkFilterProvider.notifier).state = 'all';
  container.read(adminBookingFilterProvider.notifier).state = 'all';
  container.read(adminShopOrderFilterProvider.notifier).state = 'all';

  container.invalidate(userProfileProvider);
  container.invalidate(myBookingsProvider);
  container.invalidate(bookingPaymentProvider);
  container.invalidate(myOrdersProvider);
  container.invalidate(conversationsProvider);
  container.invalidate(messagesProvider);
  container.invalidate(monkDashboardProvider);
  container.invalidate(monkAvailabilityProvider);
  container.invalidate(monkBookingsProvider);
  container.invalidate(monkProfileEditProvider);
  container.invalidate(monkEarningsProvider);
  container.invalidate(monkScheduleManagerProvider);
  container.invalidate(notificationsProvider);
  container.invalidate(tierCacheProvider);
  container.invalidate(monksNotifierProvider);
  container.invalidate(recommendedMonksProvider);
  container.invalidate(monkDetailProvider);
  container.invalidate(monkServicesProvider);
  container.invalidate(monkScheduleProvider);
  container.invalidate(monkReviewsProvider);
  container.invalidate(adminDashboardProvider);
  container.invalidate(adminMonksProvider);
  container.invalidate(adminMonkDetailProvider);
  container.invalidate(adminUsersProvider);
  container.invalidate(adminBookingsProvider);
  container.invalidate(adminFinanceProvider);
  container.invalidate(adminProductsProvider);
  container.invalidate(adminOrdersProvider);
  container.invalidate(adminCategoriesProvider);
  container.invalidate(productsProvider);
  container.invalidate(productDetailProvider);
  container.invalidate(shopOrderPaymentProvider);
}

/// AuthNotifier-ээс дуудахад circular dependency-г зайлсхийнэ.
void scheduleSessionClear(Ref ref) {
  final container = ref.container;
  Future(() => clearSessionState(container));
}

/// Refresh public monk/product lists after profile image changes.
void invalidatePublicMonkCaches(WidgetRef ref) {
  ref.invalidate(monksNotifierProvider);
  ref.invalidate(recommendedMonksProvider);
  ref.invalidate(monkDetailProvider);
}
