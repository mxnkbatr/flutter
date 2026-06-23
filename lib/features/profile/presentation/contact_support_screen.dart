import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/theme/minimal_style.dart';
import 'package:sacred_app/shared/widgets/premium_layered_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  Future<void> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _copy(BuildContext context, String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label хуулагдлаа')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PremiumLayeredScaffold(
      title: 'Бидэнтэй холбогдох',
      showBackButton: true,
      useNativeNavBar: true,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Text(
            'Асуулт, санал, техникийн тусламж хэрэгтэй бол доорх сувгуудаар холбогдоно уу.',
            style: AppText.bodySmall.copyWith(
              color: AppColors.textSec,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          _ContactCard(
            icon: Icons.chat_bubble_outline_rounded,
            iconBg: AppColors.orangeLight,
            iconColor: AppColors.orange,
            title: 'Чат дэмжлэг',
            subtitle: 'Апп доторх мессежээр холбогдох',
            onTap: () => context.go('/messenger'),
          ),
          const SizedBox(height: 12),
          _ContactCard(
            icon: Icons.email_outlined,
            iconBg: const Color(0xFFE8F0FF),
            iconColor: const Color(0xFF4A7FD4),
            title: 'И-мэйл',
            subtitle: 'support@gevabal.mn',
            onTap: () => _launch(Uri.parse('mailto:support@gevabal.mn')),
            onLongPress: () => _copy(context, 'И-мэйл', 'support@gevabal.mn'),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: MinimalStyle.card(radius: 16),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded, color: AppColors.orange, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ажлын цаг: Даваа–Баасан 09:00–18:00\n48 цагийн дотор хариу өгнө.',
                    style: AppText.caption.copyWith(
                      color: AppColors.textSec,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.onLongPress,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(MinimalStyle.cardRadius),
        child: Ink(
          decoration: MinimalStyle.card(),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppText.h3.copyWith(fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppText.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}
