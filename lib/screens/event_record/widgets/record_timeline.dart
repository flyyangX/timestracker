import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../../../models/event.dart';
import '../../../models/event_record_entry.dart';
import '../../../services/record_service.dart';
import '../../../themes/app_theme.dart';

class RecordTimeline extends StatelessWidget {
  final Event event;
  final DateTime selectedDate;
  final bool isAscending;

  const RecordTimeline({
    super.key,
    required this.event,
    required this.selectedDate,
    required this.isAscending,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EventRecordEntry>>(
      future: RecordService().getRecordsByDate(event.id, selectedDate),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              '暂无记录',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 16,
              ),
            ),
          );
        }

        // 按时间排序记录
        final records = snapshot.data!
          ..sort((a, b) => isAscending
              ? a.timestamp.compareTo(b.timestamp)
              : b.timestamp.compareTo(a.timestamp));

        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.defaultPadding),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            return TimelineTile(
              alignment: TimelineAlign.manual,
              lineXY: 0.2,
              isFirst: index == 0,
              isLast: index == records.length - 1,
              indicatorStyle: const IndicatorStyle(
                width: 20,
                color: AppTheme.primaryColor,
              ),
              beforeLineStyle: const LineStyle(
                color: AppTheme.primaryColor,
              ),
              endChild: _buildRecordContent(record),
              startChild: _buildTimeLabel(record),
            );
          },
        );
      },
    );
  }

  Widget _buildTimeLabel(EventRecordEntry record) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        '${record.timestamp.hour.toString().padLeft(2, '0')}:${record.timestamp.minute.toString().padLeft(2, '0')}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTheme.textSecondaryColor,
        ),
      ),
    );
  }

  Widget _buildRecordContent(EventRecordEntry record) {
    return Card(
      elevation: AppTheme.cardElevation,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 显示可见的字段
            ...record.attributeValues.entries
                .where((entry) => entry.value.visible)
                .map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        '${entry.key}: ${entry.value.value}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                    )),
            // 显示其他默认字段
            if (record.location.isNotEmpty) ...[
              const Divider(),
              Text('位置: ${record.location}'),
            ],
            if (record.note != null) ...[
              const Divider(),
              Text('备注: ${record.note}'),
            ],
          ],
        ),
      ),
    );
  }
}
