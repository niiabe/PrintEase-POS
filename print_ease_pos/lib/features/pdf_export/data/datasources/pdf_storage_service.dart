import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import '../models/pdf_document.dart';

class PdfStorageService {
  Future<Directory> get _pdfDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/pdf_exports');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<List<PdfDocument>> listDocuments() async {
    final dir = await _pdfDir;
    final files = await dir.list().toList();
    final docs = <PdfDocument>[];
    for (final entity in files) {
      if (entity is File && entity.path.endsWith('.pdf')) {
        final stat = await entity.stat();
        final name = entity.uri.pathSegments.last;
        final id = _parseId(name);
        final receiptId = _parseReceiptId(name);
        if (id != null && receiptId != null) {
          docs.add(PdfDocument(
            id: id,
            fileName: name,
            filePath: entity.path,
            receiptId: receiptId,
            createdAt: stat.modified,
            fileSizeKb: (stat.size / 1024).roundToDouble(),
          ));
        }
      }
    }
    docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return docs;
  }

  Future<PdfDocument> saveDocument(
    int receiptId,
    Uint8List bytes,
  ) async {
    final dir = await _pdfDir;
    final count = (await dir.list().length) + 1;
    final name = 'receipt_${receiptId}_$count.pdf';
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    final stat = await file.stat();
    return PdfDocument(
      id: count,
      fileName: name,
      filePath: file.path,
      receiptId: receiptId,
      createdAt: stat.modified,
      fileSizeKb: (stat.size / 1024).roundToDouble(),
    );
  }

  Future<void> deleteDocument(int id) async {
    final doc = await _findDocument(id);
    if (doc != null) {
      final file = File(doc.filePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  Future<Uint8List?> readDocument(int id) async {
    final doc = await _findDocument(id);
    if (doc == null) return null;
    final file = File(doc.filePath);
    if (!await file.exists()) return null;
    return await file.readAsBytes();
  }

  Future<String?> saveToDownloads(int id) async {
    final doc = await _findDocument(id);
    if (doc == null) return null;
    final file = File(doc.filePath);
    if (!await file.exists()) return null;
    final downloadDir = await getDownloadsDirectory();
    if (downloadDir == null) return null;
    final dest = File('${downloadDir.path}/${doc.fileName}');
    await file.copy(dest.path);
    return dest.path;
  }

  Future<PdfDocument?> _findDocument(int id) async {
    final docs = await listDocuments();
    try {
      return docs.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  int? _parseId(String name) {
    final parts = name.replaceAll('.pdf', '').split('_');
    if (parts.length >= 3) return int.tryParse(parts[2]);
    return null;
  }

  int? _parseReceiptId(String name) {
    final parts = name.replaceAll('.pdf', '').split('_');
    if (parts.length >= 2) return int.tryParse(parts[1]);
    return null;
  }
}
