import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/shared/widgets/auth_ambient_scaffold.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';

/// Уулзалт эхлэхээс өмнө монгол хэлээр камер/микрофон тайлбарлана.
/// Системийн (англи) popup-аас өмнө харагдана.
class CallPermissionPrepView extends StatelessWidget {
  const CallPermissionPrepView({
    super.key,
    required this.onAllow,
    required this.onCancel,
    this.isLoading = false,
  });

  final VoidCallback onAllow;
  final VoidCallback onCancel;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBg,
      body: Stack(
        children: [
          const AuthAmbientBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: isLoading ? null : onCancel,
                      icon: const Icon(Icons.close_rounded),
                      color: AppColors.inkDeep,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Уулзалтын зөвшөөрөл',
                    style: AppText.displaySerif(
                      size: 28,
                      color: AppColors.inkDeep,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Ламтай ярихын тулд дараах зөвшөөрөл хэрэгтэй.',
                    style: AppText.body.copyWith(
                      color: AppColors.inkMid,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  const _PermissionCard(
                    icon: Icons.mic_rounded,
                    title: 'Микрофон — заавал',
                    body: 'Таны дуу ламд сонсогдоно.',
                  ),
                  const SizedBox(height: 12),
                  const _PermissionCard(
                    icon: Icons.videocam_rounded,
                    title: 'Камер — сонголттой',
                    body: 'Зөвшөөрөхгүй бол зөвхөн дуугаар уулзаж болно.',
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceEl,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: Text(
                      'Дараагийн цонхонд «Allow» эсвэл «Зөвшөөрөх» товчийг дарна уу.\n\n'
                      'Хэрэв утасны хэл англи бол товч «Allow» гэж харагдана — түүнийг дарна.',
                      style: AppText.bodySmall.copyWith(
                        color: AppColors.inkMid,
                        height: 1.55,
                      ),
                    ),
                  ),
                  const Spacer(),
                  SacredButton(
                    label: 'Зөвшөөрөх',
                    prominent: true,
                    isLoading: isLoading,
                    onTap: isLoading
                        ? null
                        : () {
                            HapticFeedback.lightImpact();
                            onAllow();
                          },
                  ),
                  const SizedBox(height: 12),
                  SacredButton(
                    label: 'Буцах',
                    outline: true,
                    onTap: isLoading ? null : onCancel,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceEl,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.orange, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppText.body.copyWith(
                    color: AppColors.inkDeep,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: AppText.bodySmall.copyWith(
                    color: AppColors.inkMid,
                    height: 1.45,
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
