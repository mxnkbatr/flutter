import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/shared/widgets/auth_ambient_scaffold.dart';

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
  final String role;
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
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
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
    return Scaffold(
      backgroundColor: AppColors.creamBg,
      body: Stack(
        children: [
          const AuthAmbientBackground(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                Text(
                  'Видео дуудлага',
                  style: AppText.displaySerif(size: 26, color: AppColors.inkDeep),
                ),
                const Spacer(),
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + _pulseCtrl.value * 0.04,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppGradients.primary,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.orange.withOpacity(0.28),
                          blurRadius: 28,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceEl,
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
                                  style: AppText.displaySerif(
                                    size: 40,
                                    color: AppColors.orange,
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                _initial,
                                style: AppText.displaySerif(
                                  size: 40,
                                  color: AppColors.orange,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  widget.peerName,
                  style: AppText.h2.copyWith(color: AppColors.inkDeep),
                ),
                const SizedBox(height: 8),
                Text(
                  'Холбогдож байна...',
                  style: AppText.bodySmall.copyWith(color: AppColors.textSec),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.orange.withOpacity(0.8),
                  ),
                ),
                const Spacer(flex: 2),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      widget.onCancel();
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      side: BorderSide(color: AppColors.orange.withOpacity(0.4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Цуцлах',
                      style: AppText.body.copyWith(
                        color: AppColors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
