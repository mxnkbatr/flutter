import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';

/// Profile layout: sun gradient header + full-height white body.
class ProfilePageScaffold extends StatelessWidget {
  const ProfilePageScaffold({
    super.key,
    required this.header,
    required this.body,
  });

  final Widget header;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final headerH = (screenH * 0.26).clamp(200.0, 240.0);
    const sheetOverlap = 28.0;

    return Scaffold(
      backgroundColor: AppColors.surfaceEl,
      body: Column(
        children: [
          SizedBox(
            height: headerH,
            width: double.infinity,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: AppGradients.profileHero,
              ),
              child: header,
            ),
          ),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -sheetOverlap),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceEl,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 12,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  child: body,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
