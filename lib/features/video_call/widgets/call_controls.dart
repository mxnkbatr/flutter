import 'dart:ui';

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
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: EdgeInsets.only(
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 12,
            left: 12,
            right: 12,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceEl.withOpacity(0.92),
            border: Border(
              top: BorderSide(color: AppColors.borderSub.withOpacity(0.9)),
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
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.danger.withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.call_end_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 6),
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
        ),
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
        opacity: enabled ? 1.0 : 0.35,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: active ? AppColors.orangeLight : AppColors.creamBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: active
                      ? AppColors.orange.withOpacity(0.35)
                      : AppColors.borderSub,
                ),
              ),
              child: Icon(
                icon,
                color: active ? AppColors.orange : AppColors.textSec,
                size: 22,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppText.caption.copyWith(
                color: AppColors.textSec,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
