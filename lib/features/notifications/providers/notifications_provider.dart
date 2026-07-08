import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';
import 'package:sacred_app/features/notifications/models/app_notification.dart';

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<AppNotification>>(
  NotificationsNotifier.new,
);

final unreadNotificationsCountProvider = Provider<int>((ref) {
  ref.watch(notificationsProvider);
  return ref.watch(_unreadCountProvider);
});

final _unreadCountProvider = StateProvider<int>((ref) => 0);

class NotificationsNotifier extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() async {
    final authed =
        ref.watch(authStateProvider).valueOrNull?.isAuthenticated == true;
    if (!authed) {
      ref.read(_unreadCountProvider.notifier).state = 0;
      return [];
    }

    ref.listen(authStateProvider, (prev, next) {
      final wasAuthed = prev?.valueOrNull?.isAuthenticated == true;
      final isAuthed = next.valueOrNull?.isAuthenticated == true;
      if (wasAuthed != isAuthed) {
        ref.invalidateSelf();
      }
    });

    return _fetch();
  }

  Future<int> _fetchUnreadCount() async {
    try {
      final res = await ref.read(apiClientProvider).get('/notifications/unread-count');
      final data = res.data;
      if (data is Map<String, dynamic>) {
        return (data['count'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _syncUnreadCount() async {
    final count = await _fetchUnreadCount();
    ref.read(_unreadCountProvider.notifier).state = count;
  }

  Future<List<AppNotification>> _fetch() async {
    try {
      final res = await ref.read(apiClientProvider).get('/notifications');
      final data = res.data;
      if (data is! List) return [];
      final list = data
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
      await _syncUnreadCount();
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> refresh() async {
    try {
      final list = await _fetch();
      state = AsyncData(list);
    } catch (_) {
      state = AsyncData(state.valueOrNull ?? []);
    }
  }

  Future<void> markRead(String id) async {
    await ref.read(apiClientProvider).put('/notifications/$id/read');
    state = AsyncData([
      for (final n in state.valueOrNull ?? [])
        if (n.id == id) n.copyWith(isRead: true) else n,
    ]);
    await _syncUnreadCount();
  }

  Future<void> markReadFromPush(String? id) async {
    if (id == null || id.isEmpty) return;
    try {
      await ref.read(apiClientProvider).put('/notifications/$id/read');
      final current = state.valueOrNull ?? [];
      if (current.any((n) => n.id == id)) {
        state = AsyncData([
          for (final n in current)
            if (n.id == id) n.copyWith(isRead: true) else n,
        ]);
      }
      await _syncUnreadCount();
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    await ref.read(apiClientProvider).put('/notifications/read-all');
    state = AsyncData([
      for (final n in state.valueOrNull ?? []) n.copyWith(isRead: true),
    ]);
    ref.read(_unreadCountProvider.notifier).state = 0;
  }
}
