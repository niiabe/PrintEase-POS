import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../core/constants/app_spacing.dart';

class LogoPickerWidget extends StatelessWidget {
  final String? currentPath;
  final ValueChanged<String?> onChanged;

  const LogoPickerWidget({
    super.key,
    required this.currentPath,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Logo', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            if (currentPath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(currentPath!),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _placeholder(),
                ),
              )
            else
              _placeholder(),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                children: [
                  AppButton(
                    label: 'Pick Image',
                    icon: Icons.image,
                    variant: ButtonVariant.outlined,
                    isExpanded: true,
                    onPressed: () => _pickImage(context, ImageSource.gallery),
                  ),
                  if (currentPath != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    AppButton(
                      label: 'Remove',
                      icon: Icons.close,
                      variant: ButtonVariant.text,
                      isExpanded: true,
                      onPressed: () => onChanged(null),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, maxWidth: 512);
    if (image != null) {
      onChanged(image.path);
    }
  }
}
