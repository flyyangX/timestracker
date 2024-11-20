import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../themes/app_theme.dart';
import 'widgets/record_tab.dart';
import 'widgets/statistics_tab.dart';
import 'add_record_screen.dart';
import '../../services/record_service.dart';

class EventRecordScreen extends StatefulWidget {
  final Event event;

  const EventRecordScreen({
    super.key,
    required this.event,
  });

  @override
  State<EventRecordScreen> createState() => _EventRecordScreenState();
}

class _EventRecordScreenState extends State<EventRecordScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _recordService = RecordService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                widget.event.icon ?? Icons.event,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  widget.event.category,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          indicator: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.white,
                width: 3,
              ),
            ),
          ),
          indicatorSize: TabBarIndicatorSize.label,
          indicatorWeight: 3,
          tabs: [
            _buildAnimatedTab('记录', 0),
            _buildAnimatedTab('统计', 1),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: [
          RecordTab(event: widget.event),
          StatisticsTab(event: widget.event),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: ModalRoute.of(context)!.animation!,
            curve: Curves.easeOut,
          ),
        ),
        child: FloatingActionButton(
          onPressed: () async {
            // 打开添加记录页面
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddRecordScreen(event: widget.event),
              ),
            );

            // 如果返回结果不为空，说明保存了新记录，刷新页面
            if (result == true && mounted) {
              setState(() {});
            }
          },
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAnimatedTab(String text, int index) {
    return Tab(
      child: AnimatedBuilder(
        animation: _tabController.animation!,
        builder: (context, child) {
          final selected = _tabController.index == index;
          final value = _tabController.animation!.value;
          final progress = index == 0 ? 1 - value : value;

          return Transform.scale(
            scale: 1.0 + (selected ? 0.1 * progress : 0.0),
            child: Opacity(
              opacity: selected ? 1.0 : 0.6 + (0.4 * (1 - progress)),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
