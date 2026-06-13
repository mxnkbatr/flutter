import 'package:flutter/material.dart';
import 'package:sacred_app/core/constants/app_branding.dart';

class GevabalLogo extends StatelessWidget {
  const GevabalLogo({
    super.key,
    this.size = 80,
    this.showName = false,
    this.nameStyle,
    this.tagline,
    this.taglineStyle,
  });

  final double size;
  final bool showName;
  final TextStyle? nameStyle;
  final String? tagline;
  final TextStyle? taglineStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.18),
          child: Image.asset(
            AppBranding.logoAsset,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
        if (showName) ...[
          const SizedBox(height: 12),
          Text(
            AppBranding.name,
            style: nameStyle,
          ),
          if (tagline != null) ...[
            const SizedBox(height: 4),
            Text(
              tagline!,
              style: taglineStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ],
    );
  }
}
