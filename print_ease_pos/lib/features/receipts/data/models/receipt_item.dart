class ReceiptItem {
  final int? id;
  final int? receiptId;
  final String name;
  final int quantity;
  final double unitPrice;
  final double total;

  const ReceiptItem({
    this.id,
    this.receiptId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  factory ReceiptItem.fromMap(Map<String, dynamic> map) {
    return ReceiptItem(
      id: map['id'] as int?,
      receiptId: map['receiptId'] as int?,
      name: map['name'] as String,
      quantity: map['quantity'] as int,
      unitPrice: (map['unitPrice'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (receiptId != null) 'receiptId': receiptId,
      'name': name,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'total': total,
    };
  }

  ReceiptItem copyWith({
    int? id,
    int? receiptId,
    String? name,
    int? quantity,
    double? unitPrice,
    double? total,
  }) {
    return ReceiptItem(
      id: id ?? this.id,
      receiptId: receiptId ?? this.receiptId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      total: total ?? this.total,
    );
  }
}
