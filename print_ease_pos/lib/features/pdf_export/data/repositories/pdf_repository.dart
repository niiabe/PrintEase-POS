import 'dart:typed_data';
import 'package:printing/printing.dart';
import '../datasources/pdf_storage_service.dart';
import '../models/pdf_document.dart';
import '../services/pdf_formatter.dart';
import '../../../receipts/data/repositories/receipt_repository.dart';
import '../../../templates/data/models/receipt_template.dart';
import '../../../templates/data/repositories/template_repository.dart';

class PdfRepository {
  final PdfFormatter _formatter;
  final PdfStorageService _storageService;
  final ReceiptRepository _receiptRepository;
  final TemplateRepository _templateRepository;
  final int? _defaultTemplateId;

  PdfRepository({
    required PdfFormatter formatter,
    required PdfStorageService storageService,
    required ReceiptRepository receiptRepository,
    required TemplateRepository templateRepository,
    required int? defaultTemplateId,
  })  : _formatter = formatter,
        _storageService = storageService,
        _receiptRepository = receiptRepository,
        _templateRepository = templateRepository,
        _defaultTemplateId = defaultTemplateId;

  Future<List<PdfDocument>> getExportedPdfs() {
    return _storageService.listDocuments();
  }

  Future<PdfDocument> exportReceipt(int receiptId, {ReceiptTemplate? template}) async {
    final receipt = await _receiptRepository.getReceiptById(receiptId);
    if (receipt == null) throw Exception('Receipt not found');
    final bytes = await _formatter.formatReceipt(receipt, template: template);
    final doc = await _storageService.saveDocument(receiptId, bytes);
    return doc;
  }

  Future<void> sharePdf(int documentId) async {
    final bytes = await _storageService.readDocument(documentId);
    if (bytes == null) throw Exception('PDF not found');
    final displayName = await _getDisplayName(documentId);
    await Printing.sharePdf(
      bytes: bytes,
      filename: displayName,
    );
  }

  Future<String> _getDisplayName(int documentId) async {
    final doc = await _storageService.getDocumentById(documentId);
    if (doc == null) return 'receipt_$documentId.pdf';
    final receipt = await _receiptRepository.getReceiptById(doc.receiptId);
    if (receipt == null) return doc.fileName;
    String storeName = receipt.storeName;
    if (_defaultTemplateId != null) {
      try {
        final template = await _templateRepository.getTemplateById(_defaultTemplateId);
        if (template != null && template.storeName.isNotEmpty) {
          storeName = template.storeName;
        }
      } catch (_) {}
    }
    final sanitized = storeName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    return '${sanitized}_${receipt.receiptNumber}.pdf';
  }

  Future<void> printPdf(int documentId) async {
    final bytes = await _storageService.readDocument(documentId);
    if (bytes == null) throw Exception('PDF not found');
    await Printing.layoutPdf(onLayout: (_) => bytes);
  }

  Future<String?> downloadPdf(int documentId) async {
    return _storageService.getLocalPath(documentId);
  }

  Future<Uint8List?> getPdfBytes(int documentId) async {
    return _storageService.readDocument(documentId);
  }

  Future<void> deletePdf(int documentId) async {
    await _storageService.deleteDocument(documentId);
  }

  Future<String> getDisplayName(int documentId) async {
    return _getDisplayName(documentId);
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
