import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';

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
      width: 78,
      height: 104,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.goldPrime, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.inkDeep.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned.fill(
            child: isCameraOff || track == null
                ? const ColoredBox(
                    color: AppColors.inkMid,
                    child: Center(
                      child: Icon(
                        Icons.videocam_off_rounded,
                        color: AppColors.goldMuted,
                        size: 22,
                      ),
                    ),
                  )
                : VideoTrackRenderer(
                    track!,
                    fit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
          ),
          Positioned(
            left: 4,
            bottom: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Та',
                style: AppText.caption.copyWith(
                  color: AppColors.goldLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 9,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
