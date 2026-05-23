import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../../shared/widgets/app_error_view.dart';
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
    return PdfPreview(
      build: (format) => bytes,
      canChangePageFormat: false,
      canChangeOrientation: false,
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
