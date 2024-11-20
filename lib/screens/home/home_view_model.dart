import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../services/event_service.dart';

/// 主页视图模型
/// 负责管理主页的数据状态和业务逻辑
class HomeViewModel extends ChangeNotifier {
  // 事件服务实例，用于数据操作
  final _eventService = EventService();

  // 最近事件列表
  List<Event> _recentEvents = [];

  // 加载状态标记
  bool _isLoading = false;

  // 当前选中的分组
  String _selectedGroup = 'all';

  // Getters
  List<Event> get recentEvents => _recentEvents; // 获取最近事件列表
  bool get isLoading => _isLoading; // 获取加载状态
  String get selectedGroup => _selectedGroup; // 获取当前选中分组

  /// 加载事件列表
  /// 根据当前选中的分组获取对应的事件
  Future<void> loadEvents() async {
    _isLoading = true; // 设置加载状态
    notifyListeners(); // 通知监听器更新UI

    try {
      final events = await _eventService.getEvents(); // 获取所有事件
      // 根据分组筛选事件
      _recentEvents = _selectedGroup == 'all'
          ? events // 如果是全部分组，返回所有事件
          : events
              .where((e) => e.category == _selectedGroup)
              .toList(); // 否则返回对应分组的事件
    } catch (e) {
      debugPrint('加载事件失败: $e'); // 打印错误信息
    } finally {
      _isLoading = false; // 重置加载状态
      notifyListeners(); // 通知监听器更新UI
    }
  }

  /// 切换分组
  /// [group] 目标分组名称
  void changeGroup(String group) {
    if (_selectedGroup != group) {
      // 如果选中了不同的分组
      _selectedGroup = group; // 更新选中分组
      loadEvents(); // 重新加载事件列表
    }
  }

  /// 获取统计数据
  /// 返回今日事件的统计信息
  Map<String, dynamic> getStatistics() {
    final now = DateTime.now();
    // 获取今日的事件列表
    final todayEvents = _recentEvents.where((event) {
      final lastOccurrence = event.lastOccurrence;
      if (lastOccurrence == null) return false;
      return lastOccurrence.year == now.year &&
          lastOccurrence.month == now.month &&
          lastOccurrence.day == now.day;
    }).toList();

    return {
      'eventCount': todayEvents.length, // 今日事件数量
      'totalDuration': _calculateTotalDuration(todayEvents), // 总时长
      'completionRate': _calculateCompletionRate(todayEvents), // 完成率
    };
  }

  /// 计算总时长
  /// [events] 事件列表
  String _calculateTotalDuration(List<Event> events) {
    // TODO: 实现时长计算逻辑
    return '0小时';
  }

  /// 计算完成率
  /// [events] 事件列表
  String _calculateCompletionRate(List<Event> events) {
    if (events.isEmpty) return '0%';
    // TODO: 实现完成率计算逻辑
    return '0%';
  }
}
