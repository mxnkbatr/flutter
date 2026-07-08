import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/admin/widgets/admin_logout_button.dart';

/// Unified admin top bar — brand left, exit right. Shown once in [AdminShell].
class AdminShellHeader extends StatelessWidget {
  const AdminShellHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.creamBg,
        border: Border(
          bottom: BorderSide(color: AppColors.borderSub.withOpacity(0.85)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.orange.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 16, 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.orange.withOpacity(0.22),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.admin_panel_settings_outlined,
                color: Colors.white,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gevabal',
                    style: AppText.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkDeep,
                      letterSpacing: 0.2,
                    ),
                  ),
                  Text(
                    'Админ самбар',
                    style: AppText.caption.copyWith(
                      fontSize: 11,
                      color: AppColors.textSec,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const AdminLogoutButton(),
          ],
        ),
      ),
    );
  }
}
