import 'package:flutter/material.dart';
import 'package:sacred_app/shared/widgets/premium_layered_scaffold.dart';

/// Profile tab — premium layered layout (matches home).
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
    return PremiumLayeredScaffold(
      headerHeight: 220,
      headerContent: header,
      expandBody: true,
      body: body,
    );
  }
}
