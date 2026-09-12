import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/shared/widgets/auth_ambient_scaffold.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';

/// Апп нэвтэрсний дараа — мэдэгдэл/микрофон Allow дарахыг монголоор заана.
class AppPermissionPrepOverlay extends StatelessWidget {
  const AppPermissionPrepOverlay({
    super.key,
    required this.onContinue,
    required this.onSkip,
    this.isLoading = false,
    this.alreadyDenied = false,
  });

  final VoidCallback onContinue;
  final VoidCallback onSkip;
  final bool isLoading;
  final bool alreadyDenied;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.creamBg,
      child: Stack(
        children: [
          const AuthAmbientBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isLoading ? null : onSkip,
                      child: Text(
                        'Дараа',
                        style: AppText.bodySmall.copyWith(
                          color: AppColors.textSec,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Зөвшөөрөл шаардлагатай',
                    style: AppText.displaySerif(
                      size: 28,
                      color: AppColors.inkDeep,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    alreadyDenied
                        ? 'Мэдэгдэл эсвэл микрофон хаалттай байна. Тохиргооноос асаана уу.'
                        : 'Дуудлага, захиалгын мэдэгдэл авахын тулд дараах зөвшөөрлийг өгнө үү.',
                    style: AppText.body.copyWith(
                      color: AppColors.inkMid,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  const _PermCard(
                    icon: Icons.notifications_active_rounded,
                    title: 'Мэдэгдэл',
                    body: 'Дуудлага ирэх, захиалгын цаг сануулахад хэрэгтэй.',
                  ),
                  const SizedBox(height: 12),
                  const _PermCard(
                    icon: Icons.mic_rounded,
                    title: 'Микрофон',
                    body: 'Ламтай ярихын тулд заавал хэрэгтэй.',
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
                      alreadyDenied
                          ? 'Тохиргоо → Gevabal → Мэдэгдэл болон Микрофон-ыг асаагаад апп руу буцна уу.'
                          : 'Дараагийн цонхонд «Allow» эсвэл «Зөвшөөрөх» товчийг дарна уу.\n\n'
                              'Утасны хэл англи бол товч «Allow» гэж харагдана — түүнийг дарна.',
                      style: AppText.bodySmall.copyWith(
                        color: AppColors.inkMid,
                        height: 1.55,
                      ),
                    ),
                  ),
                  const Spacer(),
                  SacredButton(
                    label: alreadyDenied ? 'Ойлголоо' : 'Зөвшөөрөх',
                    prominent: true,
                    isLoading: isLoading,
                    onTap: isLoading
                        ? null
                        : () {
                            HapticFeedback.lightImpact();
                            onContinue();
                          },
                  ),
                  if (!alreadyDenied) ...[
                    const SizedBox(height: 12),
                    SacredButton(
                      label: 'Одоо биш',
                      outline: true,
                      onTap: isLoading ? null : onSkip,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermCard extends StatelessWidget {
  const _PermCard({
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
