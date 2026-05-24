import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/thermal_print_service.dart';
import '../../../receipts/data/models/receipt.dart';
import '../../../receipts/data/repositories/receipt_repository.dart';
import '../../../receipts/presentation/controllers/receipt_provider.dart';
import '../../../settings/presentation/controllers/settings_provider.dart';
import '../../../templates/data/models/receipt_template.dart';
import '../../../templates/data/repositories/template_repository.dart';
import '../../../templates/presentation/controllers/template_provider.dart';
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
  final TemplateRepository _templateRepository;
  final int? _defaultTemplateId;

  PrintController(this._printService, this._receiptRepository,
      this._templateRepository, this._defaultTemplateId)
      : super(const PrintControllerState());

  Future<ReceiptTemplate?> _loadDefaultTemplate() async {
    if (_defaultTemplateId == null) return null;
    try {
      return await _templateRepository.getTemplateById(_defaultTemplateId);
    } catch (_) {
      return null;
    }
  }

  Future<void> printReceipt(Receipt receipt) async {
    state = state.copyWith(isPrinting: true, message: null);
    final template = await _loadDefaultTemplate();
    final result = await _printService.printReceipt(receipt, template: template);
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
    final template = await _loadDefaultTemplate();
    final result = await _printService.reprintReceipt(receipt, template: template);
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
    taxPercentage: settings.taxPercentage,
  );
});

final printControllerProvider =
    StateNotifierProvider<PrintController, PrintControllerState>((ref) {
  final settings = ref.watch(settingsProvider);
  final printService = ref.watch(thermalPrintServiceProvider);
  final receiptRepo = ref.watch(receiptRepositoryProvider);
  final templateRepo = ref.watch(templateRepositoryProvider);
  return PrintController(printService, receiptRepo, templateRepo, settings.defaultTemplateId);
});
