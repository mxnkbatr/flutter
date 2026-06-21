import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';

class WaitingView extends StatelessWidget {
  const WaitingView({
    super.key,
    required this.role,
    this.peerName,
    this.peerImage,
  });

  final String role;
  final String? peerName;
  final String? peerImage;

  String get _initial {
    final n = peerName ?? '';
    return n.isNotEmpty ? n[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final message = role == 'monk'
        ? 'Хэрэглэгч холбогдохыг хүлээж байна...'
        : '${peerName ?? "Лам"} холбогдохыг хүлээж байна...';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.inkDeep.withOpacity(0.92),
            AppColors.inkMid.withOpacity(0.88),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.primary,
              boxShadow: [
                BoxShadow(
                  color: AppColors.orange.withOpacity(0.35),
                  blurRadius: 24,
                ),
              ],
            ),
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surfaceEl,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.hardEdge,
              child: peerImage != null && peerImage!.isNotEmpty
                  ? Image.network(
                      peerImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          _initial,
                          style: AppText.displaySerif(
                            size: 32,
                            color: AppColors.orange,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        _initial,
                        style: AppText.displaySerif(
                          size: 32,
                          color: AppColors.orange,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: AppText.body.copyWith(color: Colors.white.withOpacity(0.9)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.orange.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }
}
