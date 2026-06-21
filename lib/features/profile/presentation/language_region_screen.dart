import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/theme/minimal_style.dart';
import 'package:sacred_app/shared/widgets/premium_layered_scaffold.dart';

const _kAppLocale = 'app_locale';

class LanguageRegionScreen extends StatefulWidget {
  const LanguageRegionScreen({super.key});

  @override
  State<LanguageRegionScreen> createState() => _LanguageRegionScreenState();
}

class _LanguageRegionScreenState extends State<LanguageRegionScreen> {
  String _locale = 'mn';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _locale = prefs.getString(_kAppLocale) ?? 'mn';
      _loaded = true;
    });
  }

  Future<void> _select(String code) async {
    if (code != 'mn') return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAppLocale, code);
    setState(() => _locale = code);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Хэл сонголт хадгалагдлаа')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        backgroundColor: AppColors.creamBg,
        body: Center(child: CircularProgressIndicator(color: AppColors.orange)),
      );
    }

    return PremiumLayeredScaffold(
      title: 'Хэл / Бүс нутаг',
      showBackButton: true,
      useNativeNavBar: true,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Text(
            'Одоогоор монгол хэл идэвхтэй. Нэмэлт хэлүүд удахгүй нэмэгдэнэ.',
            style: AppText.bodySmall.copyWith(color: AppColors.textSec),
          ),
          const SizedBox(height: 16),
          _LanguageTile(
            title: 'Монгол',
            subtitle: 'Mongolia · UTC+8',
            selected: _locale == 'mn',
            onTap: () => _select('mn'),
          ),
          const SizedBox(height: 10),
          _LanguageTile(
            title: 'English',
            subtitle: 'Тун удахгүй',
            selected: false,
            enabled: false,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.enabled = true,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(MinimalStyle.cardRadius),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.surfaceEl,
              borderRadius: BorderRadius.circular(MinimalStyle.cardRadius),
              border: Border.all(
                color: selected
                    ? AppColors.orange.withOpacity(0.45)
                    : AppColors.borderSub,
                width: selected ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppText.h3.copyWith(fontSize: 16)),
                      Text(subtitle, style: AppText.bodySmall),
                    ],
                  ),
                ),
                if (selected)
                  const Icon(Icons.check_circle_rounded, color: AppColors.orange),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
