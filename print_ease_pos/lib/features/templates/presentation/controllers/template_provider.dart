import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/template_datasource.dart';
import '../../data/models/receipt_template.dart';
import '../../data/repositories/template_repository.dart';
import '../../../receipts/presentation/controllers/receipt_provider.dart';

class TemplateState {
  final List<ReceiptTemplate> templates;
  final ReceiptTemplate? selectedTemplate;
  final ReceiptTemplate? editingTemplate;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const TemplateState({
    this.templates = const [],
    this.selectedTemplate,
    this.editingTemplate,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  TemplateState copyWith({
    List<ReceiptTemplate>? templates,
    ReceiptTemplate? selectedTemplate,
    ReceiptTemplate? editingTemplate,
    bool? isLoading,
    bool? isSaving,
    String? error,
  }) {
    return TemplateState(
      templates: templates ?? this.templates,
      selectedTemplate: selectedTemplate ?? this.selectedTemplate,
      editingTemplate: editingTemplate,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }
}

class TemplateNotifier extends StateNotifier<TemplateState> {
  final TemplateRepository _repository;

  TemplateNotifier(this._repository) : super(const TemplateState());

  Future<void> loadTemplates() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final templates = await _repository.getTemplates();
      state = state.copyWith(templates: templates, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void startNewTemplate() {
    state = state.copyWith(
      editingTemplate: ReceiptTemplate(
        name: 'New Template',
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> startEditTemplate(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final template = await _repository.getTemplateById(id);
      state = state.copyWith(editingTemplate: template, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> saveTemplate() async {
    final template = state.editingTemplate;
    if (template == null) return;
    state = state.copyWith(isSaving: true, error: null);
    try {
      await _repository.saveTemplate(template);
      state = state.copyWith(isSaving: false, editingTemplate: null);
      await loadTemplates();
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  Future<void> deleteTemplate(int id) async {
    try {
      await _repository.deleteTemplate(id);
      if (state.selectedTemplate?.id == id) {
        state = state.copyWith(selectedTemplate: null);
      }
      await loadTemplates();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void selectTemplate(ReceiptTemplate template) {
    state = state.copyWith(selectedTemplate: template);
  }

  void cancelEditing() {
    state = state.copyWith(editingTemplate: null);
  }

  void updateName(String value) {
    _updateEditing((t) => t.copyWith(name: value));
  }

  void updateStoreName(String value) {
    _updateEditing((t) => t.copyWith(storeName: value));
  }

  void updateStorePhone(String value) {
    _updateEditing((t) => t.copyWith(storePhone: value));
  }

  void updateHeader(String value) {
    _updateEditing((t) => t.copyWith(header: value));
  }

  void updateFooter(String value) {
    _updateEditing((t) => t.copyWith(footer: value));
  }

  void updateShowLogo(bool value) {
    _updateEditing((t) => t.copyWith(showLogo: value));
  }

  void updateShowQrCode(bool value) {
    _updateEditing((t) => t.copyWith(showQrCode: value));
  }

  void updateShowDivider(bool value) {
    _updateEditing((t) => t.copyWith(showDivider: value));
  }

  void updateShowItemizedList(bool value) {
    _updateEditing((t) => t.copyWith(showItemizedList: value));
  }

  void updatePaperWidth(double value) {
    _updateEditing((t) => t.copyWith(paperWidth: value));
  }

  void updateFontSize(double value) {
    _updateEditing((t) => t.copyWith(fontSize: value));
  }

  void updateAlignment(ReceiptAlignment value) {
    _updateEditing((t) => t.copyWith(alignment: value));
  }

  void updateSpacing(double value) {
    _updateEditing((t) => t.copyWith(spacing: value));
  }

  void updateLogoPath(String? path) {
    _updateEditing((t) => t.copyWith(logoPath: path, clearLogo: path == null));
  }

  void _updateEditing(ReceiptTemplate Function(ReceiptTemplate) update) {
    final current = state.editingTemplate;
    if (current == null) return;
    state = state.copyWith(editingTemplate: update(current));
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final templateDatasourceProvider = Provider<TemplateDatasource>((ref) {
  return TemplateDatasource(ref.watch(databaseServiceProvider));
});

final templateRepositoryProvider = Provider<TemplateRepository>((ref) {
  return TemplateRepository(ref.watch(templateDatasourceProvider));
});

final templateProvider =
    StateNotifierProvider<TemplateNotifier, TemplateState>((ref) {
  return TemplateNotifier(ref.watch(templateRepositoryProvider));
});
