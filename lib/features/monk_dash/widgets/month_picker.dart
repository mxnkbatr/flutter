import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';

class MonthPicker extends StatelessWidget {
  const MonthPicker({
    super.key,
    required this.selectedMonth,
    required this.onChanged,
  });

  final String selectedMonth;
  final ValueChanged<String> onChanged;

  String _displayLabel(String month) {
    try {
      final date = DateFormat('yyyy-MM').parse(month);
      return DateFormat('yyyy оны MM сар').format(date);
    } catch (_) {
      return month;
    }
  }

  Future<void> _showSheet(BuildContext context) async {
    final now = DateTime.now();
    final months = List.generate(12, (i) {
      final d = DateTime(now.year, now.month - i);
      return DateFormat('yyyy-MM').format(d);
    });

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceEl,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Сар сонгох', style: AppText.h3),
              ),
              ...months.map((m) {
                final selected = m == selectedMonth;
                return ListTile(
                  title: Text(_displayLabel(m)),
                  trailing: selected
                      ? const Icon(Icons.check, color: AppColors.goldPrime)
                      : null,
                  onTap: () {
                    onChanged(m);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceEl,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_outlined, color: AppColors.goldMuted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(_displayLabel(selectedMonth), style: AppText.body),
            ),
            const Icon(Icons.expand_more, color: AppColors.textSec),
          ],
        ),
      ),
    );
  }
}
