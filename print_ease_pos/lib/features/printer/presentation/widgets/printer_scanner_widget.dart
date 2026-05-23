import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../../shared/dialogs/bluetooth_dialog.dart';
import '../../../../core/constants/app_spacing.dart';
import '../controllers/printer_provider.dart';

class PrinterScannerWidget extends ConsumerWidget {
  const PrinterScannerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(printerProvider);

    ref.listen<PrinterState>(printerProvider, (prev, next) {
      if (next.isBluetoothOff && !(prev?.isBluetoothOff ?? false)) {
        BluetoothDialog.showBluetoothOff(context);
      }
      if (next.isPermissionDenied && !(prev?.isPermissionDenied ?? false)) {
        BluetoothDialog.showPermissionsDenied(context);
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: state.isScanning
                    ? 'Scanning...'
                    : 'Scan Bluetooth Printers',
                icon: Icons.bluetooth_searching,
                onPressed: state.isScanning
                    ? null
                    : () {
                        ref
                            .read(printerProvider.notifier)
                            .clearBluetoothOff();
                        ref
                            .read(printerProvider.notifier)
                            .clearPermissionDenied();
                        ref
                            .read(printerProvider.notifier)
                            .scanDevices();
                      },
              ),
            ),
            if (state.isScanning) ...[
              const SizedBox(width: AppSpacing.sm),
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: _buildDeviceList(context, ref, state),
        ),
      ],
    );
  }

  Widget _buildDeviceList(
      BuildContext context, WidgetRef ref, PrinterState state) {
    if (state.isScanning) {
      return const AppLoader(message: 'Scanning for printers...');
    }
    if (state.isBluetoothOff) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bluetooth_disabled, size: 64,
                color: Colors.orange),
            const SizedBox(height: 16),
            const Text('Bluetooth is off.\nEnable Bluetooth to find printers.',
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => BluetoothDialog.showBluetoothOff(context),
              icon: const Icon(Icons.settings),
              label: const Text('Enable Bluetooth'),
            ),
          ],
        ),
      );
    }
    if (state.isPermissionDenied) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 64,
                color: Colors.red),
            const SizedBox(height: 16),
            const Text('Bluetooth permission denied.\nGrant permission to scan.',
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => BluetoothDialog.showPermissionsDenied(context),
              icon: const Icon(Icons.settings),
              label: const Text('Grant Permission'),
            ),
          ],
        ),
      );
    }
    if (state.devices.isEmpty) {
      return const AppEmptyView(
        message:
            'No printers found.\nTap scan to search for Bluetooth devices.',
        icon: Icons.bluetooth_disabled,
      );
    }
    return ListView.builder(
      itemCount: state.devices.length,
      itemBuilder: (context, index) {
        final device = state.devices[index];
        final isConnectingToThis = state.isConnecting;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: AppCard(
            onTap: isConnectingToThis
                ? null
                : () => ref.read(printerProvider.notifier).connect(device),
            child: ListTile(
              leading: const Icon(Icons.bluetooth),
              title: Text(device.name),
              subtitle: Text(device.address),
              trailing: isConnectingToThis
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_forward),
            ),
          ),
        );
      },
    );
  }
}
