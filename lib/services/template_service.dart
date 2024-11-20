import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_template.dart';

class TemplateService {
  static const String _key = 'event_templates';

  // 获取所有模版
  Future<List<EventTemplate>> getTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final String? templatesJson = prefs.getString(_key);
    if (templatesJson == null) return [];

    final List<dynamic> decoded = jsonDecode(templatesJson);
    return decoded.map((json) => EventTemplate.fromJson(json)).toList();
  }

  // 保存模版
  Future<void> saveTemplate(EventTemplate template) async {
    final prefs = await SharedPreferences.getInstance();
    final templates = await getTemplates();
    templates.add(template);

    final encoded = jsonEncode(templates.map((t) => t.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  // 删除模版
  Future<void> deleteTemplate(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final templates = await getTemplates();
    templates.removeWhere((t) => t.id == id);

    final encoded = jsonEncode(templates.map((t) => t.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  // 按分组获取模版
  Future<Map<String, List<EventTemplate>>> getTemplatesByGroup() async {
    final templates = await getTemplates();
    return groupBy(templates, (template) => template.group);
  }
}

// 辅助函数：按键对列表进行分组
Map<K, List<T>> groupBy<T, K>(Iterable<T> items, K Function(T) key) {
  final map = <K, List<T>>{};
  for (final item in items) {
    final k = key(item);
    (map[k] ??= []).add(item);
  }
  return map;
}
