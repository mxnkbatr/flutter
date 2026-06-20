import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';

class ConnectingView extends StatefulWidget {
  const ConnectingView({
    super.key,
    required this.peerName,
    this.peerImage,
    required this.role,
    required this.onCancel,
  });

  final String peerName;
  final String? peerImage;
  final String role; // 'client' | 'monk'
  final VoidCallback onCancel;

  @override
  State<ConnectingView> createState() => _ConnectingViewState();
}

class _ConnectingViewState extends State<ConnectingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  String get _initial =>
      widget.peerName.isNotEmpty ? widget.peerName[0].toUpperCase() : '?';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.heroInk),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, __) {
                      final t = _pulseCtrl.value;
                      return Opacity(
                        opacity: (1 - t).clamp(0.0, 1.0),
                        child: Transform.scale(
                          scale: 0.9 + t * 0.4,
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.goldPrime.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, __) {
                      final t = (_pulseCtrl.value + 0.5) % 1.0;
                      return Opacity(
                        opacity: (1 - t).clamp(0.0, 1.0),
                        child: Transform.scale(
                          scale: 0.9 + t * 0.4,
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.goldPrime.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      gradient: AppGradients.sun,
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: widget.peerImage != null &&
                            widget.peerImage!.isNotEmpty
                        ? Image.network(
                            widget.peerImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                _initial,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              _initial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.peerName,
              style: AppText.h3.copyWith(color: Colors.white, fontSize: 17),
            ),
            const SizedBox(height: 4),
            Text(
              'Холбогдож байна...',
              style: AppText.bodySmall.copyWith(color: AppColors.goldMuted),
            ),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, __) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final t = (_pulseCtrl.value * 3 - i) % 3;
                    final opacity = t < 1
                        ? (0.2 + 0.8 * (1 - (t - 0.3).abs() / 0.7))
                            .clamp(0.2, 1.0)
                        : 0.2;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.goldPrime.withOpacity(opacity),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onCancel();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  'Цуцлах',
                  style: AppText.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
