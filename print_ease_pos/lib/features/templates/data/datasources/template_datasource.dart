import 'package:sqflite/sqflite.dart';
import '../../../receipts/data/datasources/database_service.dart';
import '../models/receipt_template.dart';

class TemplateDatasource {
  final DatabaseService _dbService;

  TemplateDatasource(this._dbService);

  Future<Database> get _db => _dbService.database;

  Future<List<ReceiptTemplate>> getTemplates() async {
    final db = await _db;
    final rows = await db.query('templates', orderBy: 'createdAt DESC');
    return rows.map((row) => ReceiptTemplate.fromMap(row)).toList();
  }

  Future<ReceiptTemplate?> getTemplateById(int id) async {
    final db = await _db;
    final rows = await db.query(
      'templates',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return ReceiptTemplate.fromMap(rows.first);
  }

  Future<int> insertTemplate(ReceiptTemplate template) async {
    final db = await _db;
    return db.insert('templates', template.toMap());
  }

  Future<void> updateTemplate(ReceiptTemplate template) async {
    final db = await _db;
    await db.update(
      'templates',
      template.toMap(),
      where: 'id = ?',
      whereArgs: [template.id],
    );
  }

  Future<void> deleteTemplate(int id) async {
    final db = await _db;
    await db.delete('templates', where: 'id = ?', whereArgs: [id]);
  }
}
