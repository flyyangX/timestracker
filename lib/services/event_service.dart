import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';
import '../models/event_record.dart';

class EventService {
  static const String _eventsKey = 'events';
  static const String _recordsKey = 'event_records';

  // 获取所有事件
  Future<List<Event>> getEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? eventsJson = prefs.getString(_eventsKey);

    if (eventsJson == null) return [];

    final List<dynamic> eventsList = jsonDecode(eventsJson);
    return eventsList.map((e) => Event.fromJson(e)).toList();
  }

  // 保存事件
  Future<void> saveEvent(Event event) async {
    final prefs = await SharedPreferences.getInstance();
    final events = await getEvents();

    events.add(event);
    await prefs.setString(
        _eventsKey, jsonEncode(events.map((e) => e.toJson()).toList()));
  }

  // 更新事件
  Future<void> updateEvent(Event event) async {
    final prefs = await SharedPreferences.getInstance();
    final events = await getEvents();

    final index = events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      events[index] = event;
      await prefs.setString(
          _eventsKey, jsonEncode(events.map((e) => e.toJson()).toList()));
    }
  }

  // 删除事件
  Future<void> deleteEvent(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final events = await getEvents();

    events.removeWhere((e) => e.id == id);
    await prefs.setString(
        _eventsKey, jsonEncode(events.map((e) => e.toJson()).toList()));
  }

  // 按分组获取事件
  Future<List<Event>> getEventsByGroup(String group) async {
    final events = await getEvents();
    return events.where((e) => e.category == group).toList();
  }

  // 添加记录方法
  Future<void> addRecord(String eventId, EventRecord record) async {
    final prefs = await SharedPreferences.getInstance();

    // 获取现有记录
    final String? recordsJson = prefs.getString(_recordsKey);
    final List<EventRecord> records = [];

    if (recordsJson != null) {
      final List<dynamic> recordsList = jsonDecode(recordsJson);
      records.addAll(recordsList.map((r) => EventRecord.fromJson(r)));
    }

    // 添加新记录
    records.add(record);

    // 保存记录
    await prefs.setString(
      _recordsKey,
      jsonEncode(records.map((r) => r.toJson()).toList()),
    );

    // 更新事件的最后发生时间
    final events = await getEvents();
    final eventIndex = events.indexWhere((e) => e.id == eventId);
    if (eventIndex != -1) {
      events[eventIndex].lastOccurrence = record.timestamp;
      await prefs.setString(
        _eventsKey,
        jsonEncode(events.map((e) => e.toJson()).toList()),
      );
    }
  }

  // 获取事件的所有记录
  Future<List<EventRecord>> getEventRecords(String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? recordsJson = prefs.getString(_recordsKey);

    if (recordsJson == null) return [];

    final List<dynamic> recordsList = jsonDecode(recordsJson);
    final records = recordsList.map((r) => EventRecord.fromJson(r)).toList();

    return records.where((r) => r.eventId == eventId).toList();
  }

  // 删除记录
  Future<void> deleteRecord(String recordId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? recordsJson = prefs.getString(_recordsKey);

    if (recordsJson == null) return;

    final List<dynamic> recordsList = jsonDecode(recordsJson);
    final records = recordsList.map((r) => EventRecord.fromJson(r)).toList();

    records.removeWhere((r) => r.id == recordId);

    await prefs.setString(
      _recordsKey,
      jsonEncode(records.map((r) => r.toJson()).toList()),
    );
  }
}
