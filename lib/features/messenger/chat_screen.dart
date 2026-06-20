import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/features/messenger/providers/messenger_provider.dart';
import 'package:sacred_app/shared/widgets/error_state.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.title,
  });

  final String conversationId;
  final String title;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  bool _sending = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      ref.invalidate(messagesProvider(widget.conversationId));
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    _controller.clear();
    try {
      await sendMessage(
        ref,
        conversationId: widget.conversationId,
        text: text,
      );
    } catch (e) {
      _controller.text = text;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(formatUserError(e, fallback: 'Мессеж илгээхэд алдаа гарлаа.')),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.conversationId));
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.surfaceEl,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.surfaceEl,
        foregroundColor: AppColors.textPri,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppText.h3,
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.blue),
              ),
              error: (e, _) => ErrorState(
                error: e,
                fallback: 'Мессеж ачаалахад алдаа гарлаа.',
                onRetry: () =>
                    ref.invalidate(messagesProvider(widget.conversationId)),
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 48,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Мессеж бичиж эхлүүлээрэй',
                            style: AppText.bodySmall.copyWith(
                              color: AppColors.textSec,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: messages.length,
                itemBuilder: (_, i) {
                  final m = messages[i];
                  return Align(
                    alignment:
                        m.isMine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.72,
                      ),
                      decoration: BoxDecoration(
                        gradient: m.isMine ? AppGradients.primary : null,
                        color: m.isMine ? null : AppColors.blueSoft,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft: Radius.circular(m.isMine ? 20 : 4),
                          bottomRight: Radius.circular(m.isMine ? 4 : 20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.blue.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        m.text,
                        style: AppText.body.copyWith(
                          fontSize: 15,
                          color: m.isMine ? Colors.white : AppColors.textPri,
                          height: 1.4,
                        ),
                      ),
                    ),
                  );
                },
              );
              },
            ),
          ),
          Container(
            color: AppColors.surfaceEl,
            padding: EdgeInsets.fromLTRB(16, 10, 16, bottom + 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Мессеж бичих...',
                      hintStyle: AppText.bodySmall,
                      filled: true,
                      fillColor: AppColors.blueSoft,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sending ? null : _send,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      gradient: AppGradients.primary,
                      shape: BoxShape.circle,
                    ),
                    child: _sending
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
