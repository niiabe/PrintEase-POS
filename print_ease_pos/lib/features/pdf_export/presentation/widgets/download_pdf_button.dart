import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/pdf_provider.dart';

class DownloadPdfButton extends ConsumerStatefulWidget {
  final int receiptId;
  final bool compact;

  const DownloadPdfButton({
    super.key,
    required this.receiptId,
    this.compact = false,
  });

  @override
  ConsumerState<DownloadPdfButton> createState() => _DownloadPdfButtonState();
}

class _DownloadPdfButtonState extends ConsumerState<DownloadPdfButton> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pdfProvider);

    if (widget.compact) {
      return SizedBox(
        width: 28,
        height: 28,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: state.isExporting ? null : () => _exportAndShare(ref),
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
          : () => _exportAndShare(ref),
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
      label: Text(state.isExporting ? 'Please wait...' : 'Download & Share'),
    );
  }

  Future<void> _exportAndShare(WidgetRef ref) async {
    await ref.read(pdfProvider.notifier).exportReceipt(widget.receiptId);
    if (!mounted) return;

    final pdfState = ref.read(pdfProvider);
    if (pdfState.error != null) {
      _showError(pdfState.error!);
      return;
    }

    final doc = pdfState.selectedDocument;
    final docId = doc?.id;
    if (docId == null) return;

    await ref.read(pdfProvider.notifier).shareDocument(docId);
    if (!mounted) return;

    final afterShare = ref.read(pdfProvider);
    if (afterShare.error != null) {
      _showError(afterShare.error!);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
