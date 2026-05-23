import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class BackupResult {
  final bool success;
  final String? message;
  final String? filePath;

  const BackupResult({required this.success, this.message, this.filePath});
}

class BackupService {
  Future<BackupResult> exportBackup() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final backupDir = Directory('${dir.path}/backups/backup_$timestamp');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final dbPath = await getDatabasesPath();
      final dbFile = File('$dbPath/print_ease_pos.db');
      if (await dbFile.exists()) {
        await dbFile.copy('${backupDir.path}/database.db');
      }

      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('app_settings');
      if (settingsJson != null) {
        await File('${backupDir.path}/settings.json').writeAsString(settingsJson);
      }

      _exportTemplates(backupDir);

      final resultDir = backupDir.path;
      return BackupResult(
        success: true,
        message: 'Backup created successfully',
        filePath: resultDir,
      );
    } catch (e) {
      return BackupResult(
        success: false,
        message: 'Backup failed: $e',
      );
    }
  }

  Future<BackupResult> importBackup() async {
    try {
      final result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select backup folder',
      );
      if (result == null) {
        return const BackupResult(
          success: false,
          message: 'No folder selected',
        );
      }

      final backupDir = Directory(result);
      if (!await backupDir.exists()) {
        return const BackupResult(
          success: false,
          message: 'Selected folder does not exist',
        );
      }

      await _importDatabase(backupDir);
      await _importSettings(backupDir);
      _importTemplates(backupDir);

      return const BackupResult(
        success: true,
        message: 'Backup restored successfully',
      );
    } catch (e) {
      return BackupResult(
        success: false,
        message: 'Restore failed: $e',
      );
    }
  }

  Future<void> _exportTemplates(Directory backupDir) async {
    final dbPath = await getDatabasesPath();
    final db = await openDatabase('$dbPath/print_ease_pos.db');
    try {
      final maps = await db.query('templates');
      final data = jsonEncode(maps);
      await File('${backupDir.path}/templates.json').writeAsString(data);
    } catch (_) {
    } finally {
      await db.close();
    }
  }

  Future<void> _importDatabase(Directory backupDir) async {
    final dbFile = File('${backupDir.path}/database.db');
    if (!await dbFile.exists()) return;

    final dbPath = await getDatabasesPath();
    final target = File('$dbPath/print_ease_pos.db');
    await dbFile.copy(target.path);
  }

  Future<void> _importSettings(Directory backupDir) async {
    final settingsFile = File('${backupDir.path}/settings.json');
    if (!await settingsFile.exists()) return;

    final json = await settingsFile.readAsString();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_settings', json);
  }

  Future<void> _importTemplates(Directory backupDir) async {
    final templatesFile = File('${backupDir.path}/templates.json');
    if (!await templatesFile.exists()) return;

    final json = await templatesFile.readAsString();
    final templates = jsonDecode(json) as List;

    final dbPath = await getDatabasesPath();
    final db = await openDatabase('$dbPath/print_ease_pos.db');
    try {
      for (final t in templates) {
        final existing = await db.query(
          'templates',
          where: 'id = ?',
          whereArgs: [t['id']],
        );
        if (existing.isNotEmpty) {
          await db.update('templates', t as Map<String, dynamic>,
              where: 'id = ?', whereArgs: [t['id']]);
        } else {
          await db.insert('templates', t as Map<String, dynamic>);
        }
      }
    } finally {
      await db.close();
    }
  }
}
