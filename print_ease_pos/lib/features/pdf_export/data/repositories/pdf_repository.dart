import 'dart:typed_data';
import 'package:printing/printing.dart';
import '../datasources/pdf_storage_service.dart';
import '../models/pdf_document.dart';
import '../services/pdf_formatter.dart';
import '../../../receipts/data/repositories/receipt_repository.dart';

class PdfRepository {
  final PdfFormatter _formatter;
  final PdfStorageService _storageService;
  final ReceiptRepository _receiptRepository;

  PdfRepository({
    required PdfFormatter formatter,
    required PdfStorageService storageService,
    required ReceiptRepository receiptRepository,
  })  : _formatter = formatter,
        _storageService = storageService,
        _receiptRepository = receiptRepository;

  Future<List<PdfDocument>> getExportedPdfs() {
    return _storageService.listDocuments();
  }

  Future<PdfDocument> exportReceipt(int receiptId) async {
    final receipt = await _receiptRepository.getReceiptById(receiptId);
    if (receipt == null) throw Exception('Receipt not found');
    final bytes = await _formatter.formatReceipt(receipt);
    return _storageService.saveDocument(receiptId, bytes);
  }

  Future<void> sharePdf(int documentId) async {
    final bytes = await _storageService.readDocument(documentId);
    if (bytes == null) throw Exception('PDF not found');
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'receipt_$documentId.pdf',
    );
  }

  Future<void> printPdf(int documentId) async {
    final bytes = await _storageService.readDocument(documentId);
    if (bytes == null) throw Exception('PDF not found');
    await Printing.layoutPdf(onLayout: (_) => bytes);
  }

  Future<String?> downloadPdf(int documentId) async {
    return _storageService.saveToDownloads(documentId);
  }

  Future<Uint8List?> getPdfBytes(int documentId) async {
    return _storageService.readDocument(documentId);
  }

  Future<void> deletePdf(int documentId) async {
    await _storageService.deleteDocument(documentId);
  }

  Future<PdfDocument?> getDocumentById(int id) async {
    final docs = await _storageService.listDocuments();
    try {
      return docs.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }
}
