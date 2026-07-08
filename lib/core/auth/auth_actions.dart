import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';

Future<void> performLogout(WidgetRef ref, BuildContext context) async {
  await ref.read(authStateProvider.notifier).logout();
  if (context.mounted) {
    context.go('/auth/login');
  }
}
