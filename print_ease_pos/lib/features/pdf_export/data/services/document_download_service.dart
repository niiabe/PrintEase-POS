import 'dart:io';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';

class DocumentDownloadService {
  Future<String?> downloadFile({
    required String localPath,
    required String fileName,
    void Function(double progress)? onProgress,
  }) async {
    final file = File(localPath);
    if (!await file.exists()) return null;

    String? resultPath;
    await FileDownloader.downloadFile(
      url: Uri.file(localPath).toString(),
      name: fileName,
      notificationType: NotificationType.all,
      downloadDestination: DownloadDestinations.publicDownloads,
      onProgress: (_, progress) => onProgress?.call(progress),
      onDownloadCompleted: (path) => resultPath = path,
      onDownloadError: (error) => throw Exception(error),
    );
    return resultPath;
  }
}
