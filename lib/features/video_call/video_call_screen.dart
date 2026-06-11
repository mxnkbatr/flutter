import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';
import 'package:sacred_app/core/auth/tier_provider.dart';
import 'package:sacred_app/features/subscription/utils/tier_gating.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/video_call/widgets/call_controls.dart';
import 'package:sacred_app/features/video_call/widgets/call_top_bar.dart';
import 'package:sacred_app/features/video_call/widgets/end_call_dialog.dart';
import 'package:sacred_app/features/video_call/widgets/local_video_widget.dart';
import 'package:sacred_app/features/video_call/widgets/waiting_view.dart';

class VideoCallScreen extends ConsumerStatefulWidget {
  const VideoCallScreen({
    super.key,
    required this.bookingId,
    this.role = 'client',
  });

  final String bookingId;
  final String role;

  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen> {
  Room? _room;
  LocalParticipant? _local;
  RemoteParticipant? _remote;
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _connecting = true;
  String? _error;
  String _peerName = 'Лам';
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _connect();
    _startTimer();
  }

  VideoTrack? _videoTrackFor(Participant? participant) {
    if (participant == null) return null;
    for (final pub in participant.videoTrackPublications) {
      final track = pub.track;
      if (track is VideoTrack && !pub.muted) return track;
    }
    return null;
  }

  Future<void> _connect() async {
    final auth = ref.read(authStateProvider).valueOrNull;
    if (auth == null || !auth.isAuthenticated) {
      setState(() {
        _error = 'Нэвтрээгүй байна';
        _connecting = false;
      });
      return;
    }

    if (widget.role == 'client') {
      final tier = ref.read(userTierProvider);
      if (!tier.canVideoCall) {
        setState(() {
          _error = 'Видео дуудлага Premium эрхтэй';
          _connecting = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          TierGating.showUpgrade(
            context,
            reason: 'Видео дуудлага Premium эрхтэй',
          );
          context.pop();
        });
        return;
      }
    }

    try {
      try {
        final bookingRes = await ref.read(apiClientProvider).get(
              '/bookings/${widget.bookingId}',
            );
        final booking = bookingRes.data as Map<String, dynamic>;
        final monkName = booking['monkName'] as String? ??
            (booking['monk'] as Map<String, dynamic>?)?['name']?['mn'] as String?;
        if (monkName != null && monkName.isNotEmpty) {
          _peerName = monkName;
        }
      } catch (_) {}

      final res = await ref.read(apiClientProvider).get(
        '/livekit',
        queryParameters: {
          'room': 'booking-${widget.bookingId}',
          'username': auth.userName ?? 'user',
        },
      );
      final data = res.data as Map<String, dynamic>;
      final token = data['token'] as String;
      final wsUrl = data['wsUrl'] as String? ?? data['url'] as String?;
      if (wsUrl == null) {
        throw StateError('LiveKit wsUrl олдсонгүй');
      }

      final room = Room(
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
          defaultVideoPublishOptions: VideoPublishOptions(
            simulcast: true,
            videoEncoding: VideoEncoding(
              maxBitrate: 1500000,
              maxFramerate: 30,
            ),
          ),
        ),
      );

      await room.connect(wsUrl, token);
      await room.localParticipant?.setCameraEnabled(true);
      await room.localParticipant?.setMicrophoneEnabled(true);

      room.addListener(_onRoomEvent);

      if (!mounted) {
        await room.disconnect();
        return;
      }

      setState(() {
        _room = room;
        _local = room.localParticipant;
        _remote = room.remoteParticipants.values.firstOrNull;
        _connecting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _connecting = false;
      });
    }
  }

  void _onRoomEvent() {
    if (!mounted) return;
    setState(() {
      _remote = _room?.remoteParticipants.values.firstOrNull;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  Future<void> _toggleMute() async {
    await _room?.localParticipant?.setMicrophoneEnabled(_isMuted);
    setState(() => _isMuted = !_isMuted);
  }

  Future<void> _toggleCamera() async {
    await _room?.localParticipant?.setCameraEnabled(_isCameraOff);
    setState(() => _isCameraOff = !_isCameraOff);
  }

  Future<void> _endCall() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => const EndCallDialog(),
    );
    if (confirm != true || !mounted) return;

    try {
      await ref.read(apiClientProvider).put(
            '/bookings/${widget.bookingId}/complete',
          );
    } catch (_) {}

    await _room?.disconnect();
    if (mounted) context.go('/bookings');
  }

  Future<void> _showNoteDrawer() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceEl,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.45,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          builder: (_, scrollController) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: ListView(
                controller: scrollController,
                children: [
                  const Text('Тэмдэглэл', style: AppText.h3),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText: 'Дуудлагын тэмдэглэл бичнэ үү...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Хадгалах'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _noteController.dispose();
    _room?.removeListener(_onRoomEvent);
    _room?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_connecting) {
      return Scaffold(
        backgroundColor: AppColors.inkDeep,
        body: WaitingView(role: widget.role),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.inkDeep,
        appBar: AppBar(title: const Text('Видео дуудлага')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_error!, style: AppText.bodySmall, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Буцах'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final remoteTrack = _videoTrackFor(_remote);
    final localTrack = _videoTrackFor(_local);

    return Scaffold(
      backgroundColor: AppColors.inkDeep,
      body: Stack(
        children: [
          Positioned.fill(
            child: remoteTrack != null
                ? VideoTrackRenderer(
                    remoteTrack,
                    fit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  )
                : WaitingView(role: widget.role),
          ),
          Positioned(
            right: 16,
            bottom: 120 + MediaQuery.of(context).padding.bottom,
            child: LocalVideoWidget(
              track: localTrack,
              isCameraOff: _isCameraOff,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CallTopBar(
              monkName: _peerName,
              elapsed: _elapsed,
              isConnected: remoteTrack != null,
              onNote: _showNoteDrawer,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CallControls(
              isMuted: _isMuted,
              isCameraOff: _isCameraOff,
              onMute: _toggleMute,
              onCamera: _toggleCamera,
              onEnd: _endCall,
              onChat: () => context.push('/messenger'),
              onNote: _showNoteDrawer,
            ),
          ),
        ],
      ),
    );
  }
}
