import 'dart:io';
import 'package:flutter/material.dart';

class BluetoothDialog {
  static Future<void> showBluetoothOff(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.bluetooth_disabled, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Bluetooth Off'),
          ],
        ),
        content: const Text(
          'Bluetooth is turned off. Please enable Bluetooth to scan and connect to thermal printers.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () {
              _openBluetoothSettings();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.settings),
            label: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  static Future<void> showPermissionsDenied(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Permission Required'),
          ],
        ),
        content: const Text(
          'Bluetooth permissions are required to scan and connect to printers. '
          'Please grant the necessary permissions in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () {
              _openAppSettings();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.settings),
            label: const Text('Open App Settings'),
          ),
        ],
      ),
    );
  }

  static void _openBluetoothSettings() {
    if (Platform.isAndroid) {
      Process.run('am', [
        'start',
        '-a',
        'android.settings.BLUETOOTH_SETTINGS',
      ]);
    }
  }

  static void _openAppSettings() {
    if (Platform.isAndroid) {
      Process.run('am', [
        'start',
        '-a',
        'android.settings.APPLICATION_DETAILS_SETTINGS',
        '-d',
        'package:print_ease_pos',
      ]);
    }
  }
}
