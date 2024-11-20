import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import 'custom_event/custom_event_screen.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../services/template_service.dart';
import '../services/group_service.dart';
import 'event_record/event_record_screen.dart';
import 'custom_event/models/attribute_type.dart';
import 'custom_event/models/custom_attribute.dart';

class NewEventScreen extends StatefulWidget {
  const NewEventScreen({super.key});

  @override
  State<NewEventScreen> createState() => _NewEventScreenState();
}

class _NewEventScreenState extends State<NewEventScreen> {
  String _selectedCategory = 'all';
  final _groupService = GroupService();

  // 修改事件模板数据，添加预设属性
  final List<EventTemplate> _templates = [
    EventTemplate(
      id: '1',
      name: '喝奶茶',
      group: '生活',
      icon: Icons.local_cafe,
      quickRecord: false,
      periodicReminder: false,
      missedReminder: false,
      attributes: [
        const CustomAttribute(
          name: '品牌',
          type: AttributeType.singleChoice,
          options: ['喜茶', '奈雪的茶', '蜜雪冰城', '其他'],
          defaultValue: {
            'defaultValue': '喜茶',
            'isRequired': true,
          },
        ),
        const CustomAttribute(
          name: '杯数',
          type: AttributeType.number,
          defaultValue: {
            'defaultValue': 1,
            'unit': '杯',
            'isRequired': true,
          },
        ),
        const CustomAttribute(
          name: '糖度',
          type: AttributeType.singleChoice,
          options: ['无糖', '微糖', '半糖', '全糖'],
          defaultValue: {
            'defaultValue': '微糖',
            'isRequired': true,
          },
        ),
        const CustomAttribute(
          name: '价格',
          type: AttributeType.number,
          defaultValue: {
            'defaultValue': null,
            'unit': '元',
            'isRequired': false,
          },
        ),
        const CustomAttribute(
          name: '评价',
          type: AttributeType.text,
          defaultValue: {
            'defaultValue': '',
            'isRequired': false,
          },
        ),
      ],
      description: '记录每次喝奶茶的时间和心情',
    ),
    EventTemplate(
      id: '2',
      name: '遛狗',
      group: '宠物',
      icon: Icons.pets,
      quickRecord: false,
      periodicReminder: false,
      missedReminder: false,
      attributes: [
        const CustomAttribute(
          name: '时长',
          type: AttributeType.number,
          defaultValue: {
            'defaultValue': 30,
            'unit': '分钟',
            'isRequired': true,
          },
        ),
        const CustomAttribute(
          name: '路线',
          type: AttributeType.singleChoice,
          options: ['小区内', '公园', '河边', '其他'],
          defaultValue: {
            'defaultValue': '小区内',
            'isRequired': true,
          },
        ),
        const CustomAttribute(
          name: '天气',
          type: AttributeType.singleChoice,
          options: ['晴天', '阴天', '小雨', '大雨'],
          defaultValue: {
            'defaultValue': '晴天',
            'isRequired': false,
          },
        ),
        const CustomAttribute(
          name: '备注',
          type: AttributeType.text,
          defaultValue: {
            'defaultValue': '',
            'isRequired': false,
          },
        ),
      ],
      description: '记录遛狗的时间和路线',
    ),
    EventTemplate(
      id: '3',
      name: '跑步',
      group: '运动',
      icon: Icons.directions_run,
      quickRecord: false,
      periodicReminder: false,
      missedReminder: false,
      attributes: [],
      description: '记录跑步的时间和路线',
    ),
    EventTemplate(
      id: '4',
      name: '阅读',
      group: '学习',
      icon: Icons.book,
      quickRecord: false,
      periodicReminder: false,
      missedReminder: false,
      attributes: [],
      description: '记录阅读的时间和心情',
    ),
  ];

  // 获取过滤后的模板列表
  List<EventTemplate> get _filteredTemplates {
    if (_selectedCategory == 'all') {
      // 修改为小写的 'all'
      return _templates;
    }
    return _templates.where((t) => t.group == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.gradientStart,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildCategoryTabs(),
              _buildTemplateGrid(),
              _buildCustomEventButton(),
            ],
          ),
        ),
      ),
    );
  }

  // 构建头部
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                '新建事件',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: AppTheme.defaultPadding),
            child: Text(
              '从模板开始记录你的时间',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 修改分组标签构建方法
  Widget _buildCategoryTabs() {
    return FutureBuilder<List<String>>(
      future: _groupService.getGroups(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final groups = ['all', ...snapshot.data!];
        return Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // 分组列表
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    final isSelected = group == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(group == 'all' ? '全部' : group),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategory = group;
                            });
                          }
                        },
                        selectedColor: AppTheme.primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppTheme.textPrimaryColor,
                        ),
                      ),
                    );
                  },
                ),
              ),
              // 添加分组按钮
              Padding(
                padding: const EdgeInsets.only(left: 8),
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
          ),
        );
      },
    );
  }

  // 添加显示新增分组对话框的方法
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
            child: const Text('取消'),
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

              // 加新分组
              await _groupService.addGroup(newGroup);

              if (mounted) {
                Navigator.pop(context);
                // 刷新页面
                setState(() {
                  _selectedCategory = newGroup;
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

  // 构建模板网格
  Widget _buildTemplateGrid() {
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.all(AppTheme.defaultPadding),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: AppTheme.defaultPadding,
          mainAxisSpacing: AppTheme.defaultPadding,
        ),
        itemCount: _filteredTemplates.length,
        itemBuilder: (context, index) {
          final template = _filteredTemplates[index];
          return _buildTemplateCard(template);
        },
      ),
    );
  }

  // 构建模板卡片
  Widget _buildTemplateCard(EventTemplate template) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF3E5F5), // 浅紫色背景渐变起点
              Colors.white, // 白色背景渐变终点
            ],
          ),
        ),
        child: Stack(
          children: [
            // 主体内容
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 图标和标题行
                  Row(
                    children: [
                      // 图标容器
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7E57C2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          template.icon ?? Icons.event,
                          size: 24,
                          color: const Color(0xFF7E57C2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 标题和分组
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              template.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF512DA8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7E57C2).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                template.group,
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      const Color(0xFF7E57C2).withOpacity(0.8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 属性预览
                  if (template.attributes != null &&
                      template.attributes!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '预设属性',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: template.attributes!.take(3).map((attr) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFE0E0E0),
                                ),
                              ),
                              child: Text(
                                attr.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF757575),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  const Spacer(),
                  // 底部按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 配置按钮
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CustomEventScreen(
                                initialEvent: Event(
                                  id: DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                                  name: template.name,
                                  icon: template.icon,
                                  category: template.group,
                                  quickRecord: template.quickRecord,
                                  attributes: template.attributes,
                                  lastOccurrence: null,
                                ),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.settings_outlined,
                          size: 18,
                          color: Color(0xFF7E57C2),
                        ),
                        label: const Text(
                          '配置',
                          style: TextStyle(
                            color: Color(0xFF7E57C2),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                      // 添加按钮
                      ElevatedButton.icon(
                        onPressed: () async {
                          final event = Event(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            name: template.name,
                            icon: template.icon,
                            category: template.group,
                            quickRecord: template.quickRecord,
                            attributes: template.attributes,
                            lastOccurrence: null,
                          );
                          await EventService().saveEvent(event);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('已添加事件"${template.name}"'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('添加'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7E57C2),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 删除按钮
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 20,
                  color: Color(0xFF9E9E9E),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('删除模板'),
                      content: Text('确定要删除"${template.name}"模板吗？'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('取消'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await TemplateService().deleteTemplate(template.id);
                            if (mounted) {
                              Navigator.pop(context);
                              setState(() {
                                _templates
                                    .removeWhere((t) => t.id == template.id);
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('删除'),
                        ),
                      ],
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

  // 构建自定义事件按钮
  Widget _buildCustomEventButton() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.defaultPadding),
      child: Row(
        children: [
          Expanded(
            child: Card(
              elevation: AppTheme.cardElevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CustomEventScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.defaultPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppTheme.smallPadding),
                        decoration: const BoxDecoration(
                          color: AppTheme.gradientStart,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: AppTheme.primaryColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: AppTheme.defaultPadding),
                      const Text(
                        '自定义事件',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
