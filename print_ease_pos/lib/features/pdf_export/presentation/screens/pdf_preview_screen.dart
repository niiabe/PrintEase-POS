import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/dialogs/confirm_dialog.dart';
import '../../data/models/pdf_document.dart';
import '../controllers/pdf_provider.dart';
import '../widgets/pdf_action_buttons.dart';

class PdfPreviewScreen extends ConsumerStatefulWidget {
  final int documentId;

  const PdfPreviewScreen({super.key, required this.documentId});

  @override
  ConsumerState<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends ConsumerState<PdfPreviewScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(pdfProvider.notifier).loadPdfBytes(widget.documentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pdfProvider);
    final doc = state.selectedDocument;

    return Scaffold(
      appBar: AppBar(
        title: Text(doc?.fileName ?? 'PDF Preview'),
        actions: [
          if (doc != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _deleteDocument(doc.id!),
            ),
        ],
      ),
      body: _buildBody(state, doc),
    );
  }

  Widget _buildBody(PdfState state, PdfDocument? doc) {
    if (state.isLoading) {
      return const AppLoader();
    }
    if (state.error != null) {
      return AppErrorView(
        message: state.error!,
        onRetry: () =>
            ref.read(pdfProvider.notifier).loadPdfBytes(widget.documentId),
      );
    }
    if (state.pdfBytes == null || doc == null) {
      return const AppErrorView(message: 'PDF not found');
    }

    return Column(
      children: [
        Expanded(child: _buildPreview(state, state.pdfBytes!)),
        _buildActions(doc.id!),
      ],
    );
  }

  Widget _buildPreview(PdfState pdfState, Uint8List bytes) {
    final fileName = pdfState.selectedDocument?.fileName ?? 'document';
    final fileSizeKb = pdfState.selectedDocument?.fileSizeKb ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            bytes,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => AppCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.picture_as_pdf,
                      size: 64, color: Colors.red),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'PDF ($fileName)',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${fileSizeKb.toStringAsFixed(1)} KB',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(int documentId) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: PdfActionButtons(documentId: documentId),
    );
  }

  Future<void> _deleteDocument(int id) async {
    final navigator = Navigator.of(context);
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete PDF',
      message: 'Delete this PDF export?',
      confirmLabel: 'Delete',
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    await ref.read(pdfProvider.notifier).deleteDocument(id);
    navigator.pop();
  }
}
