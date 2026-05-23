import 'package:flutter/services.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'permission_service.dart';

class BluetoothPlatformService {
  static const _channel = MethodChannel('com.example.print_ease_pos/bluetooth');
  final PermissionService _permissionService = PermissionService();

  Future<bool> requestBluetoothEnable() async {
    try {
      final enabled = await _channel.invokeMethod<bool>('requestBluetoothEnable');
      return enabled ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> ensureBluetoothPermissions() async {
    return _permissionService.requestAllBluetoothPermissions();
  }

  Future<bool> hasBluetoothPermission() async {
    return _permissionService.checkBluetoothConnect();
  }

  Future<bool> isBluetoothEnabled() async {
    try {
      return await PrintBluetoothThermal.bluetoothEnabled;
    } catch (_) {
      return false;
    }
  }
}
