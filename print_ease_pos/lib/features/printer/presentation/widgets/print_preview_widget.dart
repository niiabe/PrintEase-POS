import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../receipts/data/models/receipt.dart';
import '../../../receipts/data/models/receipt_item.dart';

class PrintPreviewWidget extends StatelessWidget {
  final Receipt receipt;

  const PrintPreviewWidget({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            receipt.storeName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Receipt #${receipt.receiptNumber}',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          if (receipt.customerName.isNotEmpty)
            Text(
              receipt.customerName,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(color: Colors.black12, thickness: 1),
          const SizedBox(height: AppSpacing.xs),
          _buildHeaderRow(context),
          const Divider(color: Colors.black12, thickness: 1),
          ...receipt.items.map((item) => _buildItemRow(context, item)),
          const Divider(color: Colors.black12, thickness: 1),
          _buildTotalRow('Subtotal', receipt.subtotal),
          _buildTotalRow('Tax (12.5%)', receipt.tax),
          const Divider(color: Colors.black87, thickness: 2),
          _buildTotalRow('TOTAL', receipt.total, isBold: true),
          const SizedBox(height: AppSpacing.sm),
          const Divider(color: Colors.black12, thickness: 1),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Thank you for your patronage!',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: AppSpacing.sm),
          Icon(Icons.qr_code, size: 48, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return const Row(
      children: [
        Expanded(flex: 6, child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87))),
        Expanded(flex: 2, child: Text('Qty', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87))),
        Expanded(flex: 4, child: Text('Total', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87))),
      ],
    );
  }

  Widget _buildItemRow(BuildContext context, ReceiptItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(flex: 6, child: Text(item.name, style: const TextStyle(fontSize: 11, color: Colors.black87))),
          Expanded(flex: 2, child: Text('${item.quantity}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 11, color: Colors.black87))),
          Expanded(flex: 4, child: Text(item.total.toStringAsFixed(2), textAlign: TextAlign.right, style: const TextStyle(fontSize: 11, color: Colors.black87))),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: Colors.black87)),
          Text('${receipt.currency} ${amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: Colors.black87)),
        ],
      ),
    );
  }
}
