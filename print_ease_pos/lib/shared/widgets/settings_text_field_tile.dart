import 'package:flutter/material.dart';

class SettingsTextFieldTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  final ValueChanged<String> onChanged;

  const SettingsTextFieldTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  State<SettingsTextFieldTile> createState() => _SettingsTextFieldTileState();
}

class _SettingsTextFieldTileState extends State<SettingsTextFieldTile> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(SettingsTextFieldTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withAlpha(26),
          child: Icon(widget.icon, color: theme.colorScheme.primary),
        ),
        title: Text(widget.title, style: theme.textTheme.titleSmall),
        subtitle: TextField(
          controller: _controller,
          decoration: const InputDecoration(border: InputBorder.none),
          style: theme.textTheme.bodySmall,
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}
