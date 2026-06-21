import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

/// iOS-style spring press — subtle scale with elastic release.
class ScaleTap extends StatefulWidget {
  const ScaleTap({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.96,
    this.enableHaptic = true,
    this.hapticOnPress = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final bool enableHaptic;
  /// When true, fires [HapticFeedback.lightImpact] on press-down (button feel).
  final bool hapticOnPress;

  @override
  State<ScaleTap> createState() => _ScaleTapState();
}

class _ScaleTapState extends State<ScaleTap> with SingleTickerProviderStateMixin {
  static const _pressSpring = SpringDescription(
    mass: 0.35,
    stiffness: 520,
    damping: 24,
  );
  static const _releaseSpring = SpringDescription(
    mass: 0.45,
    stiffness: 280,
    damping: 13,
  );

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this, value: 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _springTo(double target, {required bool releasing}) {
    _controller.animateWith(
      SpringSimulation(
        releasing ? _releaseSpring : _pressSpring,
        _controller.value,
        target,
        _controller.velocity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled
          ? (_) {
              if (widget.enableHaptic && widget.hapticOnPress) {
                HapticFeedback.lightImpact();
              }
              _springTo(widget.pressedScale, releasing: false);
            }
          : null,
      onTapUp: enabled ? (_) => _springTo(1.0, releasing: true) : null,
      onTapCancel: enabled ? () => _springTo(1.0, releasing: true) : null,
      onTap: enabled
          ? () {
              if (widget.enableHaptic && !widget.hapticOnPress) {
                HapticFeedback.lightImpact();
              }
              widget.onTap!();
            }
          : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _controller.value.clamp(0.85, 1.05),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
