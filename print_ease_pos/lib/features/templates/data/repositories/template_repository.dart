import '../datasources/template_datasource.dart';
import '../models/receipt_template.dart';

class TemplateRepository {
  final TemplateDatasource _datasource;

  TemplateRepository(this._datasource);

  Future<List<ReceiptTemplate>> getTemplates() {
    return _datasource.getTemplates();
  }

  Future<ReceiptTemplate?> getTemplateById(int id) {
    return _datasource.getTemplateById(id);
  }

  Future<int> saveTemplate(ReceiptTemplate template) async {
    if (template.id != null) {
      await _datasource.updateTemplate(template);
      return template.id!;
    }
    return _datasource.insertTemplate(template);
  }

  Future<void> deleteTemplate(int id) {
    return _datasource.deleteTemplate(id);
  }
}
