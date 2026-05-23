import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../data/models/receipt_item.dart';

class ReceiptItemInput extends StatefulWidget {
  final ReceiptItem? initialItem;
  final ValueChanged<ReceiptItem> onSave;

  const ReceiptItemInput({
    super.key,
    this.initialItem,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    ReceiptItem? initialItem,
    required ValueChanged<ReceiptItem> onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ReceiptItemInput(initialItem: initialItem, onSave: onSave),
      ),
    );
  }

  @override
  State<ReceiptItemInput> createState() => _ReceiptItemInputState();
}

class _ReceiptItemInputState extends State<ReceiptItemInput> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _priceCtrl;
  String? _nameError;
  String? _qtyError;
  String? _priceError;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialItem?.name ?? '');
    _qtyCtrl = TextEditingController(
      text: widget.initialItem?.quantity.toString() ?? '1',
    );
    _priceCtrl = TextEditingController(
      text: widget.initialItem?.unitPrice.toStringAsFixed(2) ?? '',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _nameError = _nameCtrl.text.trim().isEmpty ? 'Item name is required' : null;
      _qtyError = null;
      _priceError = null;
      final qty = int.tryParse(_qtyCtrl.text);
      if (qty == null || qty <= 0) {
        _qtyError = 'Enter a valid quantity';
      }
      final price = double.tryParse(_priceCtrl.text);
      if (price == null || price <= 0) {
        _priceError = 'Enter a valid price';
      }
    });
    return _nameError == null && _qtyError == null && _priceError == null;
  }

  void _save() {
    if (!_validate()) return;
    final qty = int.parse(_qtyCtrl.text);
    final price = double.parse(_priceCtrl.text);
    final total = double.parse((qty * price).toStringAsFixed(2));
    widget.onSave(ReceiptItem(
      name: _nameCtrl.text.trim(),
      quantity: qty,
      unitPrice: price,
      total: total,
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            widget.initialItem != null ? 'Edit Item' : 'Add Item',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: 'Item Name',
              errorText: _nameError,
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _qtyCtrl,
                  decoration: InputDecoration(
                    labelText: 'Qty',
                    errorText: _qtyError,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: _priceCtrl,
                  decoration: InputDecoration(
                    labelText: 'Unit Price',
                    errorText: _priceError,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: widget.initialItem != null ? 'Update' : 'Add',
            icon: Icons.add,
            onPressed: _save,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
