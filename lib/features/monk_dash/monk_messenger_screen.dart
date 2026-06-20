import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/messenger/providers/messenger_provider.dart';
import 'package:sacred_app/shared/widgets/ios_grouped_section.dart';

/// Monk-side messenger — reuses same conversation API.
class MonkMessengerScreen extends ConsumerWidget {
  const MonkMessengerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convosAsync = ref.watch(conversationsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Мессенжер')),
      body: convosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(formatUserError(e))),
        data: (convos) {
          if (convos.isEmpty) {
            return const Center(
              child: Text('Чат байхгүй', style: AppText.bodySmall),
            );
          }
          return IosGroupedSection(
            title: 'Харилцагчид',
            children: convos.map((c) {
              final name = c.clientName ?? 'Хэрэглэгч';
              return ListTile(
                title: Text(name),
                subtitle: Text(c.lastMessage ?? '', maxLines: 1),
                onTap: () => context.push(
                  '/messenger/${c.id}?title=${Uri.encodeComponent(name)}',
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
