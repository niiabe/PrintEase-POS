import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../core/constants/app_spacing.dart';
import '../controllers/printer_provider.dart';

class ConnectionStatusWidget extends ConsumerWidget {
  const ConnectionStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(printerProvider);
    final device = state.connectedDevice;

    if (device == null) {
      return AppCard(
        child: ListTile(
          leading: const Icon(Icons.print_disabled, color: Colors.grey),
          title: const Text('No Printer Connected'),
          subtitle: const Text('Scan and connect to a Bluetooth printer'),
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.print, color: Colors.green),
            title: Text(device.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.address),
                Text(
                  device.paperSizeLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => ref.read(printerProvider.notifier).disconnect(),
            ),
          ),
          if (device.lastConnected != null)
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.md, bottom: AppSpacing.sm),
              child: Text(
                'Last connected: ${_formatDate(device.lastConnected!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
