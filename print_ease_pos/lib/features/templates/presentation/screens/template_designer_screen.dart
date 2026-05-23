import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../../shared/widgets/app_error_view.dart';
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

    final saveable = template != null && template.name.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(template?.name ?? 'Design Template'),
        actions: [
          if (saveable)
            TextButton.icon(
              onPressed: state.isSaving ? null : _save,
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
    );
  }

  Widget _buildDesigner(ReceiptTemplate template) {
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
              onChanged: (v) => ref.read(templateProvider.notifier).updateName(v),
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
              onChanged: (v) => ref.read(templateProvider.notifier).updateStoreName(v),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextSetting(
              label: 'Phone Number',
              value: template.storePhone,
              hint: '+233 000 000 000',
              onChanged: (v) => ref.read(templateProvider.notifier).updateStorePhone(v),
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
              onChanged: (v) => ref.read(templateProvider.notifier).updateHeader(v),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextSetting(
              label: 'Footer Message',
              value: template.footer,
              hint: 'Thank you message',
              maxLines: 2,
              onChanged: (v) => ref.read(templateProvider.notifier).updateFooter(v),
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
              onChanged: (v) => ref.read(templateProvider.notifier).updateLogoPath(v),
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
              onChanged: (v) => ref.read(templateProvider.notifier).updatePaperWidth(v),
            ),
            const SizedBox(height: AppSpacing.sm),
            AlignmentSelector(
              label: 'Alignment',
              isLeft: template.alignment == ReceiptAlignment.left,
              onChanged: (v) => ref.read(templateProvider.notifier).updateAlignment(
                    v ? ReceiptAlignment.left : ReceiptAlignment.center,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SliderSetting(
              label: 'Font Size',
              value: template.fontSize,
              min: 0.6,
              max: 1.6,
              divisions: 10,
              displayValue: '${template.fontSize.toStringAsFixed(1)}x',
              onChanged: (v) => ref.read(templateProvider.notifier).updateFontSize(v),
            ),
            SliderSetting(
              label: 'Spacing',
              value: template.spacing,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              displayValue: '${template.spacing.toStringAsFixed(1)}x',
              onChanged: (v) => ref.read(templateProvider.notifier).updateSpacing(v),
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
              onChanged: (v) => ref.read(templateProvider.notifier).updateShowLogo(v),
            ),
            ToggleSetting(
              label: 'Show QR Code',
              value: template.showQrCode,
              onChanged: (v) => ref.read(templateProvider.notifier).updateShowQrCode(v),
            ),
            ToggleSetting(
              label: 'Show Divider',
              value: template.showDivider,
              onChanged: (v) => ref.read(templateProvider.notifier).updateShowDivider(v),
            ),
            ToggleSetting(
              label: 'Show Itemized List',
              value: template.showItemizedList,
              onChanged: (v) => ref.read(templateProvider.notifier).updateShowItemizedList(v),
            ),
          ],
        ),
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

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    final notifier = ref.read(templateProvider.notifier);
    await notifier.saveTemplate();
    navigator.pop();
  }
}
