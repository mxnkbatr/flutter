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
    required this.onChat,
    required this.onNote,
  });

  final bool isMuted;
  final bool isCameraOff;
  final VoidCallback onMute;
  final VoidCallback onCamera;
  final VoidCallback onEnd;
  final VoidCallback onChat;
  final VoidCallback onNote;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        left: 24,
        right: 24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            AppColors.inkDeep,
            AppColors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _CtrlBtn(
            icon: isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
            label: isMuted ? 'Нэмэх' : 'Унтраах',
            onTap: onMute,
            active: !isMuted,
          ),
          _CtrlBtn(
            icon: isCameraOff
                ? Icons.videocam_off_rounded
                : Icons.videocam_rounded,
            label: isCameraOff ? 'Нэмэх' : 'Камер',
            onTap: onCamera,
            active: !isCameraOff,
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.heavyImpact();
              onEnd();
            },
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.danger.withOpacity(0.27),
                    blurRadius: 12,
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
          ),
          _CtrlBtn(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Мессэж',
            onTap: onChat,
            active: true,
          ),
          _CtrlBtn(
            icon: Icons.note_alt_outlined,
            label: 'Тэмдэглэл',
            onTap: onNote,
            active: true,
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
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: active ? AppColors.inkMid : AppColors.inkLight,
              shape: BoxShape.circle,
              border: Border.all(
                color: active ? AppColors.goldMuted : AppColors.border,
                width: 0.5,
              ),
            ),
            child: Icon(icon, color: AppColors.goldPrime, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppText.caption.copyWith(color: AppColors.goldMuted),
          ),
        ],
      ),
    );
  }
}
