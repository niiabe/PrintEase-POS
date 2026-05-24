import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:image/image.dart' as img;
import '../../../receipts/data/models/receipt.dart';
import '../../../receipts/data/models/receipt_item.dart';
import '../../../templates/data/models/receipt_template.dart';

class EscPosFormatter {
  final int paperWidth;
  final double taxPercentage;

  EscPosFormatter({this.paperWidth = 80, this.taxPercentage = 0});

  PaperSize get _paperSize =>
      paperWidth == 58 ? PaperSize.mm58 : PaperSize.mm80;

  Future<List<int>> formatReceipt(Receipt receipt, {ReceiptTemplate? template}) async {
    final profile = await CapabilityProfile.load();
    final gen = Generator(_paperSize, profile);

    img.Image? logoImage;
    if (template != null && template.showLogo && template.logoPath != null) {
      logoImage = await _loadLogo(template.logoPath!);
    }

    var bytes = <int>[];

    bytes += await _buildHeader(gen, receipt, template: template, logoImage: logoImage);
    bytes += _buildItems(gen, receipt.items);
    bytes += _buildTotals(gen, receipt);
    bytes += _buildFooter(gen);
    bytes += gen.cut();

    return bytes;
  }

  Future<img.Image?> _loadLogo(String logoPath) async {
    try {
      final file = File(logoPath);
      if (!await file.exists()) return null;
      final Uint8List bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return null;
      final maxW = _paperSize == PaperSize.mm58 ? 200 : 320;
      if (image.width > maxW) {
        final scale = maxW / image.width;
        return img.copyResize(image, width: maxW, height: (image.height * scale).round());
      }
      return image;
    } catch (_) {
      return null;
    }
  }

  Future<List<int>> _buildHeader(Generator gen, Receipt receipt, {ReceiptTemplate? template, img.Image? logoImage}) async {
    var bytes = <int>[];
    if (logoImage != null) {
      bytes += gen.image(logoImage);
      bytes += gen.feed(1);
    }
    final displayStoreName = (template != null && template.storeName.isNotEmpty)
        ? template.storeName
        : receipt.storeName;
    bytes += gen.text(
      displayStoreName,
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += gen.feed(1);
    bytes += gen.text(
      'Receipt #${receipt.receiptNumber}',
      styles: const PosStyles(align: PosAlign.center),
    );
    if (receipt.customerName.isNotEmpty) {
      bytes += gen.text(
        'Customer: ${receipt.customerName}',
        styles: const PosStyles(align: PosAlign.center),
      );
    }
    bytes += gen.text(
      'Date: ${_formatDate(receipt.createdAt)}',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += gen.hr();
    bytes += gen.feed(1);
    return bytes;
  }

  List<int> _buildItems(Generator gen, List<ReceiptItem> items) {
    var bytes = <int>[];
    bytes += gen.row([
      PosColumn(
        text: 'Item',
        width: 6,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: 'Qty',
        width: 2,
        styles: const PosStyles(bold: true, align: PosAlign.right),
      ),
      PosColumn(
        text: 'Total',
        width: 4,
        styles: const PosStyles(bold: true, align: PosAlign.right),
      ),
    ]);
    bytes += gen.hr();

    for (final item in items) {
      bytes += gen.row([
        PosColumn(text: item.name, width: 6),
        PosColumn(
          text: '${item.quantity}',
          width: 2,
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: item.total.toStringAsFixed(2),
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }
    return bytes;
  }

  List<int> _buildTotals(Generator gen, Receipt receipt) {
    var bytes = <int>[];
    bytes += gen.hr();
    bytes += gen.row([
      PosColumn(text: 'Subtotal', width: 8),
      PosColumn(
        text: receipt.subtotal.toStringAsFixed(2),
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += gen.row([
      PosColumn(text: 'Tax (${taxPercentage.toStringAsFixed(1)}%)', width: 8),
      PosColumn(
        text: receipt.tax.toStringAsFixed(2),
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += gen.hr(ch: '=');
    bytes += gen.row([
      PosColumn(
        text: 'TOTAL',
        width: 8,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: '${receipt.currency} ${receipt.total.toStringAsFixed(2)}',
        width: 4,
        styles: const PosStyles(bold: true, align: PosAlign.right),
      ),
    ]);
    return bytes;
  }

  List<int> _buildFooter(Generator gen) {
    var bytes = <int>[];
    bytes += gen.feed(2);
    bytes += gen.text(
      'Thank you for your patronage!',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += gen.feed(1);
    bytes += gen.qrcode(
      'https://print-ease-pos.app',
    );
    bytes += gen.feed(2);
    return bytes;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
