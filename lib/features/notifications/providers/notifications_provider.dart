import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';
import 'package:sacred_app/features/notifications/models/app_notification.dart';

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<AppNotification>>(
  NotificationsNotifier.new,
);

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final async = ref.watch(notificationsProvider);
  return async.maybeWhen(
    data: (list) => list.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});

class NotificationsNotifier extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() async {
    final authed = ref.watch(authStateProvider).valueOrNull?.isAuthenticated == true;
    if (!authed) return [];

    ref.listen(authStateProvider, (prev, next) {
      final wasAuthed = prev?.valueOrNull?.isAuthenticated == true;
      final isAuthed = next.valueOrNull?.isAuthenticated == true;
      if (wasAuthed != isAuthed) {
        ref.invalidateSelf();
      }
    });

    return _fetch();
  }

  Future<List<AppNotification>> _fetch() async {
    final res = await ref.read(apiClientProvider).get('/notifications');
    final data = res.data;
    if (data is! List) return [];
    return data
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _fetch());
  }

  Future<void> markRead(String id) async {
    await ref.read(apiClientProvider).put('/notifications/$id/read');
    state = AsyncData([
      for (final n in state.valueOrNull ?? [])
        if (n.id == id) n.copyWith(isRead: true) else n,
    ]);
  }

  Future<void> markAllRead() async {
    await ref.read(apiClientProvider).put('/notifications/read-all');
    state = AsyncData([
      for (final n in state.valueOrNull ?? []) n.copyWith(isRead: true),
    ]);
  }
}
