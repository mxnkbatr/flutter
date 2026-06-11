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
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.inkDeep.withOpacity(0.9),
            AppColors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  monkName,
                  style: AppText.h3.copyWith(color: AppColors.onDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
                    const SizedBox(width: 4),
                    Text(
                      isConnected ? 'Холбогдсон' : 'Холбогдож байна...',
                      style: AppText.caption.copyWith(
                        color: isConnected
                            ? AppColors.success
                            : AppColors.goldMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.inkMid.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _elapsedText,
              style: AppText.bodySmall.copyWith(
                color: AppColors.goldPrime,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (onNote != null) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(
                Icons.note_alt_outlined,
                color: AppColors.goldPrime,
              ),
              onPressed: onNote,
            ),
          ],
        ],
      ),
    );
  }
}
