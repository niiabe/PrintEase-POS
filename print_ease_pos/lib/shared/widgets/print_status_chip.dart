import 'package:flutter/material.dart';
import '../../features/receipts/data/models/receipt.dart';

class PrintStatusChip extends StatelessWidget {
  final PrintStatus status;
  final String label;

  const PrintStatusChip({
    super.key,
    required this.status,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPrinted = status == PrintStatus.printed;
    final isFailed = status == PrintStatus.failed;
    final color = isPrinted ? Colors.green : (isFailed ? Colors.red : Colors.orange);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
