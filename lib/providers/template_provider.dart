import 'package:flutter/material.dart';
import '../services/template_service.dart';
import '../models/event_template.dart';

class TemplateProvider extends ChangeNotifier {
  final _templateService = TemplateService();
  List<EventTemplate> _templates = [];
  bool _isLoading = false;
  String _selectedGroup = 'all';

  List<EventTemplate> get templates => _templates;
  bool get isLoading => _isLoading;
  String get selectedGroup => _selectedGroup;

  Future<void> loadTemplates() async {
    _isLoading = true;
    notifyListeners();

    try {
      final templates = await _templateService.getTemplates();
      _templates = _selectedGroup == 'all'
          ? templates
          : templates.where((t) => t.group == _selectedGroup).toList();
    } catch (e) {
      debugPrint('加载模板失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void changeGroup(String group) {
    if (_selectedGroup != group) {
      _selectedGroup = group;
      loadTemplates();
    }
  }

  Future<void> addTemplate(EventTemplate template) async {
    await _templateService.saveTemplate(template);
    await loadTemplates();
  }

  Future<void> deleteTemplate(String id) async {
    await _templateService.deleteTemplate(id);
    await loadTemplates();
  }
}
