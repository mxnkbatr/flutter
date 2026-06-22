import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/theme/minimal_style.dart';

/// Prominent incoming / active call banner for monk bookings.
class MonkCallHeroCard extends StatelessWidget {
  const MonkCallHeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.actions,
    this.accent = AppColors.success,
    this.pulsing = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final List<Widget> actions;
  final bool pulsing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(MinimalStyle.cardRadiusLg),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accent.withOpacity(0.14),
              AppColors.surfaceEl,
            ],
          ),
          border: Border.all(color: accent.withOpacity(0.45), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(pulsing ? 0.22 : 0.12),
              blurRadius: pulsing ? 20 : 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: pulsing ? AppGradients.primary : null,
                    color: pulsing ? null : accent.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: pulsing ? Colors.white : accent,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppText.h3.copyWith(
                          fontSize: 17,
                          color: AppColors.inkDeep,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppText.bodySmall.copyWith(
                          color: AppColors.textSec,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  for (var i = 0; i < actions.length; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(child: actions[i]),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
