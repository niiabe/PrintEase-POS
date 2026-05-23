import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/pdf_provider.dart';

class DownloadPdfButton extends ConsumerWidget {
  final int receiptId;
  final bool compact;

  const DownloadPdfButton({
    super.key,
    required this.receiptId,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pdfProvider);

    ref.listen<PdfState>(pdfProvider, (prev, next) {
      if (next.isExporting != (prev?.isExporting ?? false)) {
        if (!next.isExporting && next.error == null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PDF saved successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else if (next.error != null && !next.isExporting) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to save PDF: ${next.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    });

    if (compact) {
      return SizedBox(
        width: 28,
        height: 28,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: state.isExporting ? null : () => _exportPdf(ref),
          child: state.isExporting
              ? const Padding(
                  padding: EdgeInsets.all(4),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.picture_as_pdf, size: 18),
        ),
      );
    }

    return FilledButton.icon(
      onPressed: state.isExporting
          ? null
          : () => _exportPdf(ref),
      icon: state.isExporting
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.picture_as_pdf),
      label: Text(state.isExporting ? 'Saving...' : 'Download PDF'),
    );
  }

  void _exportPdf(WidgetRef ref) {
    ref.read(pdfProvider.notifier).exportReceipt(receiptId);
  }
}
