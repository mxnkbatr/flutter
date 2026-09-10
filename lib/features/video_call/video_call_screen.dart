import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';
import 'package:sacred_app/core/notifications/call_launch_service.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/features/video_call/widgets/call_error_view.dart';
import 'package:sacred_app/features/video_call/widgets/call_controls.dart';
import 'package:sacred_app/features/video_call/widgets/call_permission_prep_view.dart';
import 'package:sacred_app/features/video_call/widgets/call_top_bar.dart';
import 'package:sacred_app/features/video_call/widgets/connecting_view.dart';
import 'package:sacred_app/features/video_call/widgets/end_call_dialog.dart';
import 'package:sacred_app/features/video_call/widgets/local_video_widget.dart';
import 'package:sacred_app/features/video_call/widgets/waiting_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dart-only: native permission_handler ашиглахгүй (Shorebird patch-д тохирно).
const _kCallPermissionPrepSeenKey = 'call_permission_prep_seen_v1';

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
  bool _awaitingPermission = true;
  bool _permissionLoading = false;
  bool _connecting = false;
  String? _error;
  String _peerName = 'Лам';
  String? _peerImage;
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }
      _maybeSkipPrep();
    });
  }

  /// Өмнө нь тайлбар харсан бол шууд холбогдоно (систем зөвшөөрөл LiveKit асууна).
  Future<void> _maybeSkipPrep() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    if (prefs.getBool(_kCallPermissionPrepSeenKey) == true) {
      setState(() {
        _awaitingPermission = false;
        _connecting = true;
      });
      _startTimer();
      await _connect();
    }
  }

  Future<void> _onAllowPermissions() async {
    setState(() => _permissionLoading = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kCallPermissionPrepSeenKey, true);
    if (!mounted) return;
    setState(() {
      _permissionLoading = false;
      _awaitingPermission = false;
      _connecting = true;
    });
    _startTimer();
    await _connect();
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

    try {
      try {
        final bookingRes = await ref.read(apiClientProvider).get(
              '/bookings/${widget.bookingId}',
            );
        final booking = bookingRes.data as Map<String, dynamic>;
        if (widget.role == 'monk') {
          final clientName = booking['clientName'] as String?;
          if (clientName != null && clientName.isNotEmpty) {
            _peerName = clientName;
          }
        } else {
          final monkName = booking['monkName'] as String? ??
              (booking['monk'] as Map<String, dynamic>?)?['name']?['mn']
                  as String?;
          if (monkName != null && monkName.isNotEmpty) {
            _peerName = monkName;
          }
          final monkImage = booking['monkImage'] as String? ??
              (booking['monk'] as Map<String, dynamic>?)?['image'] as String?;
          if (monkImage != null && monkImage.isNotEmpty) {
            _peerImage = monkImage;
          }
        }
        if (mounted) setState(() {});
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

      // Системийн mic/camera popup энд (LiveKit) гарна — native plugin шаардлагагүй.
      var cameraOff = false;
      try {
        await room.localParticipant?.setMicrophoneEnabled(true);
      } catch (e) {
        if (kDebugMode) debugPrint('Mic enable: $e');
        if (!mounted) {
          await room.disconnect();
          return;
        }
        setState(() {
          _error = formatUserError(
            e,
            fallback:
                'Микрофон асаагдсангүй.\n\nТохиргоо → Gevabal → Микрофон-ыг асаагаад дахин оролдоно уу.',
          );
          _connecting = false;
        });
        await room.disconnect();
        return;
      }

      try {
        await room.localParticipant?.setCameraEnabled(true);
      } catch (e) {
        if (kDebugMode) debugPrint('Camera enable (audio-only OK): $e');
        cameraOff = true;
      }

      room.addListener(_onRoomEvent);

      if (!mounted) {
        await room.disconnect();
        return;
      }

      setState(() {
        _room = room;
        _local = room.localParticipant;
        _remote = room.remoteParticipants.values.firstOrNull;
        _isCameraOff = cameraOff;
        _connecting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = formatUserError(
          e,
          fallback: 'Видео дуудлага эхлүүлэхэд алдаа гарлаа.',
        );
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
    _timer?.cancel();
    _elapsed = Duration.zero;
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
    final enable = _isCameraOff;
    try {
      await _room?.localParticipant?.setCameraEnabled(enable);
      if (!mounted) return;
      setState(() => _isCameraOff = !enable);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Камер асаах боломжгүй. Тохиргоо → Gevabal → Камер шалгана уу.',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _switchCamera() async {
    try {
      final videoTrack = _local?.videoTrackPublications.firstOrNull?.track;
      if (videoTrack is LocalVideoTrack) {
        final options = videoTrack.currentOptions;
        if (options is CameraCaptureOptions) {
          await videoTrack.setCameraPosition(options.cameraPosition.switched());
        }
      }
    } catch (_) {}
  }

  void _leaveCallScreen() {
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
      return;
    }
    if (widget.role == 'monk') {
      context.go('/monk/dashboard?tab=2');
    } else {
      context.go('/bookings');
    }
  }

  Future<void> _cancelConnecting() async {
    await CallLaunchService.markLeftCall(widget.bookingId);
    await _room?.disconnect();
    if (mounted) _leaveCallScreen();
  }

  Future<void> _endCall() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => const EndCallDialog(),
    );
    if (confirm != true || !mounted) return;

    try {
      if (widget.role == 'monk') {
        await ref.read(apiClientProvider).put(
              '/bookings/${widget.bookingId}/complete',
            );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Дуусгах алдаа: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }

    await CallLaunchService.markLeftCall(widget.bookingId);
    await _room?.disconnect();
    if (mounted) {
      if (widget.role == 'monk') {
        context.go('/monk/dashboard?tab=2');
      } else {
        context.go('/bookings');
      }
    }
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
                  Text('Тэмдэглэл', style: AppText.h3),
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
                    child: const Text('Хаах'),
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
    if (_awaitingPermission) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _cancelConnecting();
        },
        child: CallPermissionPrepView(
          isLoading: _permissionLoading,
          onAllow: _onAllowPermissions,
          onCancel: _cancelConnecting,
        ),
      );
    }

    if (_connecting) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _cancelConnecting();
        },
        child: ConnectingView(
          peerName: _peerName,
          peerImage: _peerImage,
          role: widget.role,
          onCancel: _cancelConnecting,
        ),
      );
    }

    if (_error != null) {
      return PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _leaveCallScreen();
        },
        child: CallErrorView(
          message: _error!,
          onBack: _leaveCallScreen,
          onRetry: () {
            setState(() {
              _error = null;
              _awaitingPermission = true;
              _connecting = false;
            });
          },
        ),
      );
    }

    final remoteTrack = _videoTrackFor(_remote);
    final localTrack = _videoTrackFor(_local);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _endCall();
      },
      child: Scaffold(
        backgroundColor: AppColors.inkDeep,
        body: Stack(
          children: [
            Positioned.fill(
              child: remoteTrack != null
                  ? VideoTrackRenderer(
                      remoteTrack,
                      fit: VideoViewFit.cover,
                    )
                  : WaitingView(
                      role: widget.role,
                      peerName: _peerName,
                      peerImage: _peerImage,
                    ),
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
                onNote: _showNoteDrawer,
                onSwitchCamera: _switchCamera,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
