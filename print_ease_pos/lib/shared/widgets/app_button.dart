import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final ButtonVariant variant;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = true,
    this.variant = ButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final button = _buildButton(context);
    if (isExpanded) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }

  Widget _buildButton(BuildContext context) {
    final loaderColor = variant == ButtonVariant.primary
        ? Colors.white
        : Theme.of(context).colorScheme.primary;
    final child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: loaderColor),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(label),
            ],
          );

    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        );
      case ButtonVariant.outlined:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        );
      case ButtonVariant.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          child: child,
        );
    }
  }
}

enum ButtonVariant { primary, outlined, text }
