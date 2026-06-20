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
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.inkDeep.withOpacity(0.85),
            AppColors.transparent,
          ],
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
                    color: AppColors.onDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isConnected
                            ? AppColors.success
                            : AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isConnected
                          ? 'Холбогдсон · HD'
                          : 'Холбогдож байна...',
                      style: AppText.caption.copyWith(
                        color: isConnected
                            ? AppColors.success
                            : AppColors.goldMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.goldPrime.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.goldPrime.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _RecordingDot(),
                const SizedBox(width: 5),
                Text(
                  _elapsedText,
                  style: AppText.bodySmall.copyWith(
                    color: AppColors.goldPrime,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          if (onNote != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onNote,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.note_alt_outlined,
                  color: AppColors.goldPrime,
                  size: 18,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecordingDot extends StatefulWidget {
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
      opacity: Tween<double>(begin: 1.0, end: 0.3).animate(_ctrl),
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: AppColors.danger,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
