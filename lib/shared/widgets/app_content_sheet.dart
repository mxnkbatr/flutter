import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/shared/widgets/auth_ambient_scaffold.dart';

/// Alias — same soft orange blobs as login.
typedef AppAmbientBackground = AuthAmbientBackground;

/// Optional section title + helper (login sheet typography).
class AppSectionIntro extends StatelessWidget {
  const AppSectionIntro({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppText.displaySerif(size: 24)),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: AppText.bodySmall.copyWith(
              color: AppColors.textSec,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

/// White floating sheet — mirrors [AuthFormSheet] for main tabs.
///
/// Use under [AppTopHeader]: ambient behind, sheet fills remaining height.
/// Keep title/subtitle null for a clean office-style content plane.
class AppContentSheet extends StatelessWidget {
  const AppContentSheet({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.headerSlot,
    this.onRefresh,
    this.padding,
    this.bottomInset = 100,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  /// Optional row above content (e.g. category chips).
  final Widget? headerSlot;
  final Future<void> Function()? onRefresh;
  final EdgeInsetsGeometry? padding;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    final hasIntro = title != null || headerSlot != null;
    final contentPadding = padding ??
        EdgeInsets.fromLTRB(24, title != null ? 24 : 16, 24, 12);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceEl,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: AppColors.borderSub.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: AppColors.orange.withValues(alpha: 0.06),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasIntro)
            Padding(
              padding: contentPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (title != null) ...[
                    AppSectionIntro(title: title!, subtitle: subtitle),
                    if (headerSlot != null) const SizedBox(height: 16),
                  ],
                  if (headerSlot != null) headerSlot!,
                ],
              ),
            ),
          Expanded(
            child: onRefresh == null
                ? child
                : RefreshIndicator(
                    color: AppColors.orange,
                    onRefresh: onRefresh!,
                    child: child,
                  ),
          ),
        ],
      ),
    );
  }
}

/// Full tab body: ambient + white sheet (login composition, no page titles).
class AppTabSheetScaffold extends StatelessWidget {
  const AppTabSheetScaffold({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.headerSlot,
    this.onRefresh,
    this.bottomInset = 100,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? headerSlot;
  final Future<void> Function()? onRefresh;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.creamBg,
      child: Stack(
        children: [
          const AppAmbientBackground(),
          Column(
            children: [
              const SizedBox(height: 8),
              Expanded(
                child: AppContentSheet(
                  title: title,
                  subtitle: subtitle,
                  headerSlot: headerSlot,
                  onRefresh: onRefresh,
                  bottomInset: bottomInset,
                  child: child,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
