import 'package:flutter/material.dart';
import '../dialogs/confirm_dialog.dart';
import '../../core/constants/app_spacing.dart';

class AppDismissibleDelete extends StatelessWidget {
  final Key itemKey;
  final Widget child;
  final String confirmTitle;
  final String confirmMessage;
  final VoidCallback onDelete;
  final double borderRadius;

  const AppDismissibleDelete({
    super.key,
    required this.itemKey,
    required this.child,
    required this.confirmTitle,
    required this.confirmMessage,
    required this.onDelete,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dismissible(
      key: itemKey,
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      confirmDismiss: (_) async {
        final confirmed = await ConfirmDialog.show(
          context,
          title: confirmTitle,
          message: confirmMessage,
          confirmLabel: 'Delete',
        );
        return confirmed ?? false;
      },
      onDismissed: (_) => onDelete(),
      child: child,
    );
  }
}
