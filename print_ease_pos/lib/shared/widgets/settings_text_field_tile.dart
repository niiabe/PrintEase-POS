import 'package:flutter/material.dart';

class SettingsTextFieldTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withAlpha(26),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(title, style: theme.textTheme.titleSmall),
        subtitle: TextField(
          controller: TextEditingController(text: value),
          decoration: const InputDecoration(border: InputBorder.none),
          style: theme.textTheme.bodySmall,
          onSubmitted: onChanged,
        ),
      ),
    );
  }
}
