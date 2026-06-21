import 'package:flutter/material.dart';
import 'package:sacred_app/shared/widgets/premium_layered_scaffold.dart';

/// Messenger tab — premium layered layout (matches home).
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
    return PremiumLayeredScaffold(
      subtitle: 'Харилцаа',
      title: 'Мессенжер',
      expandBody: true,
      sheetTopContent: segmentTabs,
      body: body,
    );
  }
}
