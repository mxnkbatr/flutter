import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:sacred_app/features/monk_dash/models/monk_earnings_data.dart';
import 'package:sacred_app/features/monk_dash/utils/monk_dash_format.dart';

Future<void> exportEarningsPdf(MonkEarningsData earnings) async {
  final doc = pw.Document();

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [
        pw.Text(
          'Цалин тооцоо — ${earnings.month}',
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 16),
        pw.Text('Дууссан захиалга: ${earnings.completedCount}'),
        pw.Text('Нийт дүн: ₮${fmtCurrency(earnings.grossAmount)}'),
        pw.Text('Платформ (20%): -₮${fmtCurrency(earnings.platformFee)}'),
        pw.Text('QPay (1.5%): -₮${fmtCurrency(earnings.qpayFee)}'),
        pw.Text(
          'Цэвэр орлого: ₮${fmtCurrency(earnings.netEarnings)}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 20),
        pw.Text('Захиалгууд', style: pw.TextStyle(fontSize: 14)),
        pw.SizedBox(height: 8),
        ...earnings.transactions.map(
          (t) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    '${t.date} — ${t.clientName}\n${t.serviceName}',
                  ),
                ),
                pw.Text('₮${fmtCurrency(t.monkEarns)}'),
              ],
            ),
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Text(
          'Үүсгэсэн: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 9),
        ),
      ],
    ),
  );

  await Printing.layoutPdf(
    onLayout: (format) async => doc.save(),
    name: 'sacred-salary-${earnings.month}.pdf',
  );
}
