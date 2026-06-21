import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/shared/widgets/auth_ambient_scaffold.dart';

/// Full-screen phone-like incoming call UI.
class IncomingCallOverlay extends StatefulWidget {
  const IncomingCallOverlay({
    super.key,
    required this.callerName,
    required this.callerImage,
    required this.isScheduledStart,
    required this.onAccept,
    required this.onDecline,
  });

  final String callerName;
  final String callerImage;
  final bool isScheduledStart;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  State<IncomingCallOverlay> createState() => _IncomingCallOverlayState();
}

class _IncomingCallOverlayState extends State<IncomingCallOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  Timer? _hapticTimer;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _startRingFeedback();
  }

  void _startRingFeedback() {
    HapticFeedback.mediumImpact();
    _hapticTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      HapticFeedback.mediumImpact();
    });
  }

  @override
  void dispose() {
    _hapticTimer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  String get _initial =>
      widget.callerName.isNotEmpty ? widget.callerName[0].toUpperCase() : '?';

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Material(
      color: AppColors.creamBg,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const AuthAmbientBackground(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 32),
                Text(
                  widget.isScheduledStart
                      ? 'Уулзалтын цаг боллоо'
                      : 'Орж ирж буй дуудлага',
                  style: AppText.body.copyWith(
                    color: AppColors.textSec,
                    letterSpacing: 0.3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gevabal видео дуудлага',
                  style: AppText.caption.copyWith(color: AppColors.textHint),
                ),
                const Spacer(),
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + _pulseCtrl.value * 0.05,
                      child: child,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppGradients.primary,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.orange.withOpacity(0.32),
                          blurRadius: 32,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Container(
                      width: 144,
                      height: 144,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceEl,
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: widget.callerImage.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: widget.callerImage,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Center(
                                child: Text(
                                  _initial,
                                  style: AppText.displaySerif(
                                    size: 48,
                                    color: AppColors.orange,
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                _initial,
                                style: AppText.displaySerif(
                                  size: 48,
                                  color: AppColors.orange,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  widget.callerName,
                  style: AppText.displaySerif(
                    size: 30,
                    color: AppColors.inkDeep,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  widget.isScheduledStart
                      ? 'Одоо видео дуудлагад орох боломжтой'
                      : 'Танд видео дуудлага хийж байна...',
                  style: AppText.bodySmall.copyWith(color: AppColors.textSec),
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 2),
                Padding(
                  padding: EdgeInsets.fromLTRB(40, 0, 40, bottom + 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CallActionButton(
                        label: 'Татгалзах',
                        icon: Icons.call_end_rounded,
                        color: AppColors.danger,
                        onTap: widget.onDecline,
                      ),
                      _CallActionButton(
                        label: 'Залгах',
                        icon: Icons.videocam_rounded,
                        color: AppColors.success,
                        onTap: widget.onAccept,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CallActionButton extends StatelessWidget {
  const _CallActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: AppText.caption.copyWith(
            color: AppColors.textSec,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
