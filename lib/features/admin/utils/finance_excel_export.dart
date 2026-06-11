import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sacred_app/features/admin/models/admin_finance_data.dart';
import 'package:sacred_app/features/admin/utils/admin_format.dart';

Future<String?> exportFinanceExcel(AdminFinanceData finance) async {
  final excel = Excel.createExcel();
  final sheet = excel['Санхүү'];
  excel.delete('Sheet1');

  sheet.appendRow([TextCellValue('Сар'), TextCellValue(finance.month)]);
  sheet.appendRow([
    TextCellValue('Нийт орлого'),
    TextCellValue('₮${fmtAdmin(finance.totalRevenue)}'),
  ]);
  sheet.appendRow([
    TextCellValue('Платформын хураамж'),
    TextCellValue('₮${fmtAdmin(finance.platformFees)}'),
  ]);
  sheet.appendRow([
    TextCellValue('QPay шимтгэл'),
    TextCellValue('₮${fmtAdmin(finance.qpayFees)}'),
  ]);
  sheet.appendRow([
    TextCellValue('Цэвэр ашиг'),
    TextCellValue('₮${fmtAdmin(finance.netProfit)}'),
  ]);
  sheet.appendRow([TextCellValue('')]);
  sheet.appendRow([
    TextCellValue('Лам'),
    TextCellValue('Захиалга'),
    TextCellValue('Цэвэр орлого'),
  ]);

  for (final s in finance.monkSalaries) {
    sheet.appendRow([
      TextCellValue(s.monkName),
      IntCellValue(s.bookingCount),
      TextCellValue('₮${fmtAdmin(s.netEarnings)}'),
    ]);
  }

  final bytes = excel.encode();
  if (bytes == null) return null;

  final dir = await getApplicationDocumentsDirectory();
  final path = '${dir.path}/sacred-finance-${finance.month}.xlsx';
  await File(path).writeAsBytes(bytes);
  return path;
}
