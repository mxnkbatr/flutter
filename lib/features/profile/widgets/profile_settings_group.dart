import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';

const _chevronColor = Color(0xFFC7C7CC);
const _dividerColor = Color(0xFFE5E5EA);

class ProfileSettingsGroup extends StatelessWidget {
  const ProfileSettingsGroup({
    super.key,
    this.title,
    required this.children,
  });

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              title!.toUpperCase(),
              style: AppText.caption.copyWith(
                color: AppColors.textSec,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
                fontSize: 12,
              ),
            ),
          ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceEl,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _dividerColor, width: 0.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: _withDividers(children)),
        ),
      ],
    );
  }

  List<Widget> _withDividers(List<Widget> items) {
    if (items.length <= 1) return items;
    final out = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      out.add(items[i]);
      if (i < items.length - 1) {
        out.add(
          const Divider(
            height: 0.5,
            thickness: 0.5,
            color: _dividerColor,
            indent: 56,
            endIndent: 0,
          ),
        );
      }
    }
    return out;
  }
}

class ProfileSettingsTile extends StatelessWidget {
  const ProfileSettingsTile({
    super.key,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    this.titleColor,
    this.titleWeight,
    this.showChevron = true,
    this.onTap,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final Color? titleColor;
  final FontWeight? titleWeight;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onTap!();
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppText.body.copyWith(
                    color: titleColor ?? AppColors.textPri,
                    fontWeight: titleWeight ?? FontWeight.w400,
                  ),
                ),
              ),
              if (showChevron)
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: _chevronColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
