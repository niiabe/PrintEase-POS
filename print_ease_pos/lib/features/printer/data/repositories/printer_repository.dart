import '../../../../core/services/bluetooth_platform_service.dart';
import '../datasources/printer_datasource.dart';
import '../datasources/printer_preferences_service.dart';
import '../models/printer_device.dart';

class PrinterRepository {
  final PrinterDatasource _datasource;
  final PrinterPreferencesService _preferences;
  final BluetoothPlatformService _bluetoothService;

  PrinterDevice? _connectedDevice;

  PrinterRepository(this._datasource, this._preferences, this._bluetoothService);

  PrinterDevice? get connectedDevice => _connectedDevice;

  Future<List<PrinterDevice>> scanDevices() async {
    try {
      return await _datasource.scanDevices();
    } on BluetoothOffException {
      await _bluetoothService.requestBluetoothEnable();
      return _datasource.scanDevices();
    }
  }

  Future<bool> connect(PrinterDevice device) async {
    final success = await _datasource.connect(device);
    if (success) {
      _connectedDevice = device.copyWith(
        isConnected: true,
        lastConnected: DateTime.now(),
      );
      await _preferences.savePreferredPrinter(_connectedDevice!);
    }
    return success;
  }

  Future<void> disconnect() async {
    await _datasource.disconnect();
    _connectedDevice = null;
  }

  Future<PrinterDevice?> tryAutoConnect() async {
    final preferred = await _preferences.loadPreferredPrinter();
    if (preferred == null) return null;
    final success = await _datasource.connect(preferred);
    if (success) {
      _connectedDevice = preferred.copyWith(
        isConnected: true,
        lastConnected: DateTime.now(),
      );
      return _connectedDevice;
    }
    return null;
  }

  Future<bool> testPrint(String storeName, int paperWidth) async {
    if (_connectedDevice == null) return false;
    final bytes = await _datasource.generateTestReceipt(
      storeName: storeName,
      paperWidth: paperWidth,
    );
    return _datasource.printBytes(bytes);
  }

  Future<bool> printRaw(List<int> bytes) async {
    if (_connectedDevice == null) return false;
    return _datasource.printBytes(bytes);
  }
}
