import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/messenger/providers/messenger_provider.dart';
import 'package:sacred_app/shared/widgets/ios_grouped_section.dart';

class MessengerScreen extends ConsumerWidget {
  const MessengerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convosAsync = ref.watch(conversationsProvider);

    return IosLargeTitleScaffold(
      title: 'Мессенжер',
      body: convosAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: Center(child: Text('Алдаа: $e', style: AppText.bodySmall)),
        ),
        data: (convos) {
          if (convos.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.chat_bubble_outline_rounded,
                      size: 48, color: AppColors.textSec.withOpacity(0.5)),
                  const SizedBox(height: 12),
                  Text('Чат байхгүй', style: AppText.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    'Ламын профайлаас мессеж илгээнэ үү',
                    style: AppText.caption,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: IosGroupedSection(
              children: convos.map((c) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.accentLight,
                    child: Text(
                      c.displayName.isNotEmpty ? c.displayName[0] : '?',
                      style: const TextStyle(color: AppColors.accent),
                    ),
                  ),
                  title: Text(c.displayName, style: AppText.h3.copyWith(fontSize: 16)),
                  subtitle: Text(
                    c.lastMessage ?? 'Мессеж эхлүүлэх',
                    style: AppText.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => context.push(
                    '/messenger/${c.id}?title=${Uri.encodeComponent(c.displayName)}',
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
