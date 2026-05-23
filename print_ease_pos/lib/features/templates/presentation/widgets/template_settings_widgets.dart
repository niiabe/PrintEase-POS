import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;

  const SectionHeader({super.key, required this.title, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class ToggleSetting extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ToggleSetting({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      value: value,
      onChanged: onChanged,
    );
  }
}

class SliderSetting extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String displayValue;
  final ValueChanged<double> onChanged;

  const SliderSetting({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.divisions = 10,
    required this.displayValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label,
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
            Text(displayValue,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    )),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class TextSetting extends StatefulWidget {
  final String label;
  final String value;
  final String? hint;
  final int? maxLines;
  final ValueChanged<String> onChanged;

  const TextSetting({
    super.key,
    required this.label,
    required this.value,
    this.hint,
    this.maxLines = 1,
    required this.onChanged,
  });

  @override
  State<TextSetting> createState() => _TextSettingState();
}

class _TextSettingState extends State<TextSetting> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(TextSetting oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
      _controller.selection = TextSelection.collapsed(offset: widget.value.length);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.hint,
            isDense: true,
          ),
          maxLines: widget.maxLines,
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}

class PaperSizeSelector extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const PaperSizeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Paper Size',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<double>(
          segments: const [
            ButtonSegment(value: 58.0, label: Text('58mm')),
            ButtonSegment(value: 80.0, label: Text('80mm')),
          ],
          selected: {value},
          onSelectionChanged: (v) => onChanged(v.first),
        ),
      ],
    );
  }
}

class AlignmentSelector extends StatelessWidget {
  final String label;
  final bool isLeft;
  final ValueChanged<bool> onChanged;

  const AlignmentSelector({
    super.key,
    required this.label,
    required this.isLeft,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('Left'), icon: Icon(Icons.format_align_left)),
            ButtonSegment(value: false, label: Text('Center'), icon: Icon(Icons.format_align_center)),
          ],
          selected: {isLeft},
          onSelectionChanged: (v) => onChanged(v.first),
        ),
      ],
    );
  }
}
