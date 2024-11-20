import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';

class EventProvider extends ChangeNotifier {
  final _eventService = EventService();
  List<Event> _events = [];
  bool _isLoading = false;
  String _selectedGroup = 'all';

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String get selectedGroup => _selectedGroup;

  Future<void> loadEvents() async {
    _isLoading = true;
    notifyListeners();

    try {
      final events = await _eventService.getEvents();
      _events = _selectedGroup == 'all'
          ? events
          : events.where((e) => e.category == _selectedGroup).toList();
    } catch (e) {
      debugPrint('加载事件失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void changeGroup(String group) {
    if (_selectedGroup != group) {
      _selectedGroup = group;
      loadEvents();
    }
  }

  Future<void> addEvent(Event event) async {
    await _eventService.saveEvent(event);
    await loadEvents();
  }

  Future<void> updateEvent(Event event) async {
    await _eventService.updateEvent(event);
    await loadEvents();
  }
}
