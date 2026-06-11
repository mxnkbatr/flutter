import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/admin/models/admin_monk.dart';
import 'package:sacred_app/features/admin/providers/admin_providers.dart';
import 'package:sacred_app/shared/widgets/sacred_avatar.dart';
import 'package:sacred_app/shared/widgets/sacred_card.dart';
import 'package:sacred_app/shared/widgets/sacred_confirm_dialog.dart';

class PendingMonkCard extends ConsumerWidget {
  const PendingMonkCard({super.key, required this.monk});

  final AdminMonk monk;

  String _fmtDate(String? raw) {
    if (raw == null) return '—';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return DateFormat('yyyy.MM.dd').format(dt);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: Key(monk.id),
        resizeDuration: Duration.zero,
        background: Container(
          color: AppColors.success,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          child: Row(
            children: [
              const Icon(Icons.check_rounded, color: AppColors.onDark),
              const SizedBox(width: 8),
              Text(
                'Батлах',
                style: AppText.body.copyWith(color: AppColors.onDark),
              ),
            ],
          ),
        ),
        secondaryBackground: Container(
          color: AppColors.danger,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Татгалзах',
                style: AppText.body.copyWith(color: AppColors.onDark),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.close_rounded, color: AppColors.onDark),
            ],
          ),
        ),
        confirmDismiss: (dir) async {
          if (dir == DismissDirection.startToEnd) {
            return showDialog<bool>(
              context: context,
              builder: (_) => SacredConfirmDialog(
                title: 'Лам батлах уу?',
                message: monk.displayName,
                confirmLabel: 'Батлах',
                confirmColor: AppColors.success,
              ),
            );
          }
          return showDialog<bool>(
            context: context,
            builder: (_) => SacredConfirmDialog(
              title: 'Татгалзах уу?',
              message: monk.displayName,
              confirmLabel: 'Татгалзах',
              confirmColor: AppColors.danger,
            ),
          );
        },
        onDismissed: (dir) {
          if (dir == DismissDirection.startToEnd) {
            approveMonk(ref, monk.id);
          } else {
            rejectMonk(ref, monk.id);
          }
        },
        child: SacredCard(
          child: Row(
            children: [
              SacredAvatar(
                url: monk.image,
                radius: 24,
                initials: monk.displayName.isNotEmpty
                    ? monk.displayName[0]
                    : '?',
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      monk.displayName,
                      style: AppText.body.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (monk.temple != null)
                      Text(monk.temple!, style: AppText.bodySmall),
                    Text(
                      'Бүртгэсэн: ${_fmtDate(monk.createdAt)}',
                      style: AppText.caption,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    'Swipe',
                    style: AppText.caption.copyWith(color: AppColors.textHint),
                  ),
                  const Icon(
                    Icons.swap_horiz_rounded,
                    size: 16,
                    color: AppColors.textHint,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
