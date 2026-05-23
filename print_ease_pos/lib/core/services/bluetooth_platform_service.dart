import 'package:flutter/services.dart';

class BluetoothPlatformService {
  static const _channel = MethodChannel('com.example.print_ease_pos/bluetooth');

  Future<bool> requestBluetoothEnable() async {
    try {
      final enabled = await _channel.invokeMethod<bool>('requestBluetoothEnable');
      return enabled ?? false;
    } on MissingPluginException {
      return true;
    }
  }
}
