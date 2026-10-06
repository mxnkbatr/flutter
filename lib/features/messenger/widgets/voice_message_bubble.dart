import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/utils/media_url.dart';
import 'package:sacred_app/features/messenger/models/chat_message.dart';

class VoiceMessageBubble extends StatefulWidget {
  const VoiceMessageBubble({
    super.key,
    required this.message,
    required this.mine,
  });

  final ChatMessage message;
  final bool mine;

  @override
  State<VoiceMessageBubble> createState() => _VoiceMessageBubbleState();
}

class _VoiceMessageBubbleState extends State<VoiceMessageBubble> {
  final _player = AudioPlayer();
  bool _loading = false;
  bool _playing = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _duration = Duration(seconds: widget.message.durationSeconds);
    _player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _playing = state.playing;
        if (state.processingState == ProcessingState.completed) {
          _playing = false;
          _position = Duration.zero;
          _player.seek(Duration.zero);
          _player.pause();
        }
      });
    });
    _player.positionStream.listen((pos) {
      if (!mounted) return;
      setState(() => _position = pos);
    });
    _player.durationStream.listen((d) {
      if (!mounted || d == null) return;
      setState(() => _duration = d);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    final url = resolveMediaUrl(widget.message.mediaUrl ?? '');
    if (url.isEmpty) return;
    try {
      if (_playing) {
        await _player.pause();
        return;
      }
      if (_player.audioSource == null) {
        setState(() => _loading = true);
        await _player.setUrl(url);
        if (!mounted) return;
        setState(() => _loading = false);
      }
      await _player.play();
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Дуу тоглуулахад алдаа гарлаа'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  String _fmt(Duration d) {
    final total = d.inSeconds;
    final m = total ~/ 60;
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final mine = widget.mine;
    final total = _duration.inMilliseconds > 0
        ? _duration
        : Duration(seconds: widget.message.durationSeconds);
    final progress = total.inMilliseconds == 0
        ? 0.0
        : (_position.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
    final fg = mine ? Colors.white : AppColors.earthBrown;
    final track = mine
        ? Colors.white.withValues(alpha: 0.35)
        : AppColors.earthBrown.withValues(alpha: 0.2);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _loading ? null : _toggle,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: mine
                  ? Colors.white.withValues(alpha: 0.2)
                  : AppColors.orangeLight,
              shape: BoxShape.circle,
            ),
            child: _loading
                ? Padding(
                    padding: const EdgeInsets.all(8),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: fg,
                    ),
                  )
                : Icon(
                    _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: fg,
                    size: 22,
                  ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: track,
                  color: fg,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _playing || _position > Duration.zero
                    ? _fmt(_position)
                    : _fmt(total),
                style: AppText.caption.copyWith(
                  color: mine
                      ? Colors.white.withValues(alpha: 0.85)
                      : AppColors.textSec,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
