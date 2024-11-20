import 'package:flutter/material.dart';
import '../../../themes/app_theme.dart';
import '../../../services/notification_service.dart';

class ReminderSettings extends StatefulWidget {
  final String eventName;
  final bool periodicReminder;
  final bool missedReminder;
  final TimeOfDay reminderTime;
  final String reminderFrequency;
  final Function(bool) onPeriodicReminderChanged;
  final Function(bool) onMissedReminderChanged;
  final Function(TimeOfDay) onReminderTimeChanged;
  final Function(String?) onReminderFrequencyChanged;

  const ReminderSettings({
    super.key,
    required this.eventName,
    required this.periodicReminder,
    required this.missedReminder,
    required this.reminderTime,
    required this.reminderFrequency,
    required this.onPeriodicReminderChanged,
    required this.onMissedReminderChanged,
    required this.onReminderTimeChanged,
    required this.onReminderFrequencyChanged,
  });

  @override
  State<ReminderSettings> createState() => _ReminderSettingsState();
}

class _ReminderSettingsState extends State<ReminderSettings> {
  // 选中的星期几（每天频律）
  final List<int> _selectedDays = [];
  // 每月提醒日期
  int _dayOfMonth = 1;
  // 每年提醒日期
  DateTime _yearlyDate = DateTime.now();
  // 添加通知服务实例
  final _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    // 初始化通知服务
    _notificationService.initialize();
  }

  // 更新提醒设置时调用通知服务
  void _updateReminder() {
    if (widget.periodicReminder) {
      _notificationService.schedulePeriodicReminder(
        eventName: widget.eventName,
        frequency: widget.reminderFrequency,
        daysOfWeek: _selectedDays,
        dayOfMonth: _dayOfMonth,
        yearlyDate: _yearlyDate,
        reminderTime: widget.reminderTime,
        isEnabled: true,
      );
    } else {
      _notificationService.schedulePeriodicReminder(
        eventName: widget.eventName,
        frequency: widget.reminderFrequency,
        daysOfWeek: _selectedDays,
        dayOfMonth: _dayOfMonth,
        yearlyDate: _yearlyDate,
        reminderTime: widget.reminderTime,
        isEnabled: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppTheme.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
      ),
      child: Column(
        children: [
          // 定期提醒开关
          SwitchListTile(
            title: const Text('定期提醒'),
            value: widget.periodicReminder,
            onChanged: (value) {
              widget.onPeriodicReminderChanged(value);
              _updateReminder(); // 更新提醒设置
            },
            activeColor: AppTheme.primaryColor,
          ),
          if (widget.periodicReminder) ...[
            const Divider(height: 1),
            // 提醒频律选择
            Padding(
              padding: const EdgeInsets.all(AppTheme.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '提醒频律',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.smallPadding),
                  DropdownButtonFormField<String>(
                    value: widget.reminderFrequency,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: '每天', child: Text('每天')),
                      DropdownMenuItem(value: '每周', child: Text('每周')),
                      DropdownMenuItem(value: '每月', child: Text('每月')),
                      DropdownMenuItem(value: '每年', child: Text('每年')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        widget.onReminderFrequencyChanged(value);
                      }
                    },
                  ),
                  const SizedBox(height: AppTheme.defaultPadding),
                  // 根据频律显示不同的额外选项
                  if (widget.reminderFrequency == '每天')
                    _buildDailyOptions()
                  else if (widget.reminderFrequency == '每月')
                    _buildMonthlyOptions()
                  else if (widget.reminderFrequency == '每年')
                    _buildYearlyOptions(),
                  const SizedBox(height: AppTheme.defaultPadding),
                  // 提醒时间选择
                  _buildTimeSelector(),
                ],
              ),
            ),
          ],
          const Divider(height: 1),
          // 未完成提醒开关
          SwitchListTile(
            title: const Text('未完成提醒'),
            value: widget.missedReminder,
            onChanged: widget.onMissedReminderChanged,
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  // 每天频律的选项
  Widget _buildDailyOptions() {
    final weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '选择提醒日期',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: AppTheme.smallPadding),
        Wrap(
          spacing: AppTheme.smallPadding,
          children: List.generate(7, (index) {
            final isSelected = _selectedDays.contains(index + 1);
            return FilterChip(
              label: Text(weekdays[index]),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedDays.add(index + 1);
                  } else {
                    _selectedDays.remove(index + 1);
                  }
                });
              },
              selectedColor: AppTheme.primaryColor.withOpacity(0.2),
              checkmarkColor: AppTheme.primaryColor,
            );
          }),
        ),
      ],
    );
  }

  // 每月频律的选项
  Widget _buildMonthlyOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '选择每月提醒日期',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: AppTheme.smallPadding),
        DropdownButtonFormField<int>(
          value: _dayOfMonth,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: List.generate(31, (index) {
            return DropdownMenuItem(
              value: index + 1,
              child: Text('${index + 1}号'),
            );
          }),
          onChanged: (value) {
            if (value != null) {
              setState(() => _dayOfMonth = value);
            }
          },
        ),
      ],
    );
  }

  // 每年频律的选项
  Widget _buildYearlyOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '选择每年提醒日期',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: AppTheme.smallPadding),
        InkWell(
          onTap: () => _selectYearlyDate(context),
          child: InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            child: Text(
              '${_yearlyDate.year}-${_yearlyDate.month}-${_yearlyDate.day}',
            ),
          ),
        ),
      ],
    );
  }

  // 提醒时间选择器
  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '提醒时间',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: AppTheme.smallPadding),
        InkWell(
          onTap: () => _selectTime(context),
          child: InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            child: Text(
              _formatTime(widget.reminderTime),
            ),
          ),
        ),
      ],
    );
  }

  // 选择每年提醒日期
  Future<void> _selectYearlyDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _yearlyDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _yearlyDate = picked);
      _updateReminder(); // 更新提醒设置
    }
  }

  // 选择提醒时间
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: widget.reminderTime,
    );
    if (picked != null) {
      widget.onReminderTimeChanged(picked);
      _updateReminder(); // 更新提醒设置
    }
  }

  // 格式化时间显示
  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
