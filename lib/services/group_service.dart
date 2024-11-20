import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GroupService {
  static const String _groupsKey = 'event_groups';

  // 默认分组列表
  static const List<String> defaultGroups = [
    '默认分组',
    '工作',
    '学习',
    '生活',
    '运动',
    '娱乐',
  ];

  // 获取所有分组
  Future<List<String>> getGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final String? groupsJson = prefs.getString(_groupsKey);

    if (groupsJson == null) {
      // 如果没有保存的分组，返回默认分组
      await saveGroups(defaultGroups);
      return defaultGroups;
    }

    return List<String>.from(jsonDecode(groupsJson));
  }

  // 保存分组列表
  Future<void> saveGroups(List<String> groups) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_groupsKey, jsonEncode(groups));
  }

  // 添加新分组
  Future<void> addGroup(String group) async {
    final groups = await getGroups();
    if (!groups.contains(group)) {
      groups.add(group);
      await saveGroups(groups);
    }
  }

  // 删除分组
  Future<void> deleteGroup(String group) async {
    if (group == '默认分组') return; // 不允许删除默认分组

    final groups = await getGroups();
    groups.remove(group);
    await saveGroups(groups);
  }

  // 重命名分组
  Future<void> renameGroup(String oldName, String newName) async {
    if (oldName == '默认分组') return; // 不允许重命名默认分组

    final groups = await getGroups();
    final index = groups.indexOf(oldName);
    if (index != -1) {
      groups[index] = newName;
      await saveGroups(groups);
    }
  }
}
