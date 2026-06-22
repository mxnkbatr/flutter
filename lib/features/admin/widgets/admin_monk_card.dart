import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/admin/models/admin_monk.dart';
import 'package:sacred_app/features/admin/providers/admin_providers.dart';
import 'package:sacred_app/features/admin/widgets/admin_page_scaffold.dart';
import 'package:sacred_app/features/monk_dash/widgets/status_badge.dart';

class AdminMonkCard extends ConsumerWidget {
  const AdminMonkCard({
    super.key,
    required this.monk,
    this.showReorderHandle = false,
    this.reorderIndex = 0,
  });

  final AdminMonk monk;
  final bool showReorderHandle;
  final int reorderIndex;

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

  void _showActionMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceEl,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.person_outline, color: AppColors.goldPrime),
                  const SizedBox(width: 10),
                  Text(monk.displayName, style: AppText.h3),
                ],
              ),
            ),
            const Divider(height: 24),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Мэдээлэл засах'),
              onTap: () {
                Navigator.pop(context);
                context.push('/admin/monks/edit/${monk.id}');
              },
            ),
            if (monk.status == 'pending' || monk.status == 'blocked')
              ListTile(
                leading: const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.success,
                ),
                title: const Text(
                  'Батлах',
                  style: TextStyle(color: AppColors.success),
                ),
                onTap: () {
                  Navigator.pop(context);
                  approveMonk(ref, monk.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${monk.displayName} батлагдлаа')),
                  );
                },
              ),
            if (monk.status == 'active')
              ListTile(
                leading: const Icon(Icons.block_rounded, color: AppColors.warning),
                title: const Text(
                  'Хаах',
                  style: TextStyle(color: AppColors.warning),
                ),
                onTap: () {
                  Navigator.pop(context);
                  rejectMonk(ref, monk.id);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.danger),
              title: const Text(
                'Бүртгэл устгах',
                style: TextStyle(color: AppColors.danger),
              ),
              onTap: () async {
                Navigator.pop(context);
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Лам устгах уу?'),
                    content: Text(
                      '${monk.displayName}-н бүх захиалга, чат устана. Буцаах боломжгүй.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Болих'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.danger,
                        ),
                        child: const Text('Устгах'),
                      ),
                    ],
                  ),
                );
                if (ok == true) {
                  try {
                    await deleteMonkWithForceIfNeeded(
                      ref,
                      monk.id,
                      confirmForce: (msg) => showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Идэвхтэй захиалга'),
                          content: Text(
                            '$msg\n\nЗахиалгуудыг цуцлаад устгах уу?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Болих'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.danger,
                              ),
                              child: const Text('Цуцлаад устгах'),
                            ),
                          ],
                        ),
                      ),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${monk.displayName} устгагдлаа'),
                          backgroundColor: AppColors.danger,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(formatUserError(e)),
                          backgroundColor: AppColors.danger,
                        ),
                      );
                    }
                  }
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _cardBody() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AdminSurfaceCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            if (showReorderHandle)
              ReorderableDragStartListener(
                index: reorderIndex,
                child: const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.drag_handle, color: AppColors.textSec),
                ),
              ),
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
                      if (monk.isSpecial) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.goldPrime.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Онцгой',
                            style: AppText.caption.copyWith(
                              color: AppColors.goldPrime,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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
            if (!showReorderHandle)
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSec),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = _cardBody();

    if (showReorderHandle) {
      return card;
    }

    return GestureDetector(
      onTap: () => context.push('/admin/monks/edit/${monk.id}'),
      onLongPress: () => _showActionMenu(context, ref),
      child: Dismissible(
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
        child: card,
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
