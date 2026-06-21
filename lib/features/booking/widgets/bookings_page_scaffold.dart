import 'package:flutter/material.dart';
import 'package:sacred_app/shared/widgets/premium_layered_scaffold.dart';

/// Bookings tab — premium layered layout (matches home).
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
    return PremiumLayeredScaffold(
      subtitle: 'Миний',
      title: 'Захиалга',
      expandBody: true,
      onRefresh: onRefresh,
      body: body,
    );
  }
}
