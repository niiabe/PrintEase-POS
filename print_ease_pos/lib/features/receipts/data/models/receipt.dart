import 'receipt_item.dart';

enum PrintStatus { notPrinted, printed, failed }

class Receipt {
  final int? id;
  final String receiptNumber;
  final String storeName;
  final String customerName;
  final List<ReceiptItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final String currency;
  final PrintStatus printStatus;
  final String? notes;
  final DateTime createdAt;

  const Receipt({
    this.id,
    required this.receiptNumber,
    required this.storeName,
    this.customerName = '',
    this.items = const [],
    this.subtotal = 0,
    this.tax = 0,
    this.total = 0,
    this.currency = 'GHS',
    this.printStatus = PrintStatus.notPrinted,
    this.notes,
    required this.createdAt,
  });

  factory Receipt.fromMap(Map<String, dynamic> map) {
    return Receipt(
      id: map['id'] as int?,
      receiptNumber: map['receiptNumber'] as String,
      storeName: map['storeName'] as String,
      customerName: map['customerName'] as String? ?? '',
      items: [],
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0,
      tax: (map['tax'] as num?)?.toDouble() ?? 0,
      total: (map['total'] as num).toDouble(),
      currency: map['currency'] as String? ?? 'GHS',
      printStatus: PrintStatus.values[map['printStatus'] as int? ?? 0],
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'receiptNumber': receiptNumber,
      'storeName': storeName,
      'customerName': customerName,
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'currency': currency,
      'printStatus': printStatus.index,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Receipt copyWith({
    int? id,
    String? receiptNumber,
    String? storeName,
    String? customerName,
    List<ReceiptItem>? items,
    double? subtotal,
    double? tax,
    double? total,
    String? currency,
    PrintStatus? printStatus,
    String? notes,
    DateTime? createdAt,
  }) {
    return Receipt(
      id: id ?? this.id,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      storeName: storeName ?? this.storeName,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      currency: currency ?? this.currency,
      printStatus: printStatus ?? this.printStatus,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get printStatusLabel {
    switch (printStatus) {
      case PrintStatus.printed:
        return 'Printed';
      case PrintStatus.failed:
        return 'Failed';
      case PrintStatus.notPrinted:
        return 'Not Printed';
    }
  }
}
