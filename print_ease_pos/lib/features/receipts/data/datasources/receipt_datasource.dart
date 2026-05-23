import 'package:sqflite/sqflite.dart';
import '../models/receipt.dart';
import '../models/receipt_item.dart';
import 'database_service.dart';

class ReceiptDatasource {
  final DatabaseService _dbService;

  ReceiptDatasource(this._dbService);

  Future<List<Receipt>> getReceipts() async {
    return searchReceipts();
  }

  Future<List<Receipt>> searchReceipts({
    String? query,
    PrintStatus? printStatus,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    final db = await _dbService.database;
    final where = <String>[];
    final whereArgs = <dynamic>[];

    if (query != null && query.isNotEmpty) {
      where.add('receiptNumber LIKE ?');
      whereArgs.add('%$query%');
    }
    if (printStatus != null) {
      where.add('printStatus = ?');
      whereArgs.add(printStatus.index);
    }
    if (startDate != null) {
      where.add('createdAt >= ?');
      whereArgs.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      where.add('createdAt <= ?');
      whereArgs.add(endDate.toIso8601String());
    }

    final rows = await db.query(
      'receipts',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'createdAt DESC',
      limit: limit,
      offset: offset,
    );
    final receipts = <Receipt>[];
    for (final row in rows) {
      final receipt = Receipt.fromMap(row);
      final items = await _getItems(db, receipt.id!);
      receipts.add(receipt.copyWith(items: items));
    }
    return receipts;
  }

  Future<Receipt?> getReceiptById(int id) async {
    final db = await _dbService.database;
    final rows = await db.query('receipts', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    final receipt = Receipt.fromMap(rows.first);
    final items = await _getItems(db, receipt.id!);
    return receipt.copyWith(items: items);
  }

  Future<int> insertReceipt(Receipt receipt) async {
    final db = await _dbService.database;
    final id = await db.insert('receipts', receipt.toMap());
    for (final item in receipt.items) {
      await db.insert('receipt_items', {
        ...item.toMap(),
        'receiptId': id,
      });
    }
    return id;
  }

  Future<void> updateReceipt(Receipt receipt) async {
    final db = await _dbService.database;
    await db.update(
      'receipts',
      receipt.toMap(),
      where: 'id = ?',
      whereArgs: [receipt.id],
    );
    await db.delete('receipt_items', where: 'receiptId = ?', whereArgs: [receipt.id]);
    for (final item in receipt.items) {
      await db.insert('receipt_items', {
        ...item.toMap(),
        'receiptId': receipt.id,
      });
    }
  }

  Future<void> deleteReceipt(int id) async {
    final db = await _dbService.database;
    await db.delete('receipt_items', where: 'receiptId = ?', whereArgs: [id]);
    await db.delete('receipts', where: 'id = ?', whereArgs: [id]);
  }

  Future<String> getNextReceiptNumber() async {
    final db = await _dbService.database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM receipts WHERE strftime('%Y-%m', createdAt) = strftime('%Y-%m', 'now')",
    );
    final count = (result.first['count'] as int) + 1;
    final now = DateTime.now();
    return 'RCP-${now.year}${now.month.toString().padLeft(2, '0')}-${count.toString().padLeft(4, '0')}';
  }

  Future<List<ReceiptItem>> _getItems(Database db, int receiptId) async {
    final rows = await db.query(
      'receipt_items',
      where: 'receiptId = ?',
      whereArgs: [receiptId],
    );
    return rows.map((row) => ReceiptItem.fromMap(row)).toList();
  }
}
