import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/app_settings.dart';
import '../../data/repositories/settings_repository.dart';

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(const AppSettings());

  Future<void> loadSettings() async {
    final settings = await _repository.loadSettings();
    state = settings;
  }

  Future<void> updateSettings(AppSettings settings) async {
    state = settings;
    await _repository.saveSettings(settings);
  }

  Future<void> toggleDarkMode() async {
    final updated = state.copyWith(isDarkMode: !state.isDarkMode);
    await updateSettings(updated);
  }

  Future<void> updateStoreName(String name) async {
    final updated = state.copyWith(storeName: name);
    await updateSettings(updated);
  }

  Future<void> updateStorePhone(String phone) async {
    final updated = state.copyWith(storePhone: phone);
    await updateSettings(updated);
  }

  Future<void> updatePaperWidth(double width) async {
    final updated = state.copyWith(defaultPaperWidth: width);
    await updateSettings(updated);
  }

  Future<void> updateCurrency(String currency) async {
    final updated = state.copyWith(currency: currency);
    await updateSettings(updated);
  }

  Future<void> updateTaxPercentage(double tax) async {
    final updated = state.copyWith(taxPercentage: tax);
    await updateSettings(updated);
  }

  Future<void> updateAutoPrint(bool value) async {
    final updated = state.copyWith(autoPrint: value);
    await updateSettings(updated);
  }

  Future<void> updatePrintDensity(int density) async {
    final updated = state.copyWith(printDensity: density);
    await updateSettings(updated);
  }

  Future<void> updateCharacterSize(double size) async {
    final updated = state.copyWith(characterSize: size);
    await updateSettings(updated);
  }

  Future<void> updateLineSpacing(int spacing) async {
    final updated = state.copyWith(lineSpacing: spacing);
    await updateSettings(updated);
  }

  Future<void> updateDefaultTemplateId(int? id) async {
    final updated = state.copyWith(defaultTemplateId: id);
    await updateSettings(updated);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(SettingsRepository());
});
