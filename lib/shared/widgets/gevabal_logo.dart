import 'package:flutter/material.dart';
import 'package:sacred_app/core/constants/app_branding.dart';
import 'package:sacred_app/core/theme/app_colors.dart';

/// Transparent PNG brand mark — tall Buddhist emblem (~376×542).
class GevabalLogo extends StatelessWidget {
  const GevabalLogo({
    super.key,
    this.height = 96,
    this.showName = false,
    this.nameStyle,
    this.tagline,
    this.taglineStyle,
    this.glow = true,
  });

  /// Visual height; width follows natural aspect ratio.
  final double height;
  final bool showName;
  final TextStyle? nameStyle;
  final String? tagline;
  final TextStyle? taglineStyle;
  final bool glow;

  static const _aspectRatio = 339 / 736;

  @override
  Widget build(BuildContext context) {
    final width = height * _aspectRatio;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: width,
          height: height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (glow)
                Container(
                  width: width * 0.92,
                  height: height * 0.55,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.orange.withOpacity(0.22),
                        blurRadius: height * 0.28,
                        spreadRadius: height * 0.04,
                      ),
                      BoxShadow(
                        color: AppColors.goldPrime.withOpacity(0.18),
                        blurRadius: height * 0.18,
                      ),
                    ],
                  ),
                ),
              Image.asset(
                AppBranding.logoAsset,
                width: width,
                height: height,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ],
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
