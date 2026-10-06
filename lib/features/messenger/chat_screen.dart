import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';
import 'package:sacred_app/core/notifications/call_launch_service.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/theme/minimal_style.dart';
import 'package:sacred_app/core/utils/app_timezone.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/features/booking/models/client_booking.dart';
import 'package:sacred_app/features/booking/providers/my_bookings_provider.dart';
import 'package:sacred_app/features/messenger/models/chat_message.dart';
import 'package:sacred_app/features/messenger/models/conversation.dart';
import 'package:sacred_app/features/messenger/providers/messenger_provider.dart';
import 'package:sacred_app/features/messenger/widgets/voice_message_bubble.dart';
import 'package:sacred_app/features/monk_dash/models/monk_booking_item.dart';
import 'package:sacred_app/features/monk_dash/providers/monk_dashboard_provider.dart';
import 'package:sacred_app/shared/widgets/error_state.dart';
import 'package:sacred_app/shared/widgets/premium_layered_scaffold.dart';
import 'package:sacred_app/shared/widgets/scale_tap.dart';

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
  final _scrollCtrl = ScrollController();
  final _recorder = AudioRecorder();
  bool _sending = false;
  bool _refreshingMessages = false;
  bool _recording = false;
  bool _hasText = false;
  DateTime? _recordStartedAt;
  String? _recordPath;
  Timer? _pollTimer;
  Timer? _recordTick;
  int _recordSeconds = 0;
  int _lastMessageCount = 0;
  String? _activeBookingId;
  bool _autoJoined = false;

  String get _initial {
    final trimmed = widget.title.trim();
    if (trimmed.isEmpty) return '?';
    return String.fromCharCode(trimmed.runes.first).toUpperCase();
  }

  String _roleLabel() {
    final role = ref.read(authStateProvider).valueOrNull?.role;
    if (role == 'monk') return 'Хэрэглэгч';
    final t = widget.title.toLowerCase();
    if (t.contains('дэмжлэг')) return 'Дэмжлэг';
    return 'Лам';
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText && mounted) setState(() => _hasText = has);
    });
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _refreshMessages();
      _checkCallSlot();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkCallSlot());
  }

  Future<void> _refreshMessages() async {
    if (_refreshingMessages || !mounted) return;
    _refreshingMessages = true;
    try {
      final _ = await ref.refresh(messagesProvider(widget.conversationId).future);
    } catch (_) {
    } finally {
      _refreshingMessages = false;
    }
  }

  Conversation? _conversation() {
    final list = ref.read(conversationsProvider).valueOrNull;
    if (list == null) return null;
    for (final c in list) {
      if (c.id == widget.conversationId) return c;
    }
    return null;
  }

  /// Захиалсан цаг болсон бол шууд дуудлага руу оруулна.
  Future<void> _checkCallSlot() async {
    if (!mounted || _autoJoined) return;
    final auth = ref.read(authStateProvider).valueOrNull;
    if (auth == null || !auth.isAuthenticated) return;

    try {
      if (auth.role == 'monk') {
        ref.invalidate(monkBookingsProvider);
        final bookings = await ref.read(monkBookingsProvider.future);
        final convo = _conversation();
        MonkBookingItem? match;
        for (final b in bookings) {
          final joinable = (b.status == 'confirmed' || b.status == 'completed') &&
              b.paid == true &&
              AppTimezone.isInCallWindow(b.date, b.slot, earlyMinutes: 1);
          if (!joinable) continue;
          // Same conversation peer when we know client name; otherwise any joinable.
          if (convo?.clientName != null &&
              convo!.clientName!.isNotEmpty &&
              b.clientName.isNotEmpty &&
              b.clientName != convo.clientName) {
            continue;
          }
          match = b;
          break;
        }
        if (match == null) {
          if (mounted && _activeBookingId != null) {
            setState(() => _activeBookingId = null);
          }
          return;
        }
        if (mounted) setState(() => _activeBookingId = match!.id);
        final start = AppTimezone.slotToMinutes(match.slot);
        final now = AppTimezone.currentTimeMinutes;
        if (now >= start && !_autoJoined) {
          _autoJoined = true;
          await CallLaunchService.tryAutoJoin(
            ref,
            bookingId: match.id,
            role: 'monk',
            reason: 'chat_slot',
            userInitiated: true,
          );
        }
      } else {
        ref.invalidate(myBookingsProvider);
        final bookings = await ref.read(myBookingsProvider.future);
        final convo = _conversation();
        ClientBooking? match;
        for (final b in bookings) {
          final joinable = (b.canJoinCall || b.canRejoinCall) &&
              AppTimezone.isInCallWindow(b.date, b.slot, earlyMinutes: 1);
          if (!joinable) continue;
          if (convo?.monkId != null &&
              convo!.monkId!.isNotEmpty &&
              b.monkId.isNotEmpty &&
              b.monkId != convo.monkId) {
            continue;
          }
          match = b;
          break;
        }
        if (match == null) {
          if (mounted && _activeBookingId != null) {
            setState(() => _activeBookingId = null);
          }
          return;
        }
        if (mounted) setState(() => _activeBookingId = match!.id);
        final start = AppTimezone.slotToMinutes(match.slot);
        final now = AppTimezone.currentTimeMinutes;
        if (now >= start && !_autoJoined) {
          _autoJoined = true;
          await CallLaunchService.tryAutoJoin(
            ref,
            bookingId: match.id,
            role: 'client',
            reason: 'chat_slot',
            userInitiated: true,
          );
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _recordTick?.cancel();
    _controller.dispose();
    _scrollCtrl.dispose();
    unawaited(_recorder.dispose());
    super.dispose();
  }

  void _leaveChat(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/messenger');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
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
      _scrollToBottom();
    } catch (e) {
      _controller.text = text;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              formatUserError(e, fallback: 'Мессеж илгээхэд алдаа гарлаа.'),
            ),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _startRecording() async {
    if (_sending || _recording) return;
    try {
      final ok = await _recorder.hasPermission();
      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Микрофон зөвшөөрөх хэрэгтэй. Тохиргоо → Gevabal → Микрофон.',
              ),
              backgroundColor: AppColors.danger,
            ),
          );
        }
        return;
      }
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );
      HapticFeedback.mediumImpact();
      _recordTick?.cancel();
      if (!mounted) return;
      setState(() {
        _recording = true;
        _recordPath = path;
        _recordStartedAt = DateTime.now();
        _recordSeconds = 0;
      });
      _recordTick = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted || !_recording) return;
        setState(() => _recordSeconds += 1);
        if (_recordSeconds >= 120) {
          unawaited(_stopRecording(send: true));
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              formatUserError(e, fallback: 'Бичлэг эхлүүлэхэд алдаа гарлаа.'),
            ),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _stopRecording({required bool send}) async {
    if (!_recording) return;
    _recordTick?.cancel();
    String? path;
    try {
      path = await _recorder.stop();
    } catch (_) {
      path = _recordPath;
    }
    final started = _recordStartedAt;
    final seconds = started == null
        ? _recordSeconds
        : DateTime.now().difference(started).inSeconds;
    if (!mounted) return;
    setState(() {
      _recording = false;
      _recordPath = null;
      _recordStartedAt = null;
      _recordSeconds = 0;
    });

    if (!send || path == null || path.isEmpty) {
      try {
        final f = File(path ?? '');
        if (await f.exists()) await f.delete();
      } catch (_) {}
      return;
    }
    if (seconds < 1) {
      try {
        await File(path).delete();
      } catch (_) {}
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Бичлэг хэт богино байна')),
        );
      }
      return;
    }

    setState(() => _sending = true);
    try {
      await sendVoiceMessage(
        ref,
        conversationId: widget.conversationId,
        filePath: path,
        durationSeconds: seconds.clamp(1, 120),
      );
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              formatUserError(e, fallback: 'Дуут мессеж илгээхэд алдаа гарлаа.'),
            ),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      try {
        await File(path).delete();
      } catch (_) {}
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.conversationId.trim().isEmpty) {
      return PremiumLayeredScaffold(
        expandBody: true,
        headerContent: _ChatHeader(
          initial: '?',
          name: widget.title,
          role: _roleLabel(),
          onBack: () => _leaveChat(context),
        ),
        body: ErrorState(
          error: Exception('Чат олдсонгүй'),
          fallback: 'Чат олдсонгүй.',
          onRetry: () => _leaveChat(context),
        ),
      );
    }

    final messagesAsync = ref.watch(messagesProvider(widget.conversationId));
    final mq = MediaQuery.of(context);
    final bottomPad = mq.padding.bottom + mq.viewInsets.bottom;
    final role = ref.watch(authStateProvider).valueOrNull?.role ?? 'client';

    return PremiumLayeredScaffold(
      expandBody: true,
      headerContent: _ChatHeader(
        initial: _initial,
        name: widget.title,
        role: _roleLabel(),
        onBack: () => _leaveChat(context),
      ),
      body: Column(
        children: [
          if (_activeBookingId != null)
            Material(
              color: AppColors.success.withValues(alpha: 0.12),
              child: InkWell(
                onTap: () {
                  CallLaunchService.tryAutoJoin(
                    ref,
                    bookingId: _activeBookingId!,
                    role: role == 'monk' ? 'monk' : 'client',
                    reason: 'chat_banner',
                    userInitiated: true,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.videocam_rounded,
                        color: AppColors.success,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Цаг боллоо — дуудлагад орох',
                          style: AppText.bodySmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.success,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: messagesAsync.when(
              skipLoadingOnReload: true,
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.orange),
              ),
              error: (e, _) => ErrorState(
                error: e,
                fallback: 'Мессеж ачаалахад алдаа гарлаа.',
                onRetry: () =>
                    ref.invalidate(messagesProvider(widget.conversationId)),
              ),
              data: (messages) {
                if (messages.isEmpty) return _emptyChat();
                if (messages.length != _lastMessageCount) {
                  _lastMessageCount = messages.length;
                  _scrollToBottom();
                }
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  itemCount: messages.length,
                  itemBuilder: (_, i) => _MessageBubble(
                    message: messages[i],
                    showAvatar: !messages[i].isMine,
                    initial: _initial,
                  ),
                );
              },
            ),
          ),
          if (_recording)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Бичиж байна… ${recordSeconds}с · суллаад илгээнэ',
                    style: AppText.caption.copyWith(color: AppColors.danger),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _stopRecording(send: false),
                    child: const Text('Цуцлах'),
                  ),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPad + 8),
            child: Container(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
              decoration: MinimalStyle.card(radius: 999),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !_recording,
                      minLines: 1,
                      maxLines: 4,
                      style: AppText.body.copyWith(fontSize: 15),
                      scrollPadding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                      decoration: InputDecoration(
                        hintText: _recording
                            ? 'Бичиж байна…'
                            : 'Мессеж бичих…',
                        hintStyle: AppText.bodySmall.copyWith(
                          color: AppColors.textHint,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  if (_hasText && !_recording)
                    ScaleTap(
                      pressedScale: 0.9,
                      onTap: _sending ? null : _send,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: AppGradients.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.orangeDeep.withValues(alpha: 0.28),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
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
                                Icons.arrow_upward_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                      ),
                    )
                  else
                    GestureDetector(
                      onLongPressStart: (_) => _startRecording(),
                      onLongPressEnd: (_) => _stopRecording(send: true),
                      onLongPressCancel: () => _stopRecording(send: false),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: _recording ? null : AppGradients.primary,
                          color: _recording ? AppColors.danger : null,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (_recording
                                      ? AppColors.danger
                                      : AppColors.orangeDeep)
                                  .withValues(alpha: 0.28),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: _sending && !_recording
                            ? const Padding(
                                padding: EdgeInsets.all(10),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                _recording
                                    ? Icons.stop_rounded
                                    : Icons.mic_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyChat() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.orangeLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.waving_hand_rounded,
                size: 32,
                color: AppColors.orange.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Мэндчилгээ илгээнэ үү',
              style: AppText.h3.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              '${_roleLabel()} ${widget.title}-тай\nтекст эсвэл микрофон дарж дуут мессеж илгээнэ үү',
              style: AppText.bodySmall.copyWith(color: AppColors.textSec),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({
    required this.initial,
    required this.name,
    required this.role,
    required this.onBack,
  });

  final String initial;
  final String name;
  final String role;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ScaleTap(
          pressedScale: 0.92,
          onTap: () {
            HapticFeedback.lightImpact();
            onBack();
          },
          child: const SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.inkDeep,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 44,
          height: 44,
          decoration: MinimalStyle.avatarBox(radius: 22),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: TextStyle(
              color: AppColors.orange.withValues(alpha: 0.75),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppText.body.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    role,
                    style: AppText.caption.copyWith(
                      color: AppColors.textSec,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.showAvatar,
    required this.initial,
  });

  final ChatMessage message;
  final bool showAvatar;
  final String initial;

  String? get _timeLabel {
    final raw = message.createdAt;
    if (raw == null || raw.isEmpty) return null;
    try {
      return AppTimezone.formatInstant(DateTime.parse(raw), 'HH:mm');
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mine = message.isMine;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!mine) ...[
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 8),
              decoration: MinimalStyle.avatarBox(radius: 14),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.orange.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: mine ? AppGradients.primary : null,
                    color: mine ? null : AppColors.surfaceEl,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(mine ? 18 : 4),
                      bottomRight: Radius.circular(mine ? 4 : 18),
                    ),
                    border: mine ? null : Border.all(color: AppColors.borderSub),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: message.isAudio
                      ? VoiceMessageBubble(message: message, mine: mine)
                      : Text(
                          message.text,
                          style: AppText.body.copyWith(
                            fontSize: 15,
                            color: mine ? Colors.white : AppColors.textPri,
                            height: 1.45,
                          ),
                        ),
                ),
                if (_timeLabel != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _timeLabel!,
                    style: AppText.caption.copyWith(
                      fontSize: 10,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
