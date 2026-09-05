import 'package:flutter/material.dart';
import 'package:sacred_app/shared/widgets/app_content_sheet.dart';

/// Messenger tab — login ambient + white sheet (no page title).
class MessengerPageScaffold extends StatelessWidget {
  const MessengerPageScaffold({
    super.key,
    required this.body,
    this.segmentTabs,
  });

  final Widget? segmentTabs;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return AppTabSheetScaffold(
      headerSlot: segmentTabs,
      child: body,
    );
  }
}
