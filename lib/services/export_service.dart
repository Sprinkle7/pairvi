import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/goshwara_case.dart';

class ExportService {
  final _currency = NumberFormat.currency(symbol: 'PKR ', decimalDigits: 2);
  final _dateFormat = DateFormat('dd MMM yyyy');

  Future<void> exportPdf(GoshwaraCalculationResult result) async {
    final doc = pw.Document();
    final input = result.input;

    final tableData = result.yearGroups
        .map(
          (group) => [
            group.year.toString(),
            _currency.format(group.perMonthAmount),
            group.monthCount.toString(),
            _currency.format(group.yearTotal),
          ],
        )
        .toList();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'In the Court of ${input.court}',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Goshwara Calculation Report',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          _pdfTopDetailsSection(result),
          pw.SizedBox(height: 24),
          pw.TableHelper.fromTextArray(
            headers: ['Year', 'Per Month', 'Months', 'Total Amount'],
            data: tableData,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 16),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Grand Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(
                  '${result.allMonths.length} months • ${_currency.format(result.grandTotal)}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ),
          if (result.payments.isNotEmpty) ...[
            pw.SizedBox(height: 24),
            _pdfPaymentsSection(result),
          ],
          pw.SizedBox(height: 16),
          _pdfAmountSummary(result),
          pw.SizedBox(height: 32),
          _pdfVerificationFooter(input.verificationStatus),
        ],
      ),
    );

    final bytes = await doc.save();
    final fileName = 'goshwara_${input.caseNo.replaceAll(RegExp(r'[^\w-]'), '_')}.pdf';
    await Printing.sharePdf(bytes: bytes, filename: fileName);
  }

  pw.Widget _pdfPaymentsSection(GoshwaraCalculationResult result) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(
          'Paid Amounts',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.TableHelper.fromTextArray(
          headers: ['Date', 'Amount', 'Order Sheet No.'],
          data: result.payments
              .map(
                (payment) => [
                  payment.date != null ? _dateFormat.format(payment.date!) : '—',
                  _currency.format(payment.amount),
                  payment.orderSheetNo,
                ],
              )
              .toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          cellAlignment: pw.Alignment.centerLeft,
          cellStyle: const pw.TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  pw.Widget _pdfAmountSummary(GoshwaraCalculationResult result) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        children: [
          _pdfSummaryRow('Total Amount Due', _currency.format(result.grandTotal)),
          pw.SizedBox(height: 6),
          _pdfSummaryRow('Total Paid', _currency.format(result.totalPaid)),
          pw.SizedBox(height: 6),
          _pdfSummaryRow('Total Remaining', _currency.format(result.totalRemaining), bold: true),
        ],
      ),
    );
  }

  pw.Widget _pdfSummaryRow(String label, String value, {bool bold = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        pw.Text(value, style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      ],
    );
  }

  pw.Widget _pdfTopDetailsSection(GoshwaraCalculationResult result) {
    final input = result.input;

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              _pdfInfoRow('Case No', input.caseNo),
              _pdfInfoRow('Title', input.title),
              _pdfInfoRow('Type', input.caseType),
              _pdfInfoRow('Person Name', input.personName),
              _pdfInfoRow('Degree Amount', _currency.format(input.degreeAmount)),
              _pdfInfoRow('Date From', _dateFormat.format(input.dateFrom)),
              _pdfInfoRow('Date To', _dateFormat.format(input.dateTo)),
              _pdfInfoRow('Annual Increment', '${input.percentage}%'),
              _pdfCurrentMonthRow(result),
            ],
          ),
        ),
        pw.SizedBox(width: 24),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              _pdfInfoRow('Dower', input.dower ?? ''),
              pw.SizedBox(height: 2),
              _pdfInfoRow('Dower Articles', input.dowerArticles ?? ''),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _pdfCurrentMonthRow(GoshwaraCalculationResult result) {
    final current = result.currentMonth;
    if (current == null) {
      return _pdfInfoRow('Current Amount', 'N/A (current month is outside the date range)');
    }

    return _pdfInfoRow(
      'Current Amount (${current.monthLabel} ${current.year})',
      _currency.format(current.amount),
    );
  }

  pw.Widget _pdfVerificationFooter(String verificationStatus) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey500),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Goshwara Verified/Finalized',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 6),
              pw.Text(verificationStatus, style: const pw.TextStyle(fontSize: 11)),
            ],
          ),
        ),
        pw.SizedBox(height: 28),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Expanded(child: _pdfSignatoryBlock('Signature')),
            pw.SizedBox(width: 20),
            pw.Expanded(child: _pdfSignatoryBlock('Stamp')),
            pw.SizedBox(width: 20),
            pw.Expanded(child: _pdfSignatoryBlock('Date')),
          ],
        ),
      ],
    );
  }

  pw.Widget _pdfSignatoryBlock(String label) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Container(
          height: label == 'Stamp' ? 70 : 50,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
            borderRadius: pw.BorderRadius.circular(4),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Text(
            label,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ),
      ],
    );
  }

  pw.Widget _pdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 130,
            child: pw.Text('$label:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }
}
