import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_dismissible_delete.dart';
import '../../../../shared/dialogs/confirm_dialog.dart';
import '../../../../core/constants/app_spacing.dart';
import '../controllers/pdf_provider.dart';
import '../../data/models/pdf_document.dart';

class PdfExportScreen extends ConsumerStatefulWidget {
  const PdfExportScreen({super.key});

  @override
  ConsumerState<PdfExportScreen> createState() => _PdfExportScreenState();
}

class _PdfExportScreenState extends ConsumerState<PdfExportScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(pdfProvider.notifier).loadDocuments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pdfProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('PDF Exports')),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(PdfState state) {
    if (state.isLoading) {
      return const AppLoader();
    }
    if (state.error != null) {
      return AppErrorView(
        message: state.error!,
        onRetry: () => ref.read(pdfProvider.notifier).loadDocuments(),
      );
    }
    if (state.documents.isEmpty) {
      return const AppEmptyView(
        message: 'No PDF exports yet.\nExport a receipt from the receipt detail screen.',
        icon: Icons.picture_as_pdf,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(pdfProvider.notifier).loadDocuments(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: state.documents.length,
        itemBuilder: (context, index) {
          final doc = state.documents[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppDismissibleDelete(
              itemKey: ValueKey(doc.id),
              confirmTitle: 'Delete PDF',
              confirmMessage: 'Delete "${doc.fileName}"?',
              onDelete: () {
                ref.read(pdfProvider.notifier).deleteDocument(doc.id!);
              },
              child: _buildDocCard(doc),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDocCard(PdfDocument doc) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: () {
        ref.read(pdfProvider.notifier).selectDocument(doc);
        context.push('/pdf-export/${doc.id}');
      },
      child: ListTile(
        leading: Icon(Icons.picture_as_pdf, color: theme.colorScheme.error, size: 32),
        title: Text(doc.fileName,
            style: theme.textTheme.bodyMedium),
        subtitle: Text(
          '${doc.fileSizeKb.toStringAsFixed(1)} KB  •  ${_formatDate(doc.createdAt)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.share, size: 20),
              onPressed: () =>
                  ref.read(pdfProvider.notifier).shareDocument(doc.id!),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: () => _deleteDocument(doc),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteDocument(PdfDocument doc) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete PDF',
      message: 'Delete "${doc.fileName}"?',
      confirmLabel: 'Delete',
    );
    if (confirmed == true && context.mounted) {
      ref.read(pdfProvider.notifier).deleteDocument(doc.id!);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
