import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/print_status_chip.dart';
import '../../../../shared/dialogs/confirm_dialog.dart';
import '../../../printer/presentation/widgets/print_receipt_button.dart';
import '../../../pdf_export/presentation/widgets/download_pdf_button.dart';

import '../controllers/receipt_provider.dart';
import '../../data/models/receipt.dart';

class ReceiptDetailScreen extends ConsumerStatefulWidget {
  final int receiptId;

  const ReceiptDetailScreen({super.key, required this.receiptId});

  @override
  ConsumerState<ReceiptDetailScreen> createState() => _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends ConsumerState<ReceiptDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(receiptProvider.notifier).loadReceiptById(widget.receiptId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(receiptProvider);
    final receipt = state.selectedReceipt;

    return Scaffold(
      appBar: AppBar(
        title: Text(receipt != null ? '#${receipt.receiptNumber}' : 'Receipt'),
      ),
      body: _buildBody(state, receipt),
    );
  }

  Widget _buildBody(ReceiptState state, Receipt? receipt) {
    if (state.isLoading) {
      return const AppLoader();
    }
    if (state.error != null) {
      return AppErrorView(
        message: state.error!,
        onRetry: () => ref.read(receiptProvider.notifier).loadReceiptById(widget.receiptId),
      );
    }
    if (receipt == null) {
      return const AppEmptyView(message: 'Receipt not found');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReceiptInfoCard(receipt: receipt),
          const SizedBox(height: AppSpacing.md),
          _ReceiptItemsCard(receipt: receipt),
          const SizedBox(height: AppSpacing.md),
          _buildActions(receipt),
        ],
      ),
    );
  }

  Widget _buildActions(Receipt receipt) {
    return Column(
      children: [
        PrintReceiptButton(
          receipt: receipt,
          isReprint: receipt.printStatus == PrintStatus.printed,
        ),
        const SizedBox(height: AppSpacing.sm),
        DownloadPdfButton(receiptId: receipt.id!),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Delete Receipt',
          variant: ButtonVariant.outlined,
          icon: Icons.delete_outline,
          onPressed: () => _deleteReceipt(receipt),
        ),
      ],
    );
  }

  Future<void> _deleteReceipt(Receipt receipt) async {
    final navigator = Navigator.of(context);
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Receipt',
      message: 'Delete receipt #${receipt.receiptNumber}?',
      confirmLabel: 'Delete',
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    final notifier = ref.read(receiptProvider.notifier);
    await notifier.deleteReceipt(receipt.id!);
    navigator.pop();
  }
}

class _ReceiptInfoCard extends StatelessWidget {
  final Receipt receipt;

  const _ReceiptInfoCard({required this.receipt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '#${receipt.receiptNumber}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              PrintStatusChip(
                status: receipt.printStatus,
                label: receipt.printStatusLabel,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (receipt.customerName.isNotEmpty) ...[
            _infoRow(theme, Icons.person, receipt.customerName),
            const SizedBox(height: AppSpacing.xs),
          ],
          _infoRow(theme, Icons.calendar_today, _formatDate(receipt.createdAt)),
          const SizedBox(height: AppSpacing.xs),
          _infoRow(theme, Icons.store, receipt.storeName),
          if (receipt.notes != null && receipt.notes!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              receipt.notes!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(ThemeData theme, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.outline),
        const SizedBox(width: AppSpacing.sm),
        Text(text, style: theme.textTheme.bodyMedium),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _ReceiptItemsCard extends StatelessWidget {
  final Receipt receipt;

  const _ReceiptItemsCard({required this.receipt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Items',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...receipt.items.asMap().entries.map((entry) {
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(item.name, style: theme.textTheme.bodyMedium),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      'x${item.quantity}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: Text(
                      '${receipt.currency} ${item.unitPrice.toStringAsFixed(2)}',
                      textAlign: TextAlign.right,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: Text(
                      '${receipt.currency} ${item.total.toStringAsFixed(2)}',
                      textAlign: TextAlign.right,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const Divider(height: AppSpacing.lg),
          _totalRow(theme, 'Subtotal', receipt.subtotal, receipt.currency),
          const SizedBox(height: AppSpacing.xs),
          _totalRow(theme, 'Tax', receipt.tax, receipt.currency),
          const Divider(height: AppSpacing.md),
          _totalRow(theme, 'Total', receipt.total, receipt.currency, isTotal: true),
        ],
      ),
    );
  }

  Widget _totalRow(ThemeData theme, String label, double amount, String currency, {bool isTotal = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          '$currency ${amount.toStringAsFixed(2)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            fontSize: isTotal ? 16 : null,
          ),
        ),
      ],
    );
  }
}
