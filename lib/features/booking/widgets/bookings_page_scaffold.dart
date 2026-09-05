import 'package:flutter/material.dart';
import 'package:sacred_app/shared/widgets/app_content_sheet.dart';

/// Bookings tab — login ambient + white sheet (no page title).
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
    return AppTabSheetScaffold(
      onRefresh: onRefresh,
      child: body,
    );
  }
}
