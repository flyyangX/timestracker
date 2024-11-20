import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../themes/app_theme.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<void> _onNotificationTapped(NotificationResponse response) async {
    // 处理通知点击事件
    if (response.payload != null) {
      // TODO: 跳转到对应的事件详情页面
    }
  }

  // 设置定期提醒
  Future<void> schedulePeriodicReminder({
    required String eventName,
    required String frequency,
    required List<int> daysOfWeek,
    required int dayOfMonth,
    required DateTime yearlyDate,
    required TimeOfDay reminderTime,
    required bool isEnabled,
  }) async {
    if (!isEnabled) {
      // 如果关闭提醒，取消所有通知
      await _notifications.cancelAll();
      return;
    }

    // 构建通知内容
    final title = '提醒：$eventName';
    String body;

    switch (frequency) {
      case '每天':
        final days = daysOfWeek.map((day) {
          switch (day) {
            case 1:
              return '一';
            case 2:
              return '二';
            case 3:
              return '三';
            case 4:
              return '四';
            case 5:
              return '五';
            case 6:
              return '六';
            case 7:
              return '日';
            default:
              return '';
          }
        }).join('、');
        body = '今天是星期$days，忘了在${_formatTime(reminderTime)}完成任务！';
        await _scheduleDailyReminder(title, body, daysOfWeek, reminderTime);
        break;

      case '每周':
        body = '每周的提醒：请在${_formatTime(reminderTime)}完成任务！';
        await _scheduleWeeklyReminder(title, body, reminderTime);
        break;

      case '每月':
        body = '每月$dayOfMonth日的提醒：请在${_formatTime(reminderTime)}完成任务！';
        await _scheduleMonthlyReminder(title, body, dayOfMonth, reminderTime);
        break;

      case '每年':
        body =
            '提醒：${yearlyDate.year}-${yearlyDate.month}-${yearlyDate.day} ${_formatTime(reminderTime)}有任务！';
        await _scheduleYearlyReminder(title, body, yearlyDate, reminderTime);
        break;
    }
  }

  // 每天提醒
  Future<void> _scheduleDailyReminder(
    String title,
    String body,
    List<int> daysOfWeek,
    TimeOfDay reminderTime,
  ) async {
    for (final day in daysOfWeek) {
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        reminderTime.hour,
        reminderTime.minute,
      );

      // 如果今天的提醒时间已过，设置为下周的这一天
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 7));
      }

      // 调整到指定的星期几
      while (scheduledDate.weekday != day) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const androidDetails = AndroidNotificationDetails(
        'daily_reminders',
        '每日提醒',
        channelDescription: '用于每日定期提醒的通知',
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        day, // 使用星期几作为通知ID
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        details,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  // 每周提醒
  Future<void> _scheduleWeeklyReminder(
    String title,
    String body,
    TimeOfDay reminderTime,
  ) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      reminderTime.hour,
      reminderTime.minute,
    );

    // 如果今天的提醒时间已过，设置为下周
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    const androidDetails = AndroidNotificationDetails(
      'weekly_reminders',
      '每周提醒',
      channelDescription: '用于每周定期提醒的通知',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      100, // 使用固定ID，避免与每日提醒冲突
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  // 每月提醒
  Future<void> _scheduleMonthlyReminder(
    String title,
    String body,
    int dayOfMonth,
    TimeOfDay reminderTime,
  ) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      dayOfMonth,
      reminderTime.hour,
      reminderTime.minute,
    );

    // 如果这个月的提醒日期已过，设置为下个月
    if (scheduledDate.isBefore(now)) {
      scheduledDate = DateTime(
        now.year,
        now.month + 1,
        dayOfMonth,
        reminderTime.hour,
        reminderTime.minute,
      );
    }

    const androidDetails = AndroidNotificationDetails(
      'monthly_reminders',
      '每月提醒',
      channelDescription: '用于每月定期提醒的通知',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      200, // 使用固定ID，避免与其他提醒冲突
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  // 每年提醒
  Future<void> _scheduleYearlyReminder(
    String title,
    String body,
    DateTime yearlyDate,
    TimeOfDay reminderTime,
  ) async {
    var scheduledDate = DateTime(
      yearlyDate.year,
      yearlyDate.month,
      yearlyDate.day,
      reminderTime.hour,
      reminderTime.minute,
    );

    // 如果今年的提醒日期已过，设置为明年
    final now = DateTime.now();
    if (scheduledDate.isBefore(now)) {
      scheduledDate = DateTime(
        yearlyDate.year + 1,
        yearlyDate.month,
        yearlyDate.day,
        reminderTime.hour,
        reminderTime.minute,
      );
    }

    const androidDetails = AndroidNotificationDetails(
      'yearly_reminders',
      '每年提醒',
      channelDescription: '用于每年定期提醒的通知',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      300, // 使用固定ID，避免与其他提醒冲突
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  // 格式化时间显示
  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // 延迟提醒
  Future<void> snoozeReminder(int notificationId) async {
    // 实现延迟提醒的逻辑（默认延迟5分钟）
    const androidDetails = AndroidNotificationDetails(
      'snoozed_reminders',
      '延迟提醒',
      channelDescription: '用于延迟提醒的通知',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduledDate = DateTime.now().add(const Duration(minutes: 5));

    await _notifications.zonedSchedule(
      notificationId + 1000, // 使用新的ID避免冲突
      '延迟提醒',
      '5分钟后再提醒',
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
