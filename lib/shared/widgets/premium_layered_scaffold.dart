import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/shared/widgets/native_app_header.dart';
import 'package:sacred_app/shared/widgets/scale_tap.dart';

/// Flat cream layout with native iOS-style headers.
class PremiumLayeredScaffold extends StatelessWidget {
  const PremiumLayeredScaffold({
    super.key,
    this.title = '',
    this.subtitle,
    this.trailing,
    this.leading,
    this.headerBottom,
    this.headerContent,
    this.sheetTopContent,
    required this.body,
    this.onRefresh,
    this.headerHeight = 168,
    this.fab,
    this.showBackButton = false,
    this.centerTitle = false,
    this.backIcon = Icons.arrow_back_ios_new_rounded,
    this.onBack,
    this.expandBody = false,
    this.bottomBar,
    this.useNativeNavBar = false,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final Widget? headerBottom;
  final Widget? headerContent;
  final Widget? sheetTopContent;
  final Widget body;
  final Future<void> Function()? onRefresh;
  final double headerHeight;
  final Widget? fab;
  final bool showBackButton;
  final bool centerTitle;
  final IconData backIcon;
  final VoidCallback? onBack;
  final bool expandBody;
  final Widget? bottomBar;
  /// Push screens: compact centered nav bar (Лам нар, Хайх…).
  final bool useNativeNavBar;

  VoidCallback _backAction(BuildContext context) {
    return () {
      HapticFeedback.lightImpact();
      if (onBack != null) {
        onBack!();
      } else {
        context.pop();
      }
    };
  }

  Widget? _buildBackButton(BuildContext context) {
    if (leading != null) return leading;
    if (!showBackButton) return null;
    return ScaleTap(
      pressedScale: 0.92,
      onTap: _backAction(context),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Icon(
          backIcon,
          size: backIcon == Icons.close_rounded ? 22 : 18,
          color: AppColors.inkDeep,
        ),
      ),
    );
  }

  Widget _buildDefaultHeader(BuildContext context) {
    final back = _buildBackButton(context);

    if (useNativeNavBar || (centerTitle && showBackButton)) {
      return NativeNavBar(
        title: title,
        onBack: showBackButton ? _backAction(context) : null,
        leading: back,
        trailing: trailing,
        showBorder: false,
      );
    }

    return NativeLargeTitleHeader(
      eyebrow: subtitle,
      title: title,
      leading: back,
      trailing: trailing,
    );
  }

  Widget _headerSection(BuildContext context, double top) {
    final content = headerContent ?? _buildDefaultHeader(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(20, top + 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (headerContent != null && showBackButton && leading == null)
            Align(
              alignment: Alignment.centerLeft,
              child: ScaleTap(
                pressedScale: 0.92,
                onTap: _backAction(context),
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: AppColors.inkDeep,
                  ),
                ),
              ),
            ),
          content,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    if (expandBody) {
      return Scaffold(
        backgroundColor: AppColors.creamBg,
        floatingActionButton: fab,
        bottomNavigationBar: bottomBar,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _headerSection(context, top),
            if (headerBottom != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: headerBottom,
              ),
            if (sheetTopContent != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: sheetTopContent,
              ),
            Expanded(
              child: onRefresh == null
                  ? body
                  : RefreshIndicator(
                      color: AppColors.orange,
                      onRefresh: onRefresh!,
                      child: body,
                    ),
            ),
          ],
        ),
      );
    }

    final scrollView = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(child: _headerSection(context, top)),
        if (headerBottom != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: headerBottom,
            ),
          ),
        if (sheetTopContent != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: sheetTopContent,
            ),
          ),
        SliverToBoxAdapter(child: body),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      floatingActionButton: fab,
      bottomNavigationBar: bottomBar,
      body: onRefresh == null
          ? scrollView
          : RefreshIndicator(
              color: AppColors.orange,
              onRefresh: onRefresh!,
              child: scrollView,
            ),
    );
  }
}

/// Orange capsule tabs — matches [CategoryChip] on home.
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
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final active = i == selected;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                gradient: active ? AppGradients.primary : null,
                color: active ? null : AppColors.surfaceEl,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: active
                      ? AppColors.orangeDeep
                      : AppColors.orange,
                  width: 1.2,
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: AppColors.orange.withOpacity(0.22),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                labels[i],
                style: active ? AppText.chipActive : AppText.chipInactive,
              ),
            ),
          );
        },
      ),
    );
  }
}
