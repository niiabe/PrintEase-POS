import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../receipts/data/models/receipt.dart';
import '../controllers/print_controller.dart';

class PrintReceiptButton extends ConsumerWidget {
  final Receipt receipt;
  final bool isReprint;

  const PrintReceiptButton({
    super.key,
    required this.receipt,
    this.isReprint = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final printState = ref.watch(printControllerProvider);

    ref.listen(printControllerProvider, (previous, next) {
      if (next.message != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message!),
            backgroundColor: next.isSuccess ? Colors.green : Colors.red,
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () => ref.read(printControllerProvider.notifier).clearMessage(),
            ),
          ),
        );
      }
    });

    return AppButton(
      label: printState.isPrinting
          ? 'Printing...'
          : isReprint
              ? 'Reprint'
              : 'Print Receipt',
      icon: printState.isPrinting ? null : Icons.print,
      isLoading: printState.isPrinting,
      onPressed: printState.isPrinting
          ? null
          : () {
              if (isReprint) {
                ref.read(printControllerProvider.notifier).reprintReceipt(receipt);
              } else {
                ref.read(printControllerProvider.notifier).printReceipt(receipt);
              }
            },
    );
  }
}
