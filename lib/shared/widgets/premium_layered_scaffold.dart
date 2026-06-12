import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';

/// Blue header + white rounded sheet — premium layered layout.
class PremiumLayeredScaffold extends StatelessWidget {
  const PremiumLayeredScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.headerBottom,
    required this.body,
    this.onRefresh,
    this.headerHeight = 168,
    this.fab,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? headerBottom;
  final Widget body;
  final Future<void> Function()? onRefresh;
  final double headerHeight;
  final Widget? fab;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final sheetTop = top + headerHeight;

    final scrollView = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: sheetTop - 28)),
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surfaceEl,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 24,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: body,
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.saffron,
      floatingActionButton: fab,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: sheetTop + 32,
            child: const DecoratedBox(
              decoration: BoxDecoration(gradient: AppGradients.heroHeader),
            ),
          ),
          Positioned(
            top: top + 12,
            left: 20,
            right: 20,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: AppText.bodySmall.copyWith(
                            color: AppColors.onDarkMuted,
                          ),
                        ),
                      Text(
                        title,
                        style: AppText.h1.copyWith(
                          color: AppColors.onDark,
                          fontSize: 28,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          if (headerBottom != null)
            Positioned(
              left: 20,
              right: 20,
              top: top + 88,
              child: headerBottom!,
            ),
          Positioned.fill(
            child: onRefresh == null
                ? scrollView
                : RefreshIndicator(
                    color: AppColors.saffron,
                    onRefresh: onRefresh!,
                    child: scrollView,
                  ),
          ),
        ],
      ),
    );
  }
}

class PremiumSegmentTabs extends StatelessWidget {
  const PremiumSegmentTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = i == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onChanged(i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: active ? AppGradients.primary : null,
                  color: active ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: AppColors.sunOrange.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  labels[i],
                  style: AppText.caption.copyWith(
                    color: active ? AppColors.inkDeep : AppColors.onDarkMuted,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
