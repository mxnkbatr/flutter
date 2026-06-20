import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/shared/widgets/ios_grouped_section.dart';
import 'package:sacred_app/shared/widgets/ios_large_title_scaffold.dart';

const _kBookingNotif = 'notif_booking_updates';
const _kMessageNotif = 'notif_messages';
const _kPromoNotif = 'notif_promotions';
const _kCallNotif = 'notif_incoming_calls';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _booking = true;
  bool _message = true;
  bool _promo = true;
  bool _call = true;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _booking = prefs.getBool(_kBookingNotif) ?? true;
      _message = prefs.getBool(_kMessageNotif) ?? true;
      _promo = prefs.getBool(_kPromoNotif) ?? true;
      _call = prefs.getBool(_kCallNotif) ?? true;
      _loaded = true;
    });
  }

  Future<void> _set(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.goldPrime),
        ),
      );
    }

    return IosLargeTitleScaffold(
      title: 'Мэдэгдэл',
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
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
                  value: _booking,
                  activeColor: AppColors.goldPrime,
                  onChanged: (v) {
                    setState(() => _booking = v);
                    _set(_kBookingNotif, v);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            IosGroupedSection(
              title: 'Харилцаа',
              children: [
                SwitchListTile.adaptive(
                  title: const Text('Шинэ мессеж'),
                  value: _message,
                  activeColor: AppColors.goldPrime,
                  onChanged: (v) {
                    setState(() => _message = v);
                    _set(_kMessageNotif, v);
                  },
                ),
                SwitchListTile.adaptive(
                  title: const Text('Ирж буй дуудлага'),
                  subtitle: const Text(
                    'Видео дуудлагын мэдэгдэл',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _call,
                  activeColor: AppColors.goldPrime,
                  onChanged: (v) {
                    setState(() => _call = v);
                    _set(_kCallNotif, v);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            IosGroupedSection(
              title: 'Бусад',
              children: [
                SwitchListTile.adaptive(
                  title: const Text('Урамшуулал, мэдээ'),
                  subtitle: const Text(
                    'Шинэ лам, хямдрал, тусгай саналууд',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _promo,
                  activeColor: AppColors.goldPrime,
                  onChanged: (v) {
                    setState(() => _promo = v);
                    _set(_kPromoNotif, v);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
