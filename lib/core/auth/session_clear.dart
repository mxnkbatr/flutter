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
void clearSessionState(Ref ref) {
  ref.read(incomingCallProvider.notifier).state = null;

  ref.read(bookingDraftProvider.notifier).reset('');
  ref.read(bookingStepProvider.notifier).state = 0;
  ref.read(bookingSubmittingProvider.notifier).state = false;
  ref.read(cartProvider.notifier).clear();

  ref.read(monkCategoryFilterProvider.notifier).state = 'Бүгд';
  ref.read(monkSortFilterProvider.notifier).state = 'Үнэлгээ';
  ref.read(monkSearchQueryProvider.notifier).state = '';
  ref.read(favoriteMonksProvider.notifier).state = {};
  ref.read(searchInputProvider.notifier).state = '';
  ref.read(debouncedSearchProvider.notifier).state = '';
  ref.read(shopCategoryProvider.notifier).state = 'Бүгд';
  ref.read(adminMonkFilterProvider.notifier).state = 'all';
  ref.read(adminBookingFilterProvider.notifier).state = 'all';
  ref.read(adminShopOrderFilterProvider.notifier).state = 'all';

  ref.invalidate(userProfileProvider);
  ref.invalidate(myBookingsProvider);
  ref.invalidate(bookingPaymentProvider);
  ref.invalidate(myOrdersProvider);
  ref.invalidate(conversationsProvider);
  ref.invalidate(messagesProvider);
  ref.invalidate(monkDashboardProvider);
  ref.invalidate(monkAvailabilityProvider);
  ref.invalidate(monkBookingsProvider);
  ref.invalidate(monkProfileEditProvider);
  ref.invalidate(monkEarningsProvider);
  ref.invalidate(monkScheduleManagerProvider);
  ref.invalidate(notificationsProvider);
  ref.invalidate(tierCacheProvider);
  ref.invalidate(monksNotifierProvider);
  ref.invalidate(recommendedMonksProvider);
  ref.invalidate(monkDetailProvider);
  ref.invalidate(monkServicesProvider);
  ref.invalidate(monkScheduleProvider);
  ref.invalidate(monkReviewsProvider);
  ref.invalidate(adminDashboardProvider);
  ref.invalidate(adminMonksProvider);
  ref.invalidate(adminMonkDetailProvider);
  ref.invalidate(adminUsersProvider);
  ref.invalidate(adminBookingsProvider);
  ref.invalidate(adminFinanceProvider);
  ref.invalidate(adminProductsProvider);
  ref.invalidate(adminOrdersProvider);
  ref.invalidate(adminCategoriesProvider);
  ref.invalidate(productsProvider);
  ref.invalidate(productDetailProvider);
  ref.invalidate(shopOrderPaymentProvider);
}

/// AuthNotifier-ээс дуудахад circular dependency-г зайлсхийнэ.
void scheduleSessionClear(Ref ref) {
  Future.microtask(() => clearSessionState(ref));
}

/// Refresh public monk/product lists after profile image changes.
void invalidatePublicMonkCaches(WidgetRef ref) {
  ref.invalidate(monksNotifierProvider);
  ref.invalidate(recommendedMonksProvider);
  ref.invalidate(monkDetailProvider);
}
