import '../datasources/printer_datasource.dart';
import 'esc_pos_formatter.dart';
import '../../../receipts/data/models/receipt.dart';
import '../../../templates/data/models/receipt_template.dart';

class ThermalPrintService {
  final PrinterDatasource _datasource;
  final int _paperWidth;
  final double _taxPercentage;

  ThermalPrintService(this._datasource, {int paperWidth = 80, double taxPercentage = 0})
      : _paperWidth = paperWidth,
        _taxPercentage = taxPercentage;

  Future<PrintResult> printReceipt(Receipt receipt, {ReceiptTemplate? template}) async {
    final isConnected = await _datasource.isConnected();
    if (!isConnected) {
      return PrintResult.failure('No printer connected');
    }

    try {
      final formatter = EscPosFormatter(paperWidth: _paperWidth, taxPercentage: _taxPercentage);
      final bytes = await formatter.formatReceipt(receipt, template: template);
      final success = await _datasource.printBytes(bytes);

      if (success) {
        return PrintResult.success();
      }
      return PrintResult.failure('Failed to send print data');
    } catch (e) {
      return PrintResult.failure('Print error: ${e.toString()}');
    }
  }

  Future<PrintResult> reprintReceipt(Receipt receipt, {ReceiptTemplate? template}) async {
    return printReceipt(receipt, template: template);
  }
}

class PrintResult {
  final bool success;
  final String? message;

  const PrintResult._({required this.success, this.message});

  factory PrintResult.success() => const PrintResult._(success: true);

  factory PrintResult.failure(String message) =>
      PrintResult._(success: false, message: message);
}
