import 'package:flutter/services.dart';

class PermissionService {
  static const _channel = MethodChannel('com.example.print_ease_pos/permissions');

  Future<bool> requestBluetoothConnect() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestBluetoothConnect');
      return result ?? false;
    } on MissingPluginException {
      return true;
    }
  }

  Future<bool> requestBluetoothScan() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestBluetoothScan');
      return result ?? false;
    } on MissingPluginException {
      return true;
    }
  }

  Future<bool> requestLocation() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestLocation');
      return result ?? false;
    } on MissingPluginException {
      return true;
    }
  }

  Future<bool> requestAllBluetoothPermissions() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestAllBluetoothPermissions');
      return result ?? false;
    } on MissingPluginException {
      return true;
    }
  }

  Future<bool> checkBluetoothConnect() async {
    try {
      final result = await _channel.invokeMethod<bool>('checkBluetoothConnect');
      return result ?? false;
    } on MissingPluginException {
      return true;
    }
  }

  Future<bool> checkBluetoothScan() async {
    try {
      final result = await _channel.invokeMethod<bool>('checkBluetoothScan');
      return result ?? false;
    } on MissingPluginException {
      return true;
    }
  }

  Future<bool> requestNotification() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestNotification');
      return result ?? false;
    } on MissingPluginException {
      return true;
    }
  }

  Future<bool> requestMediaImages() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestMediaImages');
      return result ?? false;
    } on MissingPluginException {
      return true;
    }
  }

  Future<bool> requestAllAppPermissions() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestAllAppPermissions');
      return result ?? false;
    } on MissingPluginException {
      return true;
    }
  }
}
