import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../receipts/data/models/receipt.dart';
import '../controllers/print_controller.dart';

class PrintReceiptButton extends ConsumerStatefulWidget {
  final Receipt receipt;
  final bool isReprint;

  const PrintReceiptButton({
    super.key,
    required this.receipt,
    this.isReprint = false,
  });

  @override
  ConsumerState<PrintReceiptButton> createState() => _PrintReceiptButtonState();
}

class _PrintReceiptButtonState extends ConsumerState<PrintReceiptButton> {
  @override
  void initState() {
    super.initState();
    ref.listenManual(printControllerProvider, (previous, next) {
      if (next.message != null && mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    final printState = ref.watch(printControllerProvider);

    return AppButton(
      label: printState.isPrinting
          ? 'Printing...'
          : widget.isReprint
              ? 'Reprint'
              : 'Print Receipt',
      icon: printState.isPrinting ? null : Icons.print,
      isLoading: printState.isPrinting,
      onPressed: printState.isPrinting
          ? null
          : () {
              if (widget.isReprint) {
                ref.read(printControllerProvider.notifier).reprintReceipt(widget.receipt);
              } else {
                ref.read(printControllerProvider.notifier).printReceipt(widget.receipt);
              }
            },
    );
  }
}
