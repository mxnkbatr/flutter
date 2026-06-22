import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/notifications/notification_prefs.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/shared/widgets/ios_grouped_section.dart';
import 'package:sacred_app/shared/widgets/premium_layered_scaffold.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(notificationPrefsProvider);

    return PremiumLayeredScaffold(
      title: 'Мэдэгдлийн тохиргоо',
      showBackButton: true,
      useNativeNavBar: true,
      body: prefsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.goldPrime),
        ),
        error: (_, __) => const Center(child: Text('Тохиргоо ачаалахад алдаа гарлаа')),
        data: (prefs) => Padding(
          padding: const EdgeInsets.fromLTRB(0, 24, 0, 32),
          child: Column(
            children: [
              IosGroupedSection(
                title: 'Захиалга',
                children: [
                  SwitchListTile.adaptive(
                    title: const Text('Захиалгын шинэчлэл'),
                    subtitle: const Text(
                      'Батлагдсан, цуцлагдсан мэдэгдэл',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: prefs.booking,
                    activeColor: AppColors.goldPrime,
                    onChanged: (v) => ref
                        .read(notificationPrefsProvider.notifier)
                        .savePrefs(prefs.copyWith(booking: v)),
                  ),
                  SwitchListTile.adaptive(
                    title: const Text('Захиалгын сануулагч'),
                    subtitle: const Text(
                      'Уулзалтын цаг ойртоход сануулах',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: prefs.bookingReminder,
                    activeColor: AppColors.goldPrime,
                    onChanged: (v) => ref
                        .read(notificationPrefsProvider.notifier)
                        .savePrefs(prefs.copyWith(bookingReminder: v)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              IosGroupedSection(
                title: 'Харилцаа',
                children: [
                  SwitchListTile.adaptive(
                    title: const Text('Шинэ мессеж'),
                    value: prefs.message,
                    activeColor: AppColors.goldPrime,
                    onChanged: (v) => ref
                        .read(notificationPrefsProvider.notifier)
                        .savePrefs(prefs.copyWith(message: v)),
                  ),
                  SwitchListTile.adaptive(
                    title: const Text('Ирж буй дуудлага'),
                    subtitle: const Text(
                      'Видео дуудлагын мэдэгдэл',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: prefs.call,
                    activeColor: AppColors.goldPrime,
                    onChanged: (v) => ref
                        .read(notificationPrefsProvider.notifier)
                        .savePrefs(prefs.copyWith(call: v)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              IosGroupedSection(
                title: 'Лавлах',
                children: [
                  SwitchListTile.adaptive(
                    title: const Text('Үйлчилгээний нөхцөл'),
                    subtitle: const Text(
                      'Нөхцөл, бодлого шинэчлэгдэхэд мэдэгдэх',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: prefs.legal,
                    activeColor: AppColors.goldPrime,
                    onChanged: (v) => ref
                        .read(notificationPrefsProvider.notifier)
                        .savePrefs(prefs.copyWith(legal: v)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              IosGroupedSection(
                title: 'Бусад',
                children: [
                  SwitchListTile.adaptive(
                    title: const Text('Шинэ лам, санал'),
                    subtitle: const Text(
                      'Шинэ лам, хямдрал, тусгай саналууд',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: prefs.promo,
                    activeColor: AppColors.goldPrime,
                    onChanged: (v) => ref
                        .read(notificationPrefsProvider.notifier)
                        .savePrefs(prefs.copyWith(promo: v)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
