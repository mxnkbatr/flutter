import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';

class SacredAvatar extends StatelessWidget {
  const SacredAvatar({
    super.key,
    this.url,
    this.radius = 24,
    this.initials,
  });

  final String? url;
  final double radius;
  final String? initials;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.borderSub,
      backgroundImage: url != null && url!.isNotEmpty
          ? CachedNetworkImageProvider(url!)
          : null,
      child: url == null || url!.isEmpty
          ? Text(
              initials ?? '?',
              style: TextStyle(
                color: AppColors.goldMuted,
                fontWeight: FontWeight.w600,
                fontSize: radius * 0.55,
              ),
            )
          : null,
    );
  }
}
