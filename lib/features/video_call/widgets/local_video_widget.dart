import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
class LocalVideoWidget extends StatelessWidget {
  const LocalVideoWidget({
    super.key,
    required this.track,
    required this.isCameraOff,
  });

  final VideoTrack? track;
  final bool isCameraOff;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.goldPrime, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.inkDeep.withOpacity(0.4),
            blurRadius: 8,
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: isCameraOff || track == null
          ? ColoredBox(
              color: AppColors.inkMid,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.videocam_off_rounded,
                    color: AppColors.goldMuted,
                    size: 24,
                  ),
                ],
              ),
            )
          : VideoTrackRenderer(
              track!,
              fit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
    );
  }
}
