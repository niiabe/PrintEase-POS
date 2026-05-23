import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/settings_slider_tile.dart';
import '../../../../shared/widgets/settings_text_field_tile.dart';
import '../../../../core/constants/app_spacing.dart';
import '../controllers/settings_provider.dart';
import '../widgets/settings_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 32),
        children: [
          _sectionHeader(theme, 'Appearance'),
          SettingsSwitchTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: 'Toggle dark/light theme',
            value: settings.isDarkMode,
            onChanged: (_) =>
                ref.read(settingsProvider.notifier).toggleDarkMode(),
          ),

          _sectionHeader(theme, 'Store Information'),
          SettingsTextFieldTile(
            icon: Icons.store,
            title: 'Store Name',
            value: settings.storeName,
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).updateStoreName(v),
          ),
          SettingsTextFieldTile(
            icon: Icons.phone,
            title: 'Phone Number',
            value: settings.storePhone,
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).updateStorePhone(v),
          ),
          SettingsTile(
            icon: Icons.currency_exchange,
            title: 'Currency',
            subtitle: settings.currency,
            onTap: () => _showCurrencyPicker(context, ref, settings.currency),
          ),
          SettingsSliderTile(
            icon: Icons.percent,
            title: 'Tax Percentage',
            value: settings.taxPercentage,
            min: 0,
            max: 50,
            divisions: 100,
            formatLabel: (v) => '${v.toStringAsFixed(1)}%',
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).updateTaxPercentage(v),
          ),

          _sectionHeader(theme, 'Printer'),
          SettingsSwitchTile(
            icon: Icons.bluetooth_connected,
            title: 'Auto-connect Printer',
            subtitle: 'Connect to last used printer on startup',
            value: settings.autoConnectPrinter,
            onChanged: (v) => ref
                .read(settingsProvider.notifier)
                .updateSettings(settings.copyWith(autoConnectPrinter: v)),
          ),
          SettingsTile(
            icon: Icons.straighten,
            title: 'Paper Width',
            subtitle: '${settings.defaultPaperWidth.toInt()}mm',
            trailing: SegmentedButton<double>(
              segments: const [
                ButtonSegment(value: 58.0, label: Text('58mm')),
                ButtonSegment(value: 80.0, label: Text('80mm')),
              ],
              selected: {settings.defaultPaperWidth},
              onSelectionChanged: (v) =>
                  ref.read(settingsProvider.notifier).updatePaperWidth(v.first),
            ),
          ),
          SettingsSliderTile(
            icon: Icons.density_small,
            title: 'Print Density',
            value: settings.printDensity.toDouble(),
            min: 0,
            max: 3,
            divisions: 3,
            formatLabel: (v) => v.toInt().toString(),
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).updatePrintDensity(v.toInt()),
          ),
          SettingsSliderTile(
            icon: Icons.text_fields,
            title: 'Character Size',
            value: settings.characterSize,
            min: 0.8,
            max: 2.0,
            divisions: 12,
            formatLabel: (v) => '${v.toStringAsFixed(1)}x',
            onChanged: (v) => ref
                .read(settingsProvider.notifier)
                .updateCharacterSize(v),
          ),
          SettingsSliderTile(
            icon: Icons.space_bar,
            title: 'Line Spacing',
            value: settings.lineSpacing.toDouble(),
            min: 0,
            max: 5,
            divisions: 5,
            formatLabel: (v) => v.toInt().toString(),
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).updateLineSpacing(v.toInt()),
          ),

          _sectionHeader(theme, 'Receipts'),
          SettingsSwitchTile(
            icon: Icons.save,
            title: 'Auto-save Receipts',
            subtitle: 'Save receipts after printing',
            value: settings.saveReceiptsAutomatically,
            onChanged: (v) => ref
                .read(settingsProvider.notifier)
                .updateSettings(settings.copyWith(saveReceiptsAutomatically: v)),
          ),
          SettingsSwitchTile(
            icon: Icons.print,
            title: 'Auto-print',
            subtitle: 'Print receipt automatically after creation',
            value: settings.autoPrint,
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).updateAutoPrint(v),
          ),

          _sectionHeader(theme, 'Data'),
          SettingsTile(
            icon: Icons.backup,
            title: 'Backup & Restore',
            subtitle: 'Export or import your data',
            onTap: () => context.push('/settings/backup'),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _showCurrencyPicker(
      BuildContext context, WidgetRef ref, String current) {
    final currencies = ['GHS', 'USD', 'EUR', 'GBP', 'JPY', 'PHP', 'THB'];
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Currency'),
        children: currencies.map((c) {
          return SimpleDialogOption(
            onPressed: () {
              ref.read(settingsProvider.notifier).updateCurrency(c);
              Navigator.pop(context);
            },
            child: Text(
              c,
              style: TextStyle(
                fontWeight: c == current ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
