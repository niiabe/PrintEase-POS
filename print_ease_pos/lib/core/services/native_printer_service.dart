import 'package:flutter/services.dart';

class NativePrinterService {
  static const _channel = MethodChannel('com.example.print_ease_pos/native_printer');

  Future<List<Map<String, String>>?> discoverDevices() async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>('discoverDevices');
      if (result == null) return null;
      return result.map((m) {
        final map = m as Map;
        return <String, String>{
          'name': (map['name'] as String?) ?? 'Unknown',
          'address': (map['address'] as String?) ?? '',
        };
      }).toList();
    } on MissingPluginException {
      return null;
    }
  }

  Future<bool> connect(String address) async {
    try {
      await _channel.invokeMethod('connect', {'address': address});
      return true;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> disconnect() async {
    try {
      await _channel.invokeMethod('disconnect');
      return true;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> isConnected() async {
    try {
      final result = await _channel.invokeMethod<bool>('isConnected');
      return result ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> writeBytes(List<int> data) async {
    try {
      await _channel.invokeMethod('writeBytes', {'data': data});
      return true;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> printTestReceipt(String storeName) async {
    try {
      await _channel.invokeMethod('printTestReceipt', {'storeName': storeName});
      return true;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<Map<String, String>?> getConnectedDevice() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('getConnectedDevice');
      if (result == null) return null;
      return {
        'name': result['name'] as String? ?? '',
        'address': result['address'] as String? ?? '',
      };
    } on MissingPluginException {
      return null;
    }
  }
}
