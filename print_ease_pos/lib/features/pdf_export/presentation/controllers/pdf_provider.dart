import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/pdf_storage_service.dart';
import '../../data/models/pdf_document.dart';
import '../../data/repositories/pdf_repository.dart';
import '../../data/services/pdf_formatter.dart';
import '../../../receipts/presentation/controllers/receipt_provider.dart';
import '../../../settings/presentation/controllers/settings_provider.dart';

class PdfState {
  final List<PdfDocument> documents;
  final PdfDocument? selectedDocument;
  final Uint8List? pdfBytes;
  final bool isLoading;
  final bool isExporting;
  final bool isSharing;
  final String? error;

  const PdfState({
    this.documents = const [],
    this.selectedDocument,
    this.pdfBytes,
    this.isLoading = false,
    this.isExporting = false,
    this.isSharing = false,
    this.error,
  });

  PdfState copyWith({
    List<PdfDocument>? documents,
    PdfDocument? selectedDocument,
    Uint8List? pdfBytes,
    bool? isLoading,
    bool? isExporting,
    bool? isSharing,
    String? error,
    bool clearSelected = false,
    bool clearBytes = false,
  }) {
    return PdfState(
      documents: documents ?? this.documents,
      selectedDocument: clearSelected ? null : (selectedDocument ?? this.selectedDocument),
      pdfBytes: clearBytes ? null : (pdfBytes ?? this.pdfBytes),
      isLoading: isLoading ?? this.isLoading,
      isExporting: isExporting ?? this.isExporting,
      isSharing: isSharing ?? this.isSharing,
      error: error,
    );
  }
}

class PdfNotifier extends StateNotifier<PdfState> {
  final PdfRepository _repository;

  PdfNotifier(this._repository) : super(const PdfState());

  Future<void> loadDocuments() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final documents = await _repository.getExportedPdfs();
      state = state.copyWith(documents: documents, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> exportReceipt(int receiptId) async {
    state = state.copyWith(isExporting: true, error: null);
    try {
      final doc = await _repository.exportReceipt(receiptId);
      state = state.copyWith(isExporting: false, selectedDocument: doc);
      await loadDocuments();
    } catch (e) {
      state = state.copyWith(isExporting: false, error: e.toString());
    }
  }

  Future<void> loadPdfBytes(int documentId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final bytes = await _repository.getPdfBytes(documentId);
      final doc = await _repository.getDocumentById(documentId);
      state = state.copyWith(
        pdfBytes: bytes,
        selectedDocument: doc,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> shareDocument(int documentId) async {
    state = state.copyWith(isSharing: true, error: null);
    try {
      await _repository.sharePdf(documentId);
      state = state.copyWith(isSharing: false);
    } catch (e) {
      state = state.copyWith(isSharing: false, error: e.toString());
    }
  }

  Future<void> printDocument(int documentId) async {
    state = state.copyWith(isSharing: true, error: null);
    try {
      await _repository.printPdf(documentId);
      state = state.copyWith(isSharing: false);
    } catch (e) {
      state = state.copyWith(isSharing: false, error: e.toString());
    }
  }

  Future<void> deleteDocument(int id) async {
    try {
      await _repository.deletePdf(id);
      if (state.selectedDocument?.id == id) {
        state = state.copyWith(selectedDocument: null, clearSelected: true);
      }
      await loadDocuments();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void selectDocument(PdfDocument doc) {
    state = state.copyWith(selectedDocument: doc);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final pdfStorageServiceProvider = Provider<PdfStorageService>((ref) {
  return PdfStorageService();
});

final pdfFormatterProvider = Provider<PdfFormatter>((ref) {
  final settings = ref.watch(settingsProvider);
  return PdfFormatter(paperWidth: settings.defaultPaperWidth.toInt(), taxPercentage: settings.taxPercentage);
});

final pdfRepositoryProvider = Provider<PdfRepository>((ref) {
  return PdfRepository(
    formatter: ref.watch(pdfFormatterProvider),
    storageService: ref.watch(pdfStorageServiceProvider),
    receiptRepository: ref.watch(receiptRepositoryProvider),
  );
});

final pdfProvider = StateNotifierProvider<PdfNotifier, PdfState>((ref) {
  return PdfNotifier(ref.watch(pdfRepositoryProvider));
});
