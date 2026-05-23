import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_spacing.dart';
import '../controllers/printer_provider.dart';
import '../widgets/connection_status_widget.dart';
import '../widgets/printer_scanner_widget.dart';
import '../widgets/test_print_widget.dart';

class PrinterScreen extends ConsumerStatefulWidget {
  const PrinterScreen({super.key});

  @override
  ConsumerState<PrinterScreen> createState() => _PrinterScreenState();
}

class _PrinterScreenState extends ConsumerState<PrinterScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(printerProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(printerProvider, (previous, next) {
      if (next.error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () => ref.read(printerProvider.notifier).clearError(),
            ),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Printers')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ConnectionStatusWidget(),
            const SizedBox(height: AppSpacing.md),
            const TestPrintWidget(),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Available Printers',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 300,
              child: const PrinterScannerWidget(),
            ),
          ],
        ),
      ),
    );
  }
}

