import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../settings/presentation/controllers/settings_provider.dart';
import '../controllers/template_provider.dart';
import '../widgets/template_preview.dart';
import '../widgets/template_settings_widgets.dart';
import '../widgets/logo_picker_widget.dart';
import '../../data/models/receipt_template.dart';

class TemplateDesignerScreen extends ConsumerStatefulWidget {
  final int? templateId;

  const TemplateDesignerScreen({super.key, this.templateId});

  @override
  ConsumerState<TemplateDesignerScreen> createState() => _TemplateDesignerScreenState();
}

class _TemplateDesignerScreenState extends ConsumerState<TemplateDesignerScreen> {
  bool _hasChanges = false;
  bool _setAsDefault = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final notifier = ref.read(templateProvider.notifier);
      if (widget.templateId != null) {
        notifier.startEditTemplate(widget.templateId!);
      } else {
        notifier.startNewTemplate();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(templateProvider);
    final template = state.editingTemplate;

    final canSave = template != null && template.name.isNotEmpty;

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || !_hasChanges) return;
        final shouldPop = await _confirmDiscard();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(template?.name ?? 'Design Template'),
          actions: [
            if (widget.templateId != null)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmDelete(),
              ),
            TextButton.icon(
              onPressed: state.isSaving || !canSave ? null : _save,
              icon: state.isSaving
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: const Text('Save'),
            ),
          ],
        ),
        body: state.isLoading
            ? const AppLoader()
            : state.error != null
                ? AppErrorView(
                    message: state.error!,
                    onRetry: () => widget.templateId != null
                        ? ref.read(templateProvider.notifier).startEditTemplate(widget.templateId!)
                        : ref.read(templateProvider.notifier).startNewTemplate(),
                  )
                : template == null
                    ? const AppErrorView(message: 'Could not create template')
                    : _buildDesigner(template),
      ),
    );
  }

  Future<bool> _confirmDiscard() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes. Do you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Widget _buildDesigner(ReceiptTemplate template) {
    final notifier = ref.read(templateProvider.notifier);

    void onChanged(VoidCallback update) {
      setState(() => _hasChanges = true);
      update();
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Center(
          child: TemplatePreview(template: template),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildSection(
          'Template',
          Icons.description,
          children: [
            TextSetting(
              label: 'Template Name',
              value: template.name,
              hint: 'e.g. Shop Receipt',
              onChanged: (v) => onChanged(() => notifier.updateName(v)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildSection(
          'Store Info',
          Icons.store,
          children: [
            TextSetting(
              label: 'Store Name',
              value: template.storeName,
              hint: 'Your store name',
              onChanged: (v) => onChanged(() => notifier.updateStoreName(v)),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextSetting(
              label: 'Phone Number',
              value: template.storePhone,
              hint: '+233 000 000 000',
              onChanged: (v) => onChanged(() => notifier.updateStorePhone(v)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildSection(
          'Header & Footer',
          Icons.text_fields,
          children: [
            TextSetting(
              label: 'Header Text',
              value: template.header,
              hint: 'Receipt header',
              maxLines: 2,
              onChanged: (v) => onChanged(() => notifier.updateHeader(v)),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextSetting(
              label: 'Footer Message',
              value: template.footer,
              hint: 'Thank you message',
              maxLines: 2,
              onChanged: (v) => onChanged(() => notifier.updateFooter(v)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildSection(
          'Logo',
          Icons.image,
          children: [
            LogoPickerWidget(
              currentPath: template.logoPath,
              onChanged: (v) => onChanged(() => notifier.updateLogoPath(v)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildSection(
          'Layout',
          Icons.design_services,
          children: [
            PaperSizeSelector(
              value: template.paperWidth,
              onChanged: (v) => onChanged(() => notifier.updatePaperWidth(v)),
            ),
            const SizedBox(height: AppSpacing.sm),
            AlignmentSelector(
              label: 'Alignment',
              isLeft: template.alignment == ReceiptAlignment.left,
              onChanged: (v) => onChanged(() => notifier.updateAlignment(
                    v ? ReceiptAlignment.left : ReceiptAlignment.center,
                  )),
            ),
            const SizedBox(height: AppSpacing.sm),
            SliderSetting(
              label: 'Font Size',
              value: template.fontSize,
              min: 0.6,
              max: 1.6,
              divisions: 10,
              displayValue: '${template.fontSize.toStringAsFixed(1)}x',
              onChanged: (v) => onChanged(() => notifier.updateFontSize(v)),
            ),
            SliderSetting(
              label: 'Spacing',
              value: template.spacing,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              displayValue: '${template.spacing.toStringAsFixed(1)}x',
              onChanged: (v) => onChanged(() => notifier.updateSpacing(v)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildSection(
          'Visibility',
          Icons.visibility,
          children: [
            ToggleSetting(
              label: 'Show Logo',
              value: template.showLogo,
              onChanged: (v) => onChanged(() => notifier.updateShowLogo(v)),
            ),
            ToggleSetting(
              label: 'Show QR Code',
              value: template.showQrCode,
              onChanged: (v) => onChanged(() => notifier.updateShowQrCode(v)),
            ),
            ToggleSetting(
              label: 'Show Divider',
              value: template.showDivider,
              onChanged: (v) => onChanged(() => notifier.updateShowDivider(v)),
            ),
            ToggleSetting(
              label: 'Show Itemized List',
              value: template.showItemizedList,
              onChanged: (v) => onChanged(() => notifier.updateShowItemizedList(v)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildSection(
          'Defaults',
          Icons.star,
          children: [
            ToggleSetting(
              label: 'Set as Default Template',
              value: _setAsDefault,
              onChanged: (v) {
                setState(() => _setAsDefault = v);
                _hasChanges = true;
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Consumer(builder: (context, ref, _) {
          final saving = ref.watch(templateProvider.select((s) => s.isSaving));
          final name = ref.watch(templateProvider.select((s) => s.editingTemplate?.name ?? ''));
          return AppButton(
            label: saving ? 'Saving...' : 'Save Template',
            icon: Icons.save,
            onPressed: saving || name.isEmpty ? null : _save,
          );
        }),
        if (widget.templateId != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Consumer(builder: (context, ref, _) {
            final saving = ref.watch(templateProvider.select((s) => s.isSaving));
            return AppButton(
              label: 'Delete Template',
              icon: Icons.delete_outline,
              variant: ButtonVariant.outlined,
              onPressed: saving ? null : _confirmDelete,
            );
          }),
        ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, {required List<Widget> children}) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title, icon: icon),
          ...children,
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final template = ref.read(templateProvider).editingTemplate;
    if (template?.id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Template?'),
        content: Text('Are you sure you want to delete "${template!.name}"?'),
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
    if (confirmed == true && mounted) {
      final t = ref.read(templateProvider).editingTemplate;
      final id = t?.id;
      if (id == null) return;
      final notifier = ref.read(templateProvider.notifier);
      await notifier.deleteTemplate(id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    final notifier = ref.read(templateProvider.notifier);
    final savedId = await notifier.saveTemplate();
    if (mounted) {
      if (savedId != null) {
        if (_setAsDefault) {
          ref.read(settingsProvider.notifier).updateDefaultTemplateId(savedId);
        }
        setState(() => _hasChanges = false);
        navigator.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save template'),
            backgroundColor: Theme.of(context).colorScheme.error,
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }
}
