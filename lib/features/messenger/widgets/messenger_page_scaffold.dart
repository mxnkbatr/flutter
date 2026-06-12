import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';

/// Messenger layout: gradient header + white sheet (tabs live on white, no overlap).
class MessengerPageScaffold extends StatelessWidget {
  const MessengerPageScaffold({
    super.key,
    required this.segmentTabs,
    required this.body,
  });

  final Widget segmentTabs;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final screenH = MediaQuery.of(context).size.height;
    final headerH = (screenH * 0.20).clamp(152.0, 180.0);
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
                gradient: AppGradients.heroHeader,
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, top + 16, 20, 24),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Харилцаа',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onDarkMuted,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Мессенжер',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onDark,
                        letterSpacing: -0.5,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                        child: segmentTabs,
                      ),
                      Expanded(child: body),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
