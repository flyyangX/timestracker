import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_record_entry.dart';

class RecordService {
  static const String _recordsKey = 'event_records';

  Future<void> saveRecord(EventRecordEntry record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final records = await getRecords();

      records.add(record);
      final jsonList = records.map((r) => r.toJson()).toList();
      await prefs.setString(_recordsKey, jsonEncode(jsonList));
    } catch (e) {
      print('Save Record Error: $e'); // 添加错误日志
      rethrow; // 重新抛出错误以便上层处理
    }
  }

  Future<List<EventRecordEntry>> getRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? recordsJson = prefs.getString(_recordsKey);

      if (recordsJson == null) return [];

      final List<dynamic> recordsList = jsonDecode(recordsJson);
      return recordsList
          .map((json) => EventRecordEntry.fromJson(json))
          .toList();
    } catch (e) {
      print('Get Records Error: $e'); // 添加错误日志
      return []; // 发生错误时返回空列表
    }
  }

  Future<List<EventRecordEntry>> getRecordsByDate(
      String eventId, DateTime date) async {
    final records = await getRecords();
    return records.where((r) {
      return r.eventId == eventId &&
          r.timestamp.year == date.year &&
          r.timestamp.month == date.month &&
          r.timestamp.day == date.day;
    }).toList();
  }

  // 获取指定事件的记录
  Future<List<EventRecordEntry>> getEventRecords(String eventId) async {
    final records = await getRecords();
    return records.where((r) => r.eventId == eventId).toList();
  }

  // 获取统计数据
  Future<Map<String, dynamic>> getStatistics(String eventId) async {
    final records = await getEventRecords(eventId);

    return {
      'totalCount': records.length,
      'monthlyCount': records.where((r) {
        final now = DateTime.now();
        return r.timestamp.year == now.year && r.timestamp.month == now.month;
      }).length,
      'weeklyAverage': records.length / 4, // 简单计算，实际应该更精确
      // TODO: 添加更多统计数据
    };
  }

  // 删除记录
  Future<void> deleteRecord(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await getRecords();

    records.removeWhere((r) => r.id == id);
    await prefs.setString(
        _recordsKey, jsonEncode(records.map((e) => e.toJson()).toList()));
  }
}
