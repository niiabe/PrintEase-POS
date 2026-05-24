import 'package:flutter/services.dart';

class NativePdfService {
  static const _channel = MethodChannel('com.example.print_ease_pos/pdf_save');

  Future<String?> saveBitmapAsPdf({
    required String imagePath,
    required String fileName,
    int pageWidth = 2480,
    int pageHeight = 3508,
  }) async {
    try {
      final result = await _channel.invokeMethod<String>('saveBitmapAsPdf', {
        'path': imagePath,
        'fileName': fileName,
        'pageWidth': pageWidth,
        'pageHeight': pageHeight,
      });
      return result;
    } on MissingPluginException {
      return 'ERROR:Native plugin not available';
    }
  }

  Future<String?> saveFileToDownloads(String filePath, String fileName) async {
    try {
      final result = await _channel.invokeMethod<String>('saveToDownloads', {
        'path': filePath,
        'fileName': fileName,
      });
      return result;
    } on MissingPluginException {
      return 'ERROR:Native plugin not available';
    }
  }
}
