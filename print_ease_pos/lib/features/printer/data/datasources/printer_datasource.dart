import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/printer_device.dart';

class BluetoothOffException implements Exception {
  final String message;
  const BluetoothOffException([this.message = 'Bluetooth is turned off']);
  @override
  String toString() => message;
}

class BluetoothPermissionException implements Exception {
  final String message;
  const BluetoothPermissionException(
      [this.message = 'Bluetooth permission denied']);
  @override
  String toString() => message;
}

class PrinterDatasource {
  Future<List<PrinterDevice>> scanDevices() async {
    final bool isEnabled = await PrintBluetoothThermal.bluetoothEnabled;
    if (!isEnabled) {
      throw const BluetoothOffException();
    }
    try {
      final available = await PrintBluetoothThermal.pairedBluetooths;
      return available
          .map((d) => PrinterDevice(
                name: d.name,
                address: d.macAdress,
              ))
          .toList();
    } on PlatformException catch (e) {
      final msg = e.message?.toLowerCase() ?? '';
      if (msg.contains('bluetooth') && msg.contains('off')) {
        throw const BluetoothOffException();
      }
      if (msg.contains('permission')) {
        throw const BluetoothPermissionException();
      }
      rethrow;
    }
  }

  Future<bool> connect(PrinterDevice device) async {
    try {
      return await PrintBluetoothThermal.connect(
        macPrinterAddress: device.address,
      );
    } on PlatformException catch (e) {
      final msg = e.message?.toLowerCase() ?? '';
      if (msg.contains('bluetooth') && msg.contains('off')) {
        throw const BluetoothOffException();
      }
      rethrow;
    }
  }

  Future<bool> disconnect() async {
    return await PrintBluetoothThermal.disconnect;
  }

  Future<bool> isConnected() async {
    return await PrintBluetoothThermal.connectionStatus;
  }

  Future<bool> printBytes(List<int> bytes) async {
    try {
      return await PrintBluetoothThermal.writeBytes(bytes);
    } catch (e) {
      debugPrint('Print error: $e');
      return false;
    }
  }

  Future<List<int>> generateTestReceipt({
    required String storeName,
    required int paperWidth,
  }) async {
    final profile = await CapabilityProfile.load();
    final paperSize = paperWidth == 58 ? PaperSize.mm58 : PaperSize.mm80;
    final generator = Generator(paperSize, profile);

    var bytes = <int>[];

    bytes += generator.text(
      'TEST PRINT',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.feed(1);
    bytes += generator.text(storeName,
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.feed(1);
    bytes += generator.hr();
    bytes += generator.text('Printer Connection: OK',
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('Paper Width: ${paperWidth}mm',
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('Date: ${DateTime.now().toLocal()}',
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.hr();
    bytes += generator.text('If you can read this,',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('your printer is working!',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }
}
