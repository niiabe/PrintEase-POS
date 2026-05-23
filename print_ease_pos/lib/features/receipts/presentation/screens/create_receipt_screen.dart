import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../settings/presentation/controllers/settings_provider.dart';
import '../../data/models/receipt.dart';
import '../controllers/receipt_provider.dart';
import '../widgets/receipt_item_input.dart';
import '../widgets/receipt_item_widget.dart';
import '../widgets/totals_widget.dart';

class CreateReceiptScreen extends ConsumerStatefulWidget {
  const CreateReceiptScreen({super.key});

  @override
  ConsumerState<CreateReceiptScreen> createState() => _CreateReceiptScreenState();
}

class _CreateReceiptScreenState extends ConsumerState<CreateReceiptScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final settings = ref.read(settingsProvider);
      ref.read(receiptProvider.notifier).startNewReceipt(settings.storeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(receiptProvider);
    final draft = state.draftReceipt;

    ref.listen(receiptProvider, (previous, next) {
      if (next.isSaving == false && previous?.isSaving == true && next.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receipt saved')),
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
        title: const Text('New Receipt'),
        actions: [
          if (draft != null && draft.items.isNotEmpty)
            TextButton.icon(
              onPressed: state.isSaving ? null : () => _saveReceipt(draft),
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
      body: draft == null
          ? const AppLoader()
          : _buildForm(context, state, draft),
    );
  }

  Widget _buildForm(BuildContext context, ReceiptState state, Receipt draft) {
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
                            .addDraftItem(item),
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
                            .updateDraftItem(idx, updated),
                      ),
                      onDelete: () => ref
                          .read(receiptProvider.notifier)
                          .removeDraftItem(idx),
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
            onChanged: (value) =>
                ref.read(receiptProvider.notifier).updateDraftNotes(value),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: state.isSaving ? 'Saving...' : 'Save Receipt',
            icon: Icons.save,
            onPressed: state.isSaving || draft.items.isEmpty
                ? null
                : () => _saveReceipt(draft),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  void _saveReceipt(Receipt draft) {
    final customer = draft.customerName;
    final notes = draft.notes;
    ref.read(receiptProvider.notifier).saveReceipt(
      draft.copyWith(
        customerName: customer,
        notes: notes,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
