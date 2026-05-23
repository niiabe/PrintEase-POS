class PdfDocument {
  final int? id;
  final String fileName;
  final String filePath;
  final int receiptId;
  final DateTime createdAt;
  final double fileSizeKb;

  const PdfDocument({
    this.id,
    required this.fileName,
    required this.filePath,
    required this.receiptId,
    required this.createdAt,
    this.fileSizeKb = 0,
  });

  factory PdfDocument.fromMap(Map<String, dynamic> map) {
    return PdfDocument(
      id: map['id'] as int?,
      fileName: map['fileName'] as String,
      filePath: map['filePath'] as String,
      receiptId: map['receiptId'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
      fileSizeKb: (map['fileSizeKb'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'fileName': fileName,
      'filePath': filePath,
      'receiptId': receiptId,
      'createdAt': createdAt.toIso8601String(),
      'fileSizeKb': fileSizeKb,
    };
  }
}
