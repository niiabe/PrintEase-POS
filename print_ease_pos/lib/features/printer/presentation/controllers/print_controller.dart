import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/thermal_print_service.dart';
import '../../../receipts/data/models/receipt.dart';
import '../../../receipts/data/repositories/receipt_repository.dart';
import '../../../receipts/presentation/controllers/receipt_provider.dart';
import '../../../settings/presentation/controllers/settings_provider.dart';
import 'printer_provider.dart';

class PrintControllerState {
  final bool isPrinting;
  final String? message;
  final bool isSuccess;

  const PrintControllerState({
    this.isPrinting = false,
    this.message,
    this.isSuccess = false,
  });

  PrintControllerState copyWith({
    bool? isPrinting,
    String? message,
    bool? isSuccess,
  }) {
    return PrintControllerState(
      isPrinting: isPrinting ?? this.isPrinting,
      message: message,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class PrintController extends StateNotifier<PrintControllerState> {
  final ThermalPrintService _printService;
  final ReceiptRepository _receiptRepository;

  PrintController(this._printService, this._receiptRepository)
      : super(const PrintControllerState());

  Future<void> printReceipt(Receipt receipt) async {
    state = state.copyWith(isPrinting: true, message: null);
    final result = await _printService.printReceipt(receipt);
    if (result.success && receipt.id != null) {
      final updated = receipt.copyWith(
        printStatus: PrintStatus.printed,
      );
      await _receiptRepository.updateReceipt(updated);
    } else if (receipt.id != null) {
      final updated = receipt.copyWith(
        printStatus: PrintStatus.failed,
      );
      await _receiptRepository.updateReceipt(updated);
    }
    state = state.copyWith(
      isPrinting: false,
      message: result.message ?? (result.success ? 'Printed' : 'Failed'),
      isSuccess: result.success,
    );
  }

  Future<void> reprintReceipt(Receipt receipt) async {
    state = state.copyWith(isPrinting: true, message: null);
    final result = await _printService.reprintReceipt(receipt);
    if (result.success && receipt.id != null) {
      final updated = receipt.copyWith(
        printStatus: PrintStatus.printed,
      );
      await _receiptRepository.updateReceipt(updated);
    }
    state = state.copyWith(
      isPrinting: false,
      message: result.message ?? (result.success ? 'Reprinted' : 'Failed'),
      isSuccess: result.success,
    );
  }

  void clearMessage() {
    state = state.copyWith(message: null);
  }
}

final thermalPrintServiceProvider = Provider<ThermalPrintService>((ref) {
  final settings = ref.watch(settingsProvider);
  return ThermalPrintService(
    ref.watch(printerDatasourceProvider),
    paperWidth: settings.defaultPaperWidth.toInt(),
  );
});

final printControllerProvider =
    StateNotifierProvider<PrintController, PrintControllerState>((ref) {
  final printService = ref.watch(thermalPrintServiceProvider);
  final receiptRepo = ref.watch(receiptRepositoryProvider);
  return PrintController(printService, receiptRepo);
});
