import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';

class CallTopBar extends StatelessWidget {
  const CallTopBar({
    super.key,
    required this.monkName,
    required this.elapsed,
    required this.isConnected,
    this.onNote,
  });

  final String monkName;
  final Duration elapsed;
  final bool isConnected;
  final VoidCallback? onNote;

  String get _elapsedText {
    final m = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = elapsed.inHours;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:$m:$s';
    }
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            bottom: 16,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceEl.withOpacity(0.88),
            border: Border(
              bottom: BorderSide(color: AppColors.borderSub.withOpacity(0.8)),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      monkName,
                      style: AppText.h3.copyWith(
                        color: AppColors.inkDeep,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: isConnected
                                ? AppColors.success
                                : AppColors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isConnected ? 'Холбогдсон · HD' : 'Холбогдож байна...',
                          style: AppText.caption.copyWith(
                            color: isConnected
                                ? AppColors.success
                                : AppColors.textSec,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.orangeLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.orange.withOpacity(0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _RecordingDot(active: isConnected),
                    const SizedBox(width: 6),
                    Text(
                      _elapsedText,
                      style: AppText.bodySmall.copyWith(
                        color: AppColors.orange,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              if (onNote != null) ...[
                const SizedBox(width: 8),
                Material(
                  color: AppColors.orangeLight,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: onNote,
                    borderRadius: BorderRadius.circular(12),
                    child: const SizedBox(
                      width: 36,
                      height: 36,
                      child: Icon(
                        Icons.note_alt_outlined,
                        color: AppColors.orange,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordingDot extends StatefulWidget {
  const _RecordingDot({required this.active});

  final bool active;

  @override
  State<_RecordingDot> createState() => _RecordingDotState();
}

class _RecordingDotState extends State<_RecordingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.active
          ? Tween<double>(begin: 1.0, end: 0.35).animate(_ctrl)
          : AlwaysStoppedAnimation(1.0),
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: widget.active ? AppColors.danger : AppColors.orange,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
