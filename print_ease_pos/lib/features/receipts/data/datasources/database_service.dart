import 'package:sqflite/sqflite.dart';
import '../../../../core/constants/app_constants.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/${AppConstants.dbName}';
    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE receipts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        receiptNumber TEXT NOT NULL,
        storeName TEXT NOT NULL,
        customerName TEXT NOT NULL DEFAULT '',
        subtotal REAL NOT NULL DEFAULT 0,
        tax REAL NOT NULL DEFAULT 0,
        total REAL NOT NULL,
        currency TEXT NOT NULL DEFAULT 'GHS',
        printStatus INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE receipt_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        receiptId INTEGER NOT NULL,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unitPrice REAL NOT NULL,
        total REAL NOT NULL,
        FOREIGN KEY (receiptId) REFERENCES receipts(id) ON DELETE CASCADE
      )
    ''');
    await _createTemplatesTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createTemplatesTable(db);
    }
  }

  Future<void> _createTemplatesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS templates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        storeName TEXT NOT NULL DEFAULT '',
        storePhone TEXT NOT NULL DEFAULT '',
        header TEXT NOT NULL DEFAULT '',
        footer TEXT NOT NULL DEFAULT 'Thank you for your patronage!',
        logoPath TEXT,
        showLogo INTEGER NOT NULL DEFAULT 1,
        showQrCode INTEGER NOT NULL DEFAULT 1,
        showDivider INTEGER NOT NULL DEFAULT 1,
        showItemizedList INTEGER NOT NULL DEFAULT 1,
        paperWidth REAL NOT NULL DEFAULT 58,
        fontSize REAL NOT NULL DEFAULT 1.0,
        alignment TEXT NOT NULL DEFAULT 'center',
        spacing REAL NOT NULL DEFAULT 1.0,
        createdAt TEXT NOT NULL
      )
    ''');
  }
}
