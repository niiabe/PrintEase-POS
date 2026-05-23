import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../../../routes/app_routes.dart';
import '../../../receipts/presentation/controllers/receipt_provider.dart';
import '../../../receipts/data/models/receipt.dart';
import '../../../printer/presentation/controllers/printer_provider.dart';
import '../../../settings/presentation/controllers/settings_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(receiptProvider.notifier).loadReceipts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final receiptState = ref.watch(receiptProvider);
    final printerState = ref.watch(printerProvider);
    final settings = ref.watch(settingsProvider);
    final todayReceipts = _todayReceipts(receiptState.receipts);
    final todayTotal = _todayTotal(todayReceipts);

    return Scaffold(
      appBar: AppBar(
        title: Text(settings.storeName),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(receiptProvider.notifier).loadReceipts(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsRow(todayReceipts.length, todayTotal, settings.currency),
              const SizedBox(height: AppSpacing.md),
              _buildPrinterStatus(printerState),
              const SizedBox(height: AppSpacing.md),
              _buildQuickActions(context),
              const SizedBox(height: AppSpacing.md),
              _buildRecentReceipts(receiptState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(int receiptCount, double total, String currency) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: AppCard(
            child: Column(
              children: [
                Icon(Icons.receipt, size: 28, color: theme.colorScheme.primary),
                const SizedBox(height: AppSpacing.sm),
                Text('$receiptCount', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                Text('Today\'s Receipts', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: AppCard(
            child: Column(
              children: [
                Icon(Icons.attach_money, size: 28, color: theme.colorScheme.primary),
                const SizedBox(height: AppSpacing.sm),
                Text('$currency ${total.toStringAsFixed(2)}', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                Text('Today\'s Sales', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrinterStatus(PrinterState printerState) {
    final theme = Theme.of(context);
    final isConnected = printerState.connectedDevice != null;
    return AppCard(
      child: Row(
        children: [
          Icon(
            isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
            color: isConnected ? Colors.green : theme.colorScheme.outline,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnected ? 'Connected' : 'Not Connected',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (isConnected)
                  Text(
                    printerState.connectedDevice!.name,
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.go(AppRoutes.printer),
            child: const Text('Manage'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'New Receipt',
                icon: Icons.add,
                isExpanded: true,
                onPressed: () => context.push(AppRoutes.receiptCreate),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppButton(
                label: 'Scan Printer',
                icon: Icons.bluetooth_searching,
                variant: ButtonVariant.outlined,
                isExpanded: true,
                onPressed: () => context.go(AppRoutes.printer),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Templates',
                icon: Icons.article,
                variant: ButtonVariant.outlined,
                isExpanded: true,
                onPressed: () => context.go(AppRoutes.templates),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppButton(
                label: 'PDF Exports',
                icon: Icons.picture_as_pdf,
                variant: ButtonVariant.outlined,
                isExpanded: true,
                onPressed: () => context.go(AppRoutes.pdfExport),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentReceipts(ReceiptState receiptState) {
    final theme = Theme.of(context);
    final receipts = receiptState.receipts.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Receipts', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            TextButton(
              onPressed: () => context.go(AppRoutes.receipts),
              child: const Text('View All'),
            ),
          ],
        ),
        if (receiptState.isLoading)
          const AppLoader()
        else if (receipts.isEmpty)
          const AppEmptyView(
            message: 'No receipts yet.\nTap "New Receipt" to create one.',
            icon: Icons.receipt_long,
          )
        else
          ...receipts.map((r) => _receiptTile(theme, r)),
      ],
    );
  }

  Widget _receiptTile(ThemeData theme, Receipt receipt) {
    return AppCard(
      onTap: () => context.push('/receipts/${receipt.id}'),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('#${receipt.receiptNumber}', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(receipt.customerName.isNotEmpty ? receipt.customerName : 'Walk-in',
                    style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Text('${receipt.currency} ${receipt.total.toStringAsFixed(2)}',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(width: AppSpacing.sm),
          Icon(Icons.chevron_right, size: 18, color: theme.colorScheme.outline),
        ],
      ),
    );
  }

  List<Receipt> _todayReceipts(List<Receipt> all) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return all.where((r) => r.createdAt.isAfter(today)).toList();
  }

  double _todayTotal(List<Receipt> receipts) {
    double total = 0;
    for (final r in receipts) {
      total += r.total;
    }
    return double.parse(total.toStringAsFixed(2));
  }
}