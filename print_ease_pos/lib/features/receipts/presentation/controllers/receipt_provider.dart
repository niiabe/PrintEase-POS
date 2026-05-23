import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/database_service.dart';
import '../../data/datasources/receipt_datasource.dart';
import '../../data/models/receipt.dart';
import '../../data/models/receipt_item.dart';
import '../../data/repositories/receipt_repository.dart';

class ReceiptState {
  final List<Receipt> receipts;
  final Receipt? selectedReceipt;
  final Receipt? draftReceipt;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String searchQuery;
  final PrintStatus? filterStatus;
  final DateTime? filterDateStart;
  final DateTime? filterDateEnd;

  const ReceiptState({
    this.receipts = const [],
    this.selectedReceipt,
    this.draftReceipt,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.searchQuery = '',
    this.filterStatus,
    this.filterDateStart,
    this.filterDateEnd,
  });

  ReceiptState copyWith({
    List<Receipt>? receipts,
    Receipt? selectedReceipt,
    Receipt? draftReceipt,
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? searchQuery,
    PrintStatus? filterStatus,
    DateTime? filterDateStart,
    DateTime? filterDateEnd,
    bool clearFilterStatus = false,
    bool clearFilterDateStart = false,
    bool clearFilterDateEnd = false,
  }) {
    return ReceiptState(
      receipts: receipts ?? this.receipts,
      selectedReceipt: selectedReceipt ?? this.selectedReceipt,
      draftReceipt: draftReceipt,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      filterStatus: clearFilterStatus ? null : (filterStatus ?? this.filterStatus),
      filterDateStart: clearFilterDateStart ? null : (filterDateStart ?? this.filterDateStart),
      filterDateEnd: clearFilterDateEnd ? null : (filterDateEnd ?? this.filterDateEnd),
    );
  }
}

class ReceiptNotifier extends StateNotifier<ReceiptState> {
  final ReceiptRepository _repository;
  Timer? _debounce;

  ReceiptNotifier(this._repository) : super(const ReceiptState());

  Future<void> loadReceipts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final receipts = await _repository.searchReceipts(
        query: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        printStatus: state.filterStatus,
        startDate: state.filterDateStart,
        endDate: state.filterDateEnd,
      );
      state = state.copyWith(receipts: receipts, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadReceiptById(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final receipt = await _repository.getReceiptById(id);
      state = state.copyWith(selectedReceipt: receipt, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<int?> saveReceipt(Receipt receipt) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final id = await _repository.saveReceipt(receipt);
      state = state.copyWith(isSaving: false, draftReceipt: null);
      await loadReceipts();
      return id;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return null;
    }
  }

  Future<bool> updateReceipt(Receipt receipt) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      await _repository.updateReceipt(receipt);
      state = state.copyWith(isSaving: false, draftReceipt: null, selectedReceipt: receipt);
      await loadReceipts();
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  Future<void> deleteReceipt(int id) async {
    try {
      await _repository.deleteReceipt(id);
      if (state.selectedReceipt?.id == id) {
        state = state.copyWith(selectedReceipt: null);
      }
      await loadReceipts();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      loadReceipts();
    });
  }

  void setFilterStatus(PrintStatus? status) {
    state = state.copyWith(filterStatus: status, clearFilterStatus: status == null);
    loadReceipts();
  }

  void setDateFilter(DateTime? start, DateTime? end) {
    state = state.copyWith(
      filterDateStart: start,
      filterDateEnd: end,
      clearFilterDateStart: start == null,
      clearFilterDateEnd: end == null,
    );
    loadReceipts();
  }

  void clearAllFilters() {
    state = state.copyWith(
      searchQuery: '',
      filterStatus: null,
      filterDateStart: null,
      filterDateEnd: null,
      clearFilterStatus: true,
      clearFilterDateStart: true,
      clearFilterDateEnd: true,
    );
    loadReceipts();
  }

  Future<void> startNewReceipt(String storeName) async {
    final receiptNumber = await _repository.getNextReceiptNumber();
    state = state.copyWith(
      draftReceipt: Receipt(
        receiptNumber: receiptNumber,
        storeName: storeName,
        createdAt: DateTime.now(),
      ),
    );
  }

  void startEditReceipt(Receipt receipt) {
    state = state.copyWith(draftReceipt: receipt);
  }

  void updateDraftCustomer(String name) {
    final draft = state.draftReceipt;
    if (draft == null) return;
    state = state.copyWith(
      draftReceipt: draft.copyWith(customerName: name),
    );
  }

  void updateDraftNotes(String notes) {
    final draft = state.draftReceipt;
    if (draft == null) return;
    state = state.copyWith(
      draftReceipt: draft.copyWith(notes: notes),
    );
  }

  void addDraftItem(ReceiptItem item, {double taxPercentage = 0}) {
    final draft = state.draftReceipt;
    if (draft == null) return;
    state = state.copyWith(
      draftReceipt: _repository.addItem(draft, item, taxPercentage: taxPercentage),
    );
  }

  void removeDraftItem(int index, {double taxPercentage = 0}) {
    final draft = state.draftReceipt;
    if (draft == null) return;
    state = state.copyWith(
      draftReceipt: _repository.removeItem(draft, index, taxPercentage: taxPercentage),
    );
  }

  void updateDraftItem(int index, ReceiptItem item, {double taxPercentage = 0}) {
    final draft = state.draftReceipt;
    if (draft == null) return;
    state = state.copyWith(
      draftReceipt: _repository.updateItem(draft, index, item, taxPercentage: taxPercentage),
    );
  }

  void updatePrintStatus(int id, PrintStatus status) async {
    final receipt = state.receipts.firstWhere((r) => r.id == id);
    final updated = receipt.copyWith(printStatus: status);
    await _repository.updateReceipt(updated);
    if (state.selectedReceipt?.id == id) {
      state = state.copyWith(selectedReceipt: updated);
    }
    await loadReceipts();
  }

  void selectReceipt(Receipt receipt) {
    state = state.copyWith(selectedReceipt: receipt);
  }

  void clearDraft() {
    state = state.copyWith(draftReceipt: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

final receiptDatasourceProvider = Provider<ReceiptDatasource>((ref) {
  return ReceiptDatasource(ref.watch(databaseServiceProvider));
});

final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  return ReceiptRepository(ref.watch(receiptDatasourceProvider));
});

final receiptProvider =
    StateNotifierProvider<ReceiptNotifier, ReceiptState>((ref) {
  return ReceiptNotifier(ref.watch(receiptRepositoryProvider));
});
