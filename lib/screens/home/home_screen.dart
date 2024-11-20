import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';
import '../new_event_screen.dart';
import 'widgets/greeting_section.dart';
import 'widgets/statistics_card.dart';
import 'widgets/recent_events_list.dart';
import '../../models/event.dart';
import '../../services/event_service.dart';
import '../../services/group_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Event> _recentEvents = [];
  String _selectedGroup = 'all';

  @override
  void initState() {
    super.initState();
    _loadRecentEvents();
  }

  Future<void> _loadRecentEvents() async {
    final events = await EventService().getEvents();
    setState(() {
      _recentEvents = _selectedGroup == 'all'
          ? events
          : events.where((e) => e.category == _selectedGroup).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.gradientStart,
            AppTheme.gradientEnd,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'TimesTracker',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(AppTheme.cardBorderRadius),
            ),
          ),
          actions: [
            // 添加新建事件按钮
            Padding(
              padding: const EdgeInsets.only(right: AppTheme.defaultPadding),
              child: IconButton(
                icon: const Icon(Icons.add_circle_outline),
                iconSize: 28,
                color: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewEventScreen(),
                    ),
                  ).then((_) => _loadRecentEvents());
                },
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppTheme.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GreetingSection(),
              const SizedBox(height: AppTheme.defaultPadding),
              const StatisticsCard(),
              const SizedBox(height: AppTheme.defaultPadding),
              // 分组导航栏
              _buildGroupNavigation(),
              const SizedBox(height: AppTheme.defaultPadding),
              RecentEventsList(
                events: _recentEvents,
                onAddEvent: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewEventScreen(),
                    ),
                  ).then((_) => _loadRecentEvents());
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTheme.cardBorderRadius),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            backgroundColor: Colors.transparent,
            elevation: 0,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: '首页',
              ),
              NavigationDestination(
                icon: Icon(Icons.trending_up_outlined),
                selectedIcon: Icon(Icons.trending_up),
                label: '趋势',
              ),
              NavigationDestination(
                icon: Icon(Icons.timeline_outlined),
                selectedIcon: Icon(Icons.timeline),
                label: '时间线',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: '设置',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建分组导航栏
  Widget _buildGroupNavigation() {
    return FutureBuilder<List<String>>(
      future: GroupService().getGroups(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final groups = ['all', ...snapshot.data!];
        return Row(
          children: [
            // 分组列表
            Expanded(
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    final isSelected = group == _selectedGroup;
                    return Padding(
                      padding:
                          const EdgeInsets.only(right: AppTheme.smallPadding),
                      child: Material(
                        color:
                            isSelected ? AppTheme.primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        elevation: isSelected ? 4 : 2,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedGroup = group;
                              _loadRecentEvents();
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.defaultPadding,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              group == 'all' ? '全部事件' : group,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // 添加分组按钮
            Padding(
              padding: const EdgeInsets.only(left: AppTheme.smallPadding),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                elevation: 2,
                child: InkWell(
                  onTap: _showAddGroupDialog,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.add,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 显示添加分组对话框
  void _showAddGroupDialog() {
    final newGroupController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新增分组'),
        content: TextField(
          controller: newGroupController,
          decoration: const InputDecoration(
            labelText: '分组名称',
            hintText: '请输入分组名称',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newGroup = newGroupController.text.trim();
              if (newGroup.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请输入分组名称')),
                );
                return;
              }

              // 添加新分组
              await GroupService().addGroup(newGroup);

              if (mounted) {
                Navigator.pop(context);
                // 刷新页面
                setState(() {
                  _selectedGroup = newGroup;
                  _loadRecentEvents();
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
