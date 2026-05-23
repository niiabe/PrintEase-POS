import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/printer_device.dart';

class PrinterPreferencesService {
  static const _preferredKey = 'preferred_printer';
  static const _autoConnectKey = 'auto_connect_printer';

  Future<PrinterDevice?> loadPreferredPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_preferredKey);
    if (data == null) return null;
    return PrinterDevice.fromMap(jsonDecode(data) as Map<String, dynamic>);
  }

  Future<void> savePreferredPrinter(PrinterDevice device) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferredKey, jsonEncode(device.toMap()));
  }

  Future<void> removePreferredPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_preferredKey);
  }

  Future<bool> isAutoConnectEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoConnectKey) ?? false;
  }

  Future<void> setAutoConnect(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoConnectKey, enabled);
  }
}
