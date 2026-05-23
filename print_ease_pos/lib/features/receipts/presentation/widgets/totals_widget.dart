import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../data/models/receipt.dart';

class TotalsWidget extends StatelessWidget {
  final Receipt receipt;

  const TotalsWidget({
    super.key,
    required this.receipt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        _buildRow(context, 'Subtotal', receipt.subtotal),
        const SizedBox(height: AppSpacing.xs),
        _buildRow(context, 'Tax', receipt.tax),
        const Divider(thickness: 2),
        _buildRow(context, 'Total', receipt.total, isBold: true),
      ],
    );
  }

  Widget _buildRow(BuildContext context, String label, double amount,
      {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '${receipt.currency} ${amount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
