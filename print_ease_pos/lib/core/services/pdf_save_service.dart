import 'package:flutter/services.dart';

class PdfSaveService {
  static const _channel = MethodChannel('com.example.print_ease_pos/pdf_save');

  Future<String?> saveToPublicDownloads(String filePath, String fileName) async {
    try {
      final result = await _channel.invokeMethod<String>('saveToDownloads', {
        'path': filePath,
        'fileName': fileName,
      });
      return result;
    } on MissingPluginException {
      return null;
    }
  }
}
