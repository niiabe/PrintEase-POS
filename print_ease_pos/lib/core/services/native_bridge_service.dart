import 'package:flutter/services.dart';

class NativeBridgeService {
  static const _nativePrintChannel = MethodChannel('com.example.print_ease_pos/printer');
  static const _btChannel = MethodChannel('com.example.print_ease_pos/bluetooth');

  Future<bool> isBluetoothEnabled() async {
    try {
      final result = await _btChannel.invokeMethod<bool>('isBluetoothEnabled');
      return result ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<String?> getPrinterStatus() async {
    try {
      return await _nativePrintChannel.invokeMethod<String>('getPrinterStatus');
    } on MissingPluginException {
      return null;
    }
  }
}
