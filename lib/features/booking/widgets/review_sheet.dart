import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';

class ReviewSheet extends ConsumerStatefulWidget {
  const ReviewSheet({
    super.key,
    required this.monkId,
    required this.bookingId,
    required this.monkName,
  });

  final String monkId;
  final String bookingId;
  final String monkName;

  @override
  ConsumerState<ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends ConsumerState<ReviewSheet> {
  int _rating = 5;
  final _commentCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(apiClientProvider).post(
        '/monks/${widget.monkId}/reviews',
        data: {
          'rating': _rating,
          'comment': _commentCtrl.text.trim(),
          'bookingId': widget.bookingId,
        },
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (_) {
      setState(() {
        _error = 'Алдаа гарлаа. Дахин оролдоно уу.';
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text('Сэтгэгдэл бичих', style: AppText.h3),
            const SizedBox(height: 4),
            Text(
              widget.monkName,
              style: AppText.bodySmall.copyWith(color: AppColors.textSec),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final star = i + 1;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _rating = star);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      star <= _rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 40,
                      color: AppColors.goldPrime,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              _ratingLabel(_rating),
              style: AppText.bodySmall.copyWith(
                color: AppColors.saffronDeep,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _commentCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Сэтгэгдлээ бичнэ үү (заавал биш)',
                hintStyle: AppText.bodySmall.copyWith(color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.surfaceEl,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border, width: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border, width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.goldPrime, width: 1.5),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: AppText.bodySmall.copyWith(color: AppColors.danger),
              ),
            ],
            const SizedBox(height: 20),
            SacredButton(
              label: 'Илгээх',
              isLoading: _submitting,
              onTap: _submitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  String _ratingLabel(int r) => switch (r) {
        5 => 'Маш сайн',
        4 => 'Сайн',
        3 => 'Дунд',
        2 => 'Муу',
        _ => 'Маш муу',
      };
}
