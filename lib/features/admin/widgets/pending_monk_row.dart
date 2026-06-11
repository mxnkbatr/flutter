import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/admin/models/admin_monk.dart';
import 'package:sacred_app/features/admin/providers/admin_providers.dart';
import 'package:sacred_app/features/admin/widgets/small_admin_btn.dart';

class PendingMonkRow extends ConsumerStatefulWidget {
  const PendingMonkRow({super.key, required this.monk});

  final AdminMonk monk;

  @override
  ConsumerState<PendingMonkRow> createState() => _PendingMonkRowState();
}

class _PendingMonkRowState extends ConsumerState<PendingMonkRow> {
  bool _pulse = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _pulse = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            width: _pulse ? 8 : 12,
            height: _pulse ? 8 : 12,
            decoration: BoxDecoration(
              color: AppColors.warning,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.warning.withOpacity(_pulse ? 0.4 : 0.1),
                  blurRadius: _pulse ? 6 : 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.borderSub,
            backgroundImage: widget.monk.image != null && widget.monk.image!.isNotEmpty
                ? CachedNetworkImageProvider(widget.monk.image!)
                : null,
            child: widget.monk.image == null || widget.monk.image!.isEmpty
                ? const Icon(Icons.person, size: 18)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.monk.displayName, style: AppText.body),
                if (widget.monk.temple != null)
                  Text(widget.monk.temple!, style: AppText.bodySmall),
              ],
            ),
          ),
          SmallAdminBtn(
            label: 'Батлах',
            color: AppColors.success,
            onTap: () => approveMonk(ref, widget.monk.id),
          ),
          const SizedBox(width: 6),
          SmallAdminBtn(
            label: 'Татгалзах',
            color: AppColors.danger,
            outline: true,
            onTap: () => rejectMonk(ref, widget.monk.id),
          ),
        ],
      ),
    );
  }
}
