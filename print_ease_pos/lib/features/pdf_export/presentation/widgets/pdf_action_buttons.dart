import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../core/constants/app_spacing.dart';
import '../controllers/pdf_provider.dart';

class PdfActionButtons extends ConsumerWidget {
  final int documentId;

  const PdfActionButtons({super.key, required this.documentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pdfProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: state.isSharing ? 'Sharing...' : 'Share',
                icon: Icons.share,
                isLoading: state.isSharing,
                onPressed: state.isSharing
                    ? null
                    : () => ref.read(pdfProvider.notifier).shareDocument(documentId),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppButton(
                label: 'Print',
                icon: Icons.print,
                variant: ButtonVariant.outlined,
                onPressed: state.isSharing
                    ? null
                    : () => ref.read(pdfProvider.notifier).printDocument(documentId),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: state.isDownloading ? 'Saving...' : 'Save to Downloads',
          icon: Icons.download,
          variant: ButtonVariant.outlined,
          isLoading: state.isDownloading,
          onPressed: state.isDownloading
              ? null
              : () => _saveToDownloads(context, ref, documentId),
        ),
      ],
    );
  }

  Future<void> _saveToDownloads(
      BuildContext context, WidgetRef ref, int documentId) async {
    final path = await ref
        .read(pdfProvider.notifier)
        .downloadDocument(documentId);
    if (!context.mounted) return;
    if (path != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF saved — check notification'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save PDF'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
