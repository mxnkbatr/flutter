import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Soft Ken Burns zoom — draws the eye without feeling flashy.
class ZoomingNetworkImage extends StatefulWidget {
  const ZoomingNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.alignment = const Alignment(0, -0.18),
    this.beginScale = 1.0,
    this.endScale = 1.12,
    this.duration = const Duration(seconds: 14),
    this.memCacheWidth,
    this.memCacheHeight,
    this.fadeInDuration = const Duration(milliseconds: 280),
    this.placeholder,
    this.errorWidget,
  });

  final String imageUrl;
  final BoxFit fit;
  final Alignment alignment;
  final double beginScale;
  final double endScale;
  final Duration duration;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final Duration fadeInDuration;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  State<ZoomingNetworkImage> createState() => _ZoomingNetworkImageState();
}

class _ZoomingNetworkImageState extends State<ZoomingNetworkImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scale = Tween<double>(
      begin: widget.beginScale,
      end: widget.endScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          alignment: widget.alignment,
          child: child,
        ),
        child: CachedNetworkImage(
          imageUrl: widget.imageUrl,
          fit: widget.fit,
          alignment: widget.alignment,
          memCacheWidth: widget.memCacheWidth,
          memCacheHeight: widget.memCacheHeight,
          fadeInDuration: widget.fadeInDuration,
          placeholder: (_, __) =>
              widget.placeholder ?? const ColoredBox(color: Color(0xFFFFE8D6)),
          errorWidget: (_, __, ___) =>
              widget.errorWidget ??
              (widget.placeholder ?? const ColoredBox(color: Color(0xFFFFE8D6))),
        ),
      ),
    );
  }
}
