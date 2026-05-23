class AppRoutes {
  AppRoutes._();

  static const String dashboard = '/';
  static const String printer = '/printer';
  static const String receipts = '/receipts';
  static const String receiptDetail = '/receipts/:id';
  static const String receiptCreate = '/receipts/create';
  static const String receiptEdit = '/receipts/:id/edit';
  static const String templates = '/templates';
  static const String templateDetail = '/templates/:id';
  static const String templateCreate = '/templates/create';
  static const String settings = '/settings';
  static const String settingsBackup = '/settings/backup';
  static const String pdfExport = '/pdf-export';
  static const String pdfExportDetail = '/pdf-export/:id';
}
