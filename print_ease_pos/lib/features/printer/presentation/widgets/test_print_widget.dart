import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../settings/presentation/controllers/settings_provider.dart';
import '../controllers/printer_provider.dart';

class TestPrintWidget extends ConsumerWidget {
  const TestPrintWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final printerState = ref.watch(printerProvider);
    final settings = ref.watch(settingsProvider);
    final connected = printerState.connectedDevice != null;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.print_outlined),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Test Print',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildPaperWidthSelector(context, ref, printerState),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: printerState.isTestPrinting
                ? 'Printing...'
                : 'Print Test Receipt',
            icon: Icons.receipt_long,
            onPressed: connected && !printerState.isTestPrinting
                ? () => ref
                    .read(printerProvider.notifier)
                    .testPrint(settings.storeName)
                : null,
          ),
          if (printerState.testPrintMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildResultMessage(context, printerState.testPrintMessage!),
          ],
          if (!connected)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                'Connect a printer to enable test printing',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaperWidthSelector(
      BuildContext context, WidgetRef ref, PrinterState state) {
    return Row(
      children: [
        Text('Paper Size:',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(width: AppSpacing.md),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 58, label: Text('58mm')),
            ButtonSegment(value: 80, label: Text('80mm')),
          ],
          selected: {state.paperWidth},
          onSelectionChanged: (selected) {
            ref.read(printerProvider.notifier).setPaperWidth(selected.first);
          },
        ),
      ],
    );
  }

  Widget _buildResultMessage(BuildContext context, String message) {
    final isSuccess = message.contains('successfully');
    return Row(
      children: [
        Icon(
          isSuccess ? Icons.check_circle : Icons.error,
          size: 18,
          color: isSuccess ? Colors.green : Colors.red,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isSuccess ? Colors.green : Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}
