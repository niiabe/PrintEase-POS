import '../datasources/receipt_datasource.dart';
import '../models/receipt.dart';
import '../models/receipt_item.dart';

class ReceiptRepository {
  final ReceiptDatasource _datasource;

  ReceiptRepository(this._datasource);

  Future<List<Receipt>> getReceipts() {
    return _datasource.getReceipts();
  }

  Future<List<Receipt>> searchReceipts({
    String? query,
    PrintStatus? printStatus,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) {
    return _datasource.searchReceipts(
      query: query,
      printStatus: printStatus,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
      offset: offset,
    );
  }

  Future<Receipt?> getReceiptById(int id) {
    return _datasource.getReceiptById(id);
  }

  Future<int> saveReceipt(Receipt receipt) {
    return _datasource.insertReceipt(receipt);
  }

  Future<void> updateReceipt(Receipt receipt) {
    return _datasource.updateReceipt(receipt);
  }

  Future<void> deleteReceipt(int id) {
    return _datasource.deleteReceipt(id);
  }

  Future<String> getNextReceiptNumber() {
    return _datasource.getNextReceiptNumber();
  }

  Receipt calculateTotals(Receipt receipt) {
    double subtotal = 0;
    for (final item in receipt.items) {
      subtotal += item.total;
    }
    subtotal = double.parse(subtotal.toStringAsFixed(2));
    final tax = double.parse((subtotal * 0.125).toStringAsFixed(2));
    final total = double.parse((subtotal + tax).toStringAsFixed(2));
    return receipt.copyWith(subtotal: subtotal, tax: tax, total: total);
  }

  Receipt addItem(Receipt receipt, ReceiptItem item) {
    final items = [...receipt.items, item];
    return calculateTotals(receipt.copyWith(items: items));
  }

  Receipt removeItem(Receipt receipt, int index) {
    final items = [...receipt.items]..removeAt(index);
    return calculateTotals(receipt.copyWith(items: items));
  }

  Receipt updateItem(Receipt receipt, int index, ReceiptItem item) {
    final items = [...receipt.items];
    items[index] = item;
    return calculateTotals(receipt.copyWith(items: items));
  }
}
