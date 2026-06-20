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
      decoration: const BoxDecoration(gradient: AppGradients.heroInk),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              gradient: AppGradients.sun,
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
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
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: AppText.body.copyWith(color: AppColors.goldLight),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
