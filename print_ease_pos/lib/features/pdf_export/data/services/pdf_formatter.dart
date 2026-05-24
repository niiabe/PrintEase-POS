import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../receipts/data/models/receipt.dart';
import '../../../receipts/data/models/receipt_item.dart';
import '../../../templates/data/models/receipt_template.dart';

class PdfFormatter {
  final int paperWidth;
  final double taxPercentage;

  PdfFormatter({this.paperWidth = 80, this.taxPercentage = 0});

  PdfPageFormat get _pageFormat {
    final w = paperWidth * PdfPageFormat.mm;
    return PdfPageFormat(w, double.infinity);
  }

  Future<Uint8List> formatReceipt(Receipt receipt, {ReceiptTemplate? template}) async {
    final doc = pw.Document();

    Uint8List? logoBytes;
    if (template != null && template.showLogo && template.logoPath != null) {
      final logoFile = File(template.logoPath!);
      if (await logoFile.exists()) {
        logoBytes = await logoFile.readAsBytes();
      }
    }

    doc.addPage(
      pw.Page(
        pageFormat: _pageFormat,
        margin: const pw.EdgeInsets.all(4 * PdfPageFormat.mm),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _buildHeader(receipt, template: template, logoBytes: logoBytes),
            pw.Divider(),
            _buildItemsHeader(),
            ..._buildItems(receipt.items),
            pw.Divider(),
            _buildTotals(receipt),
            pw.Divider(),
            _buildFooter(template: template),
          ],
        ),
      ),
    );

    return await doc.save();
  }

  pw.Widget _buildHeader(Receipt receipt, {ReceiptTemplate? template, Uint8List? logoBytes}) {
    final displayStoreName = (template != null && template.storeName.isNotEmpty)
        ? template.storeName
        : receipt.storeName;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        if (logoBytes != null) ...[
          pw.Image(pw.MemoryImage(logoBytes), width: 80, height: 80),
          pw.SizedBox(height: 4),
        ],
        pw.Text(
          displayStoreName,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Receipt #${receipt.receiptNumber}',
          style: const pw.TextStyle(fontSize: 10),
        ),
        if (receipt.customerName.isNotEmpty)
          pw.Text(
            'Customer: ${receipt.customerName}',
            style: const pw.TextStyle(fontSize: 10),
          ),
        pw.Text(
          'Date: ${_formatDate(receipt.createdAt)}',
          style: const pw.TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  pw.Widget _buildItemsHeader() {
    return pw.Row(
      children: [
        pw.Expanded(
          flex: 6,
          child: pw.Text('Item',
              style: pw.TextStyle(
                  fontSize: 9, fontWeight: pw.FontWeight.bold)),
        ),
        pw.Expanded(
          flex: 2,
          child: pw.Text('Qty',
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                  fontSize: 9, fontWeight: pw.FontWeight.bold)),
        ),
        pw.Expanded(
          flex: 4,
          child: pw.Text('Total',
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                  fontSize: 9, fontWeight: pw.FontWeight.bold)),
        ),
      ],
    );
  }

  List<pw.Widget> _buildItems(List<ReceiptItem> items) {
    return items.map((item) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 1),
        child: pw.Row(
          children: [
            pw.Expanded(
              flex: 6,
              child: pw.Text(item.name, style: const pw.TextStyle(fontSize: 9)),
            ),
            pw.Expanded(
              flex: 2,
              child: pw.Text(
                '${item.quantity}',
                textAlign: pw.TextAlign.right,
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
            pw.Expanded(
              flex: 4,
              child: pw.Text(
                item.total.toStringAsFixed(2),
                textAlign: pw.TextAlign.right,
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  pw.Widget _buildTotals(Receipt receipt) {
    return pw.Column(
      children: [
        _totalRow('Subtotal', receipt.subtotal, ''),
        _totalRow('Tax (${taxPercentage.toStringAsFixed(1)}%)', receipt.tax, ''),
        pw.SizedBox(height: 2),
        _totalRow('TOTAL', receipt.total, receipt.currency, bold: true),
      ],
    );
  }

  pw.Widget _totalRow(String label, double amount, String currency,
      {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
          pw.Text(
            '$currency ${amount.toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter({ReceiptTemplate? template}) {
    final footerText = (template != null && template.footer.isNotEmpty)
        ? template.footer
        : 'Thank you for your patronage!';
    final showQr = template?.showQrCode ?? true;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.SizedBox(height: 8),
        pw.Text(
          footerText,
          style: const pw.TextStyle(fontSize: 10),
        ),
        if (showQr) ...[
          pw.SizedBox(height: 4),
          pw.BarcodeWidget(
            barcode: pw.Barcode.qrCode(),
            data: 'https://print-ease-pos.app',
            width: 50,
            height: 50,
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
