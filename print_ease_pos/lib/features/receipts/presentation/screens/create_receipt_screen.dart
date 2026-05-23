import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../printer/presentation/controllers/print_controller.dart';
import '../../../settings/presentation/controllers/settings_provider.dart';
import '../../data/models/receipt.dart';
import '../controllers/receipt_provider.dart';
import '../widgets/receipt_item_input.dart';
import '../widgets/receipt_item_widget.dart';
import '../widgets/totals_widget.dart';

class CreateReceiptScreen extends ConsumerStatefulWidget {
  final int? editReceiptId;

  const CreateReceiptScreen({super.key, this.editReceiptId});

  @override
  ConsumerState<CreateReceiptScreen> createState() => _CreateReceiptScreenState();
}

class _CreateReceiptScreenState extends ConsumerState<CreateReceiptScreen> {
  final _customerCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _initialize());
  }

  Future<void> _initialize() async {
    final notifier = ref.read(receiptProvider.notifier);
    final settings = ref.read(settingsProvider);

    if (widget.editReceiptId != null) {
      await notifier.loadReceiptById(widget.editReceiptId!);
      final state2 = ref.read(receiptProvider);
      final existing = state2.selectedReceipt;
      if (existing != null && mounted) {
        notifier.startEditReceipt(existing);
        _customerCtrl.text = existing.customerName;
        _notesCtrl.text = existing.notes ?? '';
      }
    } else {
      notifier.startNewReceipt(settings.storeName);
    }
    if (mounted) _initialized = true;
  }

  @override
  void dispose() {
    _customerCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(receiptProvider);
    final draft = state.draftReceipt;
    final isEditing = widget.editReceiptId != null;
    final settings = ref.watch(settingsProvider);
    final taxPct = settings.taxPercentage;

    ref.listen(receiptProvider, (previous, next) {
      if (next.isSaving == false && previous?.isSaving == true && next.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? 'Receipt updated' : 'Receipt saved')),
        );
        Navigator.of(context).pop();
      }
      if (next.error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.error}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Receipt' : 'New Receipt'),
        actions: [
          if (draft != null && draft.items.isNotEmpty)
            TextButton.icon(
              onPressed: state.isSaving ? null : () => _saveReceipt(draft, taxPct),
              icon: state.isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('Save'),
            ),
        ],
      ),
      body: draft == null || !_initialized
          ? const AppLoader()
          : _buildForm(context, state, draft, taxPct),
    );
  }

  Widget _buildForm(BuildContext context, ReceiptState state, Receipt draft, double taxPct) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Receipt #${draft.receiptNumber}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Store: ${draft.storeName}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Date: ${_formatDate(draft.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppInput(
            label: 'Customer Name',
            hint: 'Optional',
            controller: _customerCtrl,
            onChanged: (value) =>
                ref.read(receiptProvider.notifier).updateDraftCustomer(value),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Items',
                        style: Theme.of(context).textTheme.titleMedium),
                    TextButton.icon(
                      onPressed: () => ReceiptItemInput.show(
                        context,
                        onSave: (item) => ref
                            .read(receiptProvider.notifier)
                            .addDraftItem(item, taxPercentage: taxPct),
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Item'),
                    ),
                  ],
                ),
                const Divider(),
                if (draft.items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Center(child: Text('No items added yet')),
                  )
                else
                  ...draft.items.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    return ReceiptItemWidget(
                      item: item,
                      index: idx,
                      onEdit: () => ReceiptItemInput.show(
                        context,
                        initialItem: item,
                        onSave: (updated) => ref
                            .read(receiptProvider.notifier)
                            .updateDraftItem(idx, updated, taxPercentage: taxPct),
                      ),
                      onDelete: () => ref
                          .read(receiptProvider.notifier)
                          .removeDraftItem(idx, taxPercentage: taxPct),
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: TotalsWidget(receipt: draft),
          ),
          const SizedBox(height: AppSpacing.md),
          AppInput(
            label: 'Notes',
            hint: 'Optional notes',
            maxLines: 3,
            controller: _notesCtrl,
            onChanged: (value) =>
                ref.read(receiptProvider.notifier).updateDraftNotes(value),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: state.isSaving ? 'Saving...' : 'Save Receipt',
            icon: Icons.save,
            onPressed: state.isSaving || draft.items.isEmpty
                ? null
                : () => _saveReceipt(draft, taxPct),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Future<void> _saveReceipt(Receipt draft, double taxPct) async {
    final notifier = ref.read(receiptProvider.notifier);
    final settings = ref.read(settingsProvider);

    final receipt = draft.copyWith(
      customerName: _customerCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    if (widget.editReceiptId != null) {
      final success = await notifier.updateReceipt(receipt);
      if (success && settings.autoPrint && context.mounted) {
        ref.read(printControllerProvider.notifier).printReceipt(receipt);
      }
    } else {
      final id = await notifier.saveReceipt(receipt);
      if (id != null && settings.autoPrint && context.mounted) {
        final saved = receipt.copyWith(id: id);
        ref.read(printControllerProvider.notifier).printReceipt(saved);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
