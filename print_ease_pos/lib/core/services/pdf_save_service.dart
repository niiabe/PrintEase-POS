import 'package:flutter/services.dart';

class PdfSaveResult {
  final bool success;
  final String? uri;
  final String? error;

  const PdfSaveResult({required this.success, this.uri, this.error});
}

class PdfSaveService {
  static const _channel = MethodChannel('com.example.print_ease_pos/pdf_save');

  Future<PdfSaveResult> saveToPublicDownloads(String filePath, String fileName) async {
    try {
      final result = await _channel.invokeMethod<String>('saveToDownloads', {
        'path': filePath,
        'fileName': fileName,
      });
      if (result == null) {
        return const PdfSaveResult(success: false, error: 'Native returned null');
      }
      if (result.startsWith('OK:')) {
        final uri = result.substring(3);
        return PdfSaveResult(success: true, uri: uri);
      }
      if (result.startsWith('ERROR:')) {
        final error = result.substring(6);
        return PdfSaveResult(success: false, error: error);
      }
      return PdfSaveResult(success: false, error: 'Unexpected response: $result');
    } on MissingPluginException {
      return const PdfSaveResult(success: false, error: 'PDF save plugin not available');
    }
  }
}
