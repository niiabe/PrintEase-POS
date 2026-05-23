import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/receipt_template.dart';

class TemplatePreview extends StatelessWidget {
  final ReceiptTemplate template;

  const TemplatePreview({super.key, required this.template});

  @override
  Widget build(BuildContext context) {
    final fontSize = 8.0 + (template.fontSize * 4);
    final spacing = template.spacing * 4;

    return Container(
      width: template.paperWidth == 58 ? 220 : 300,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: template.alignment == ReceiptAlignment.left
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          if (template.showLogo && template.logoPath != null)
            Padding(
              padding: EdgeInsets.only(bottom: spacing),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.file(
                  File(template.logoPath!),
                  height: 40,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.image,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          if (template.showLogo && template.logoPath == null)
            Padding(
              padding: EdgeInsets.only(bottom: spacing),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          if (template.storeName.isNotEmpty)
            Text(
              template.storeName,
              textAlign: template.alignment == ReceiptAlignment.center
                  ? TextAlign.center
                  : TextAlign.start,
              style: TextStyle(
                fontSize: fontSize + 4,
                fontWeight: FontWeight.bold,
              ),
            ),
          SizedBox(height: spacing),
          if (template.header.isNotEmpty)
            Text(
              template.header,
              textAlign: template.alignment == ReceiptAlignment.center
                  ? TextAlign.center
                  : TextAlign.start,
              style: TextStyle(fontSize: fontSize - 2, color: Colors.grey.shade700),
            ),
          SizedBox(height: spacing),
          if (template.showDivider)
            Divider(height: 1, color: Colors.grey.shade400),
          SizedBox(height: spacing),
          if (template.showItemizedList) ...[
            _previewRow('Item 1', '2', '10.00', fontSize),
            SizedBox(height: spacing * 0.5),
            _previewRow('Item 2', '1', '15.00', fontSize),
            SizedBox(height: spacing * 0.5),
            _previewRow('Item 3', '3', '7.50', fontSize),
          ],
          SizedBox(height: spacing),
          if (template.showDivider)
            Divider(height: 1, color: Colors.grey.shade400),
          SizedBox(height: spacing),
          _totalsPreview('Subtotal', '32.50', fontSize),
          SizedBox(height: spacing * 0.5),
          _totalsPreview('Tax (12.5%)', '4.06', fontSize),
          SizedBox(height: spacing * 0.5),
          Text(
            'GHS 36.56',
            style: TextStyle(
              fontSize: fontSize + 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: spacing),
          if (template.showDivider)
            Divider(height: 1, color: Colors.grey.shade400),
          SizedBox(height: spacing),
          Text(
            template.footer,
            textAlign: template.alignment == ReceiptAlignment.center
                ? TextAlign.center
                : TextAlign.start,
            style: TextStyle(fontSize: fontSize - 2, color: Colors.grey.shade600),
          ),
          SizedBox(height: spacing),
          if (template.showQrCode)
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _previewRow(String name, String qty, String total, double fontSize) {
    return Row(
      children: [
        Expanded(flex: 3, child: Text(name, style: TextStyle(fontSize: fontSize))),
        SizedBox(
          width: 24,
          child: Text(qty, textAlign: TextAlign.right, style: TextStyle(fontSize: fontSize)),
        ),
        SizedBox(
          width: 50,
          child: Text(total, textAlign: TextAlign.right, style: TextStyle(fontSize: fontSize)),
        ),
      ],
    );
  }

  Widget _totalsPreview(String label, String amount, double fontSize) {
    return Row(
      children: [
        Expanded(child: Text(label, style: TextStyle(fontSize: fontSize))),
        Text(amount, style: TextStyle(fontSize: fontSize)),
      ],
    );
  }
}
