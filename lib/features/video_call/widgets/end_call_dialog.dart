import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';

class EndCallDialog extends StatelessWidget {
  const EndCallDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceEl,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: AppColors.borderSub),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.call_end_rounded,
                color: AppColors.danger,
                size: 26,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Дуудлага дуусгах уу?',
              style: AppText.displaySerif(size: 22, color: AppColors.inkDeep),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Дуудлага дууссаны дараа захиалга бүрэн дууссан гэж тэмдэглэгдэнэ.',
              style: AppText.bodySmall.copyWith(
                color: AppColors.textSec,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SacredButton(
              label: 'Дуусгах',
              onTap: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: 10),
            SacredButton(
              label: 'Үргэлжлүүлэх',
              outline: true,
              onTap: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}
