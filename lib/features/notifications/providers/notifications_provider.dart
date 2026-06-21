import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/features/notifications/models/app_notification.dart';

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<AppNotification>>(
  (ref) => NotificationsNotifier(),
);

final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref
      .watch(notificationsProvider)
      .where((n) => !n.isRead)
      .length;
});

class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  NotificationsNotifier() : super(_seed);

  static final _seed = [
    AppNotification(
      id: '1',
      title: 'Захиалга баталгаажлаа',
      body: 'Таны ерөөлийн цаг баталгаажсан',
      type: AppNotificationType.booking,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    AppNotification(
      id: '2',
      title: 'Шинэ мессеж',
      body: 'Батбаяр лам танд бичсэн',
      type: AppNotificationType.message,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
    ),
    AppNotification(
      id: '3',
      title: 'Premium санал',
      body: 'Шинэ багцын хямдрал эхэллээ',
      type: AppNotificationType.promo,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  void markRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ];
  }

  void markAllRead() {
    state = [for (final n in state) n.copyWith(isRead: true)];
  }
}
