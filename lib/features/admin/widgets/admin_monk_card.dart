import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/admin/models/admin_monk.dart';
import 'package:sacred_app/features/admin/providers/admin_providers.dart';
import 'package:sacred_app/features/monk_dash/widgets/status_badge.dart';
import 'package:sacred_app/shared/widgets/sacred_card.dart';

class AdminMonkCard extends ConsumerWidget {
  const AdminMonkCard({super.key, required this.monk});

  final AdminMonk monk;

  Future<bool> _confirmApprove(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Лам батлах уу?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Үгүй'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Тийм'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _confirmBlock(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Лам хаах уу?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Үгүй'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Тийм'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(monk.id),
      background: const _SwipeBackground(
        color: AppColors.success,
        icon: Icons.check,
        align: Alignment.centerLeft,
      ),
      secondaryBackground: const _SwipeBackground(
        color: AppColors.danger,
        icon: Icons.block,
        align: Alignment.centerRight,
      ),
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          return _confirmApprove(context);
        }
        return _confirmBlock(context);
      },
      onDismissed: (dir) {
        if (dir == DismissDirection.startToEnd) {
          approveMonk(ref, monk.id);
        } else {
          rejectMonk(ref, monk.id);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SacredCard(
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.borderSub,
                backgroundImage: monk.image != null && monk.image!.isNotEmpty
                    ? CachedNetworkImageProvider(monk.image!)
                    : null,
                child: monk.image == null || monk.image!.isEmpty
                    ? const Icon(Icons.person)
                    : null,
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
                    Row(
                      children: [
                        StatusBadge(status: monk.status),
                        const SizedBox(width: 8),
                        Text(
                          '★ ${monk.rating.toStringAsFixed(1)}',
                          style: AppText.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSec),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.color,
    required this.icon,
    required this.align,
  });

  final Color color;
  final IconData icon;
  final Alignment align;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      alignment: align,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Icon(icon, color: Colors.white),
    );
  }
}
