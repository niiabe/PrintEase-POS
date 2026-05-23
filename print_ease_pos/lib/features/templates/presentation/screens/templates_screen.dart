import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_dismissible_delete.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/template_provider.dart';

class TemplatesScreen extends ConsumerStatefulWidget {
  const TemplatesScreen({super.key});

  @override
  ConsumerState<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends ConsumerState<TemplatesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(templateProvider.notifier).loadTemplates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(templateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Templates')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.templateCreate),
        child: const Icon(Icons.add),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(TemplateState state) {
    if (state.isLoading) {
      return const AppLoader();
    }
    if (state.error != null) {
      return AppErrorView(
        message: state.error!,
        onRetry: () => ref.read(templateProvider.notifier).loadTemplates(),
      );
    }
    if (state.templates.isEmpty) {
      return const AppEmptyView(
        message: 'No templates yet',
        icon: Icons.description,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(templateProvider.notifier).loadTemplates(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: state.templates.length,
        itemBuilder: (context, index) {
          final template = state.templates[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppDismissibleDelete(
              itemKey: ValueKey(template.id),
              confirmTitle: 'Delete Template',
              confirmMessage: 'Delete "${template.name}"?',
              onDelete: () {
                ref.read(templateProvider.notifier).deleteTemplate(template.id!);
              },
              child: AppCard(
                onTap: () => context.push('/templates/${template.id}'),
                child: ListTile(
                  leading: const Icon(Icons.description),
                  title: Text(template.name),
                  subtitle: Text(
                    '${template.paperWidth.toStringAsFixed(0)}mm  •  ${template.storeName.isNotEmpty ? template.storeName : 'No store name'}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${template.fontSize.toStringAsFixed(1)}x',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _confirmDelete(context, ref, template),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, dynamic template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Template?'),
        content: Text('Are you sure you want to delete "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(templateProvider.notifier).deleteTemplate(template.id!);
    }
  }
}
