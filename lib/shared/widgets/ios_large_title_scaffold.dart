import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';

class IosLargeTitleScaffold extends StatelessWidget {
  const IosLargeTitleScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      floatingActionButton: floatingActionButton,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            floating: false,
            pinned: true,
            expandedHeight: 96,
            titleSpacing: 0,
            elevation: 0,
            actions: actions,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 12),
              expandedTitleScale: 1.4,
              title: Text(
                title,
                style: AppText.h3.copyWith(color: AppColors.textPri),
              ),
              background: Container(color: AppColors.surface),
            ),
          ),
          SliverToBoxAdapter(child: body),
        ],
      ),
    );
  }
}
