import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/messenger/providers/messenger_provider.dart';
import 'package:sacred_app/features/messenger/widgets/chat_conversation_tile.dart';
import 'package:sacred_app/shared/widgets/error_state.dart';
import 'package:sacred_app/shared/widgets/premium_layered_scaffold.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';

/// Monk-side messenger — same API as client, client-focused UI.
class MonkMessengerScreen extends ConsumerWidget {
  const MonkMessengerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convosAsync = ref.watch(conversationsProvider);
    final bottomPad = MediaQuery.of(context).padding.bottom + 80;

    return PremiumLayeredScaffold(
      subtitle: 'Харилцаа',
      title: 'Мессенжер',
      expandBody: true,
      body: RefreshIndicator(
        color: AppColors.orange,
        onRefresh: () => ref.refresh(conversationsProvider.future),
        child: convosAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.orange),
          ),
          error: (e, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              Padding(
                padding: const EdgeInsets.all(24),
                child: ErrorState(
                  error: e,
                  fallback: 'Чатын жагсаалт ачаалахад алдаа гарлаа.',
                  onRetry: () => ref.invalidate(conversationsProvider),
                ),
              ),
            ],
          ),
          data: (convos) {
            if (convos.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 48, 20, 32),
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.orangeLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 36,
                      color: AppColors.orange.withOpacity(0.65),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Чат байхгүй',
                    style: AppText.h3.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Хэрэглэгч тантай чат эхлүүлэхэд\nэнд харагдана',
                    style: AppText.bodySmall.copyWith(
                      color: AppColors.textSec,
                      height: 1.45,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPad),
              itemCount: convos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final c = convos[i];
                final name = c.clientName?.trim().isNotEmpty == true
                    ? c.clientName!
                    : 'Хэрэглэгч';
                return ChatConversationTile(
                  name: name,
                  preview: c.lastMessage ?? 'Мессеж эхлүүлэх',
                  time: c.lastMessageAt,
                  peerRole: 'Хэрэглэгч',
                  onTap: () => context.push(
                    '/messenger/${c.id}?title=${Uri.encodeComponent(name)}',
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
