import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
/// Bookings-only layout: gradient header + full-height white body (no yellow gap).
class BookingsPageScaffold extends StatelessWidget {
  const BookingsPageScaffold({
    super.key,
    required this.body,
    this.onRefresh,
  });

  final Widget body;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final headerH = (screenH * 0.22).clamp(168.0, 210.0);
    final sheetOverlap = 28.0;

    return Scaffold(
      backgroundColor: AppColors.surfaceEl,
      body: Column(
        children: [
          SizedBox(
            height: headerH,
            width: double.infinity,
            child: const DecoratedBox(
              decoration: BoxDecoration(gradient: AppGradients.heroHeader),
              child: _BookingsHeader(),
            ),
          ),
          Expanded(
            child: Transform.translate(
              offset: Offset(0, -sheetOverlap),
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
                  child: onRefresh == null
                      ? body
                      : RefreshIndicator(
                          color: AppColors.saffron,
                          onRefresh: onRefresh!,
                          child: body,
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

class _BookingsHeader extends StatelessWidget {
  const _BookingsHeader();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, top + 16, 20, 24),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Миний',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.onDarkMuted,
              height: 1.2,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Захиалга',
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
    );
  }
}
