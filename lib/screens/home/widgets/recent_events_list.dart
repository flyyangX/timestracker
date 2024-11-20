import 'package:flutter/material.dart';
import '../../../themes/app_theme.dart';
import '../../../models/event.dart';
import '../../../services/event_service.dart';
import '../../../services/group_service.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../event_record/event_record_screen.dart';
import '../../event_record/add_record_screen.dart';

class RecentEventsList extends StatefulWidget {
  final List<Event> events;
  final VoidCallback onAddEvent;

  const RecentEventsList({
    super.key,
    required this.events,
    required this.onAddEvent,
  });

  @override
  State<RecentEventsList> createState() => _RecentEventsListState();
}

class _RecentEventsListState extends State<RecentEventsList> {
  final _eventService = EventService();
  final _groupService = GroupService();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.history,
                color: AppTheme.primaryColor,
              ),
              SizedBox(width: AppTheme.smallPadding),
              Text(
                '最近事件',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.defaultPadding),
          Expanded(
            child: widget.events.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: widget.events.length,
                    itemBuilder: _buildEventCard,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, int index) {
    final event = widget.events[index];

    return Slidable(
      key: Key(event.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.4,
        children: [
          CustomSlidableAction(
            onPressed: (context) => _showGroupPicker(event),
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.folder_outlined, size: 24),
                const SizedBox(height: 4),
                Text(
                  '分组',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ],
            ),
          ),
          CustomSlidableAction(
            onPressed: (context) => _deleteEvent(event),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.delete_outline, size: 24),
                const SizedBox(height: 4),
                Text(
                  '删除',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: AppTheme.smallPadding),
        elevation: AppTheme.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventRecordScreen(event: event),
              ),
            );
          },
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(AppTheme.smallPadding),
              decoration: const BoxDecoration(
                color: AppTheme.gradientStart,
                shape: BoxShape.circle,
              ),
              child: event.icon != null
                  ? Icon(
                      event.icon,
                      color: AppTheme.primaryColor,
                    )
                  : event.emoji != null
                      ? Text(
                          event.emoji!,
                          style: const TextStyle(fontSize: 24),
                        )
                      : const Icon(
                          Icons.event,
                          color: AppTheme.primaryColor,
                        ),
            ),
            title: Text(
              event.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            subtitle: Text(
              '上次发生：${event.lastOccurrence != null ? _formatDate(event.lastOccurrence!) : "-"}',
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            trailing: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddRecordScreen(event: event),
                  ),
                ).then((_) => widget.onAddEvent());
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('记录'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.defaultPadding,
                  vertical: AppTheme.smallPadding,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showGroupPicker(Event event) async {
    final groups = await _groupService.getGroups();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.defaultPadding),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFEEEEEE),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '选择分组',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: AppTheme.textSecondaryColor,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppTheme.defaultPadding),
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  final isSelected = event.category == group;
                  return Card(
                    elevation: AppTheme.cardElevation,
                    margin:
                        const EdgeInsets.only(bottom: AppTheme.smallPadding),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.cardBorderRadius),
                    ),
                    child: InkWell(
                      onTap: () async {
                        final updatedEvent = Event(
                          id: event.id,
                          name: event.name,
                          icon: event.icon,
                          emoji: event.emoji,
                          imagePath: event.imagePath,
                          category: group,
                          quickRecord: event.quickRecord,
                          attributes: event.attributes,
                          lastOccurrence: event.lastOccurrence,
                        );
                        await _eventService.updateEvent(updatedEvent);
                        if (mounted) {
                          Navigator.pop(context);
                          setState(() {});
                        }
                      },
                      borderRadius:
                          BorderRadius.circular(AppTheme.cardBorderRadius),
                      child: Container(
                        padding: const EdgeInsets.all(AppTheme.defaultPadding),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryColor.withOpacity(0.1)
                              : null,
                          borderRadius:
                              BorderRadius.circular(AppTheme.cardBorderRadius),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.folder,
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : AppTheme.textSecondaryColor,
                            ),
                            const SizedBox(width: AppTheme.defaultPadding),
                            Text(
                              group,
                              style: TextStyle(
                                fontSize: 16,
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : AppTheme.textPrimaryColor,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              const Icon(
                                Icons.check,
                                color: AppTheme.primaryColor,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteEvent(Event event) async {
    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除事件'),
        content: Text('确定要删除"${event.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    // 如果用户确认删除
    if (confirmed == true && mounted) {
      try {
        // 删除事件
        await _eventService.deleteEvent(event.id);

        // 从事件列表中移除该事件并刷新UI
        setState(() {
          widget.events.removeWhere((e) => e.id == event.id);
        });

        // 显示撤销提示
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已删除事件"${event.name}"'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(AppTheme.defaultPadding),
              action: SnackBarAction(
                label: '撤销',
                onPressed: () async {
                  // 恢复删除的事件
                  await _eventService.saveEvent(event);
                  // 重新添加到列表并刷新UI
                  setState(() {
                    widget.events.add(event);
                  });
                },
              ),
            ),
          );
        }
      } catch (e) {
        // 显示错误提示
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('删除失败：$e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(AppTheme.defaultPadding),
            ),
          );
        }
      }
    }
  }

  Widget _buildEmptyState() {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.smallPadding),
      elevation: AppTheme.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppTheme.smallPadding),
          decoration: const BoxDecoration(
            color: AppTheme.gradientStart,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.event,
            color: AppTheme.primaryColor,
          ),
        ),
        title: const Text(
          '暂无事件',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        subtitle: const Text(
          '点击右下角的按钮添加新件',
          style: TextStyle(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.add_circle_outline,
            color: AppTheme.primaryColor,
          ),
          onPressed: widget.onAddEvent,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
