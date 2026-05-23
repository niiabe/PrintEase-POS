import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/bluetooth_platform_service.dart';
import '../../data/datasources/printer_datasource.dart';
import '../../data/datasources/printer_preferences_service.dart';
import '../../data/models/printer_device.dart';
import '../../data/repositories/printer_repository.dart';

class PrinterState {
  final List<PrinterDevice> devices;
  final PrinterDevice? connectedDevice;
  final bool isScanning;
  final bool isConnecting;
  final bool isTestPrinting;
  final bool isBluetoothOff;
  final bool isPermissionDenied;
  final int paperWidth;
  final String? error;
  final String? testPrintMessage;

  const PrinterState({
    this.devices = const [],
    this.connectedDevice,
    this.isScanning = false,
    this.isConnecting = false,
    this.isTestPrinting = false,
    this.isBluetoothOff = false,
    this.isPermissionDenied = false,
    this.paperWidth = 80,
    this.error,
    this.testPrintMessage,
  });

  PrinterState copyWith({
    List<PrinterDevice>? devices,
    PrinterDevice? connectedDevice,
    bool? isScanning,
    bool? isConnecting,
    bool? isTestPrinting,
    bool? isBluetoothOff,
    bool? isPermissionDenied,
    int? paperWidth,
    String? error,
    String? testPrintMessage,
  }) {
    return PrinterState(
      devices: devices ?? this.devices,
      connectedDevice: connectedDevice ?? this.connectedDevice,
      isScanning: isScanning ?? this.isScanning,
      isConnecting: isConnecting ?? this.isConnecting,
      isTestPrinting: isTestPrinting ?? this.isTestPrinting,
      isBluetoothOff: isBluetoothOff ?? this.isBluetoothOff,
      isPermissionDenied: isPermissionDenied ?? this.isPermissionDenied,
      paperWidth: paperWidth ?? this.paperWidth,
      error: error,
      testPrintMessage: testPrintMessage,
    );
  }
}

class PrinterNotifier extends StateNotifier<PrinterState> {
  final PrinterRepository _repository;
  Timer? _scanTimer;

  PrinterNotifier(this._repository) : super(const PrinterState());

  Future<void> init() async {
    final device = await _repository.tryAutoConnect();
    if (device != null) {
      state = state.copyWith(connectedDevice: device);
    }
  }

  void setPaperWidth(int width) {
    state = state.copyWith(paperWidth: width, error: null);
  }

  Future<void> scanDevices() async {
    _scanTimer?.cancel();
    state = state.copyWith(
      isScanning: true,
      error: null,
      devices: [],
      isBluetoothOff: false,
      isPermissionDenied: false,
    );
    _scanTimer = Timer(const Duration(seconds: 15), () {
      if (state.isScanning) {
        state = state.copyWith(
          isScanning: false,
          error: 'Scan timed out. Try again.',
        );
      }
    });
    try {
      final devices = await _repository.scanDevices();
      _scanTimer?.cancel();
      if (state.isScanning) {
        state = state.copyWith(devices: devices, isScanning: false);
      }
    } on BluetoothOffException {
      _scanTimer?.cancel();
      state = state.copyWith(
        isScanning: false,
        isBluetoothOff: true,
        error: 'Bluetooth is turned off',
      );
    } on BluetoothPermissionException {
      _scanTimer?.cancel();
      state = state.copyWith(
        isScanning: false,
        isPermissionDenied: true,
        error: 'Bluetooth permission denied',
      );
    } catch (e) {
      _scanTimer?.cancel();
      final err = e.toString();
      if (err.contains('BLUETOOTH') || err.contains('bluetooth')) {
        state = state.copyWith(
          isScanning: false,
          isBluetoothOff: true,
          error: 'Bluetooth is not available',
        );
      } else {
        state = state.copyWith(
          isScanning: false,
          error: 'Failed to scan: $err',
        );
      }
    }
  }

  void cancelScan() {
    _scanTimer?.cancel();
    state = state.copyWith(isScanning: false, error: 'Scan cancelled');
  }

  Future<void> connect(PrinterDevice device) async {
    state = state.copyWith(isConnecting: true, error: null);
    try {
      final success = await _repository.connect(device);
      if (success) {
        state = state.copyWith(
          connectedDevice: device.copyWith(isConnected: true),
          isConnecting: false,
        );
      } else {
        state = state.copyWith(
          isConnecting: false,
          error: 'Failed to connect to ${device.name}',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isConnecting: false,
        error: 'Connection failed: ${e.toString()}',
      );
    }
  }

  Future<void> disconnect() async {
    await _repository.disconnect();
    state = state.copyWith(connectedDevice: null, testPrintMessage: null);
  }

  Future<void> testPrint(String storeName) async {
    state = state.copyWith(
        isTestPrinting: true, error: null, testPrintMessage: null);
    try {
      final success =
          await _repository.testPrint(storeName, state.paperWidth);
      state = state.copyWith(
        isTestPrinting: false,
        testPrintMessage: success
            ? 'Test print sent successfully'
            : 'Test print failed',
      );
    } catch (e) {
      state = state.copyWith(
        isTestPrinting: false,
        testPrintMessage: 'Test print error: ${e.toString()}',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearTestPrintMessage() {
    state = state.copyWith(testPrintMessage: null);
  }

  void clearBluetoothOff() {
    state = state.copyWith(isBluetoothOff: false);
  }

  void clearPermissionDenied() {
    state = state.copyWith(isPermissionDenied: false);
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    super.dispose();
  }
}

final bluetoothPlatformServiceProvider = Provider<BluetoothPlatformService>((ref) {
  return BluetoothPlatformService();
});

final printerDatasourceProvider = Provider<PrinterDatasource>((ref) {
  return PrinterDatasource();
});

final printerPreferencesServiceProvider =
    Provider<PrinterPreferencesService>((ref) {
  return PrinterPreferencesService();
});

final printerRepositoryProvider = Provider<PrinterRepository>((ref) {
  final datasource = ref.watch(printerDatasourceProvider);
  final preferences = ref.watch(printerPreferencesServiceProvider);
  final bluetoothService = ref.watch(bluetoothPlatformServiceProvider);
  return PrinterRepository(datasource, preferences, bluetoothService);
});

final printerProvider =
    StateNotifierProvider<PrinterNotifier, PrinterState>((ref) {
  final repository = ref.watch(printerRepositoryProvider);
  return PrinterNotifier(repository);
});
