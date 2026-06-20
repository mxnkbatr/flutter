import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';

class CallControls extends StatelessWidget {
  const CallControls({
    super.key,
    required this.isMuted,
    required this.isCameraOff,
    required this.onMute,
    required this.onCamera,
    required this.onEnd,
    required this.onNote,
    this.onSwitchCamera,
  });

  final bool isMuted;
  final bool isCameraOff;
  final VoidCallback onMute;
  final VoidCallback onCamera;
  final VoidCallback onEnd;
  final VoidCallback onNote;
  final VoidCallback? onSwitchCamera;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            AppColors.inkDeep,
            AppColors.inkDeep.withOpacity(0.5),
            AppColors.transparent,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _CtrlBtn(
            icon: isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
            label: 'Дуу',
            onTap: onMute,
            active: !isMuted,
          ),
          _CtrlBtn(
            icon: isCameraOff
                ? Icons.videocam_off_rounded
                : Icons.videocam_rounded,
            label: 'Камер',
            onTap: onCamera,
            active: !isCameraOff,
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.heavyImpact();
              onEnd();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.danger.withOpacity(0.4),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.call_end_rounded,
                    color: AppColors.onDark,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Дуусгах',
                  style: AppText.caption.copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          _CtrlBtn(
            icon: Icons.cameraswitch_rounded,
            label: 'Сэлгэх',
            onTap: onSwitchCamera ?? () {},
            active: false,
            enabled: onSwitchCamera != null,
          ),
          _CtrlBtn(
            icon: Icons.note_alt_outlined,
            label: 'Тэмдэглэл',
            onTap: onNote,
            active: false,
          ),
        ],
      ),
    );
  }
}

class _CtrlBtn extends StatelessWidget {
  const _CtrlBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.active,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled
          ? () {
              HapticFeedback.lightImpact();
              onTap();
            }
          : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: active
                    ? AppColors.goldPrime.withOpacity(0.12)
                    : Colors.white.withOpacity(0.06),
                shape: BoxShape.circle,
                border: Border.all(
                  color: active
                      ? AppColors.goldPrime.withOpacity(0.25)
                      : Colors.white.withOpacity(0.08),
                  width: 0.5,
                ),
              ),
              child: Icon(
                icon,
                color: active ? AppColors.goldPrime : AppColors.goldMuted,
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppText.caption.copyWith(
                color: Colors.white.withOpacity(0.4),
                fontWeight: FontWeight.w600,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
