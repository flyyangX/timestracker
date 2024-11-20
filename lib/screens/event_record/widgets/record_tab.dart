import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../models/event.dart';
import '../../../themes/app_theme.dart';
import 'record_timeline.dart';

class RecordTab extends StatefulWidget {
  final Event event;

  const RecordTab({
    super.key,
    required this.event,
  });

  @override
  State<RecordTab> createState() => _RecordTabState();
}

class _RecordTabState extends State<RecordTab> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  bool _isAscending = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.grey.withOpacity(0.2),
            ),
          ),
          child: TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.now(),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppTheme.secondaryColor,
                shape: BoxShape.circle,
              ),
              weekendTextStyle: TextStyle(color: Colors.red),
              outsideDaysVisible: false,
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isAscending = !_isAscending;
                  });
                },
                icon: Icon(
                  _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 18,
                  color: AppTheme.primaryColor,
                ),
                label: Text(
                  _isAscending ? '升序' : '降序',
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: AppTheme.gradientStart,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: RecordTimeline(
            event: widget.event,
            selectedDate: _selectedDay,
            isAscending: _isAscending,
          ),
        ),
      ],
    );
  }
}
