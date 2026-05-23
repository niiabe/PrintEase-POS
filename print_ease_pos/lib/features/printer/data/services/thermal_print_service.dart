import '../datasources/printer_datasource.dart';
import 'esc_pos_formatter.dart';
import '../../../receipts/data/models/receipt.dart';

class ThermalPrintService {
  final PrinterDatasource _datasource;
  final int _paperWidth;

  ThermalPrintService(this._datasource, {int paperWidth = 80})
      : _paperWidth = paperWidth;

  Future<PrintResult> printReceipt(Receipt receipt) async {
    final isConnected = await _datasource.isConnected();
    if (!isConnected) {
      return PrintResult.failure('No printer connected');
    }

    try {
      final formatter = EscPosFormatter(paperWidth: _paperWidth);
      final bytes = await formatter.formatReceipt(receipt);
      final success = await _datasource.printBytes(bytes);

      if (success) {
        return PrintResult.success();
      }
      return PrintResult.failure('Failed to send print data');
    } catch (e) {
      return PrintResult.failure('Print error: ${e.toString()}');
    }
  }

  Future<PrintResult> reprintReceipt(Receipt receipt) async {
    return printReceipt(receipt);
  }

  Future<bool> isPrinterReady() async {
    return _datasource.isConnected();
  }

  Future<List<int>> previewReceipt(Receipt receipt) async {
    final formatter = EscPosFormatter(paperWidth: _paperWidth);
    return formatter.formatReceipt(receipt);
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
