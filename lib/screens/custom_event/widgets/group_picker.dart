import 'package:flutter/material.dart';
import '../../../themes/app_theme.dart';

class GroupPicker extends StatefulWidget {
  final String selectedGroup;
  final Function(String) onGroupChanged;

  const GroupPicker({
    super.key,
    required this.selectedGroup,
    required this.onGroupChanged,
  });

  @override
  State<GroupPicker> createState() => _GroupPickerState();
}

class _GroupPickerState extends State<GroupPicker> {
  // 分组列表
  final List<String> _groups = [
    '默认分组',
    '工作',
    '学习',
    '生活',
    '运动',
    '娱乐',
  ];

  // 新分组输入控制器
  final _newGroupController = TextEditingController();
  // 滚动控制器
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppTheme.defaultPadding),
              itemCount: _groups.length,
              itemBuilder: (context, index) {
                final group = _groups[index];
                // 默认分组不允许删除
                if (group == '默认分组') {
                  return _buildGroupItem(group);
                }
                return Dismissible(
                  key: Key(group),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding:
                        const EdgeInsets.only(right: AppTheme.defaultPadding),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFFA07A), // 浅红色
                          Color(0xFFFF4500), // 深红色
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius:
                          BorderRadius.circular(AppTheme.cardBorderRadius),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    // 添加删除动画
                    setState(() {
                      _groups.removeAt(index);
                    });
                    // 如果删除的是当前选中的分组，自动切换到默认分组
                    if (group == widget.selectedGroup) {
                      widget.onGroupChanged('默认分组');
                    }
                    // 显示撤销提示
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('已删除分组"$group"'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(AppTheme.defaultPadding),
                        action: SnackBarAction(
                          label: '撤销',
                          onPressed: () {
                            setState(() {
                              _groups.insert(index, group);
                            });
                          },
                        ),
                      ),
                    );
                  },
                  // 添加滑动动画
                  confirmDismiss: (direction) async {
                    return true; // 直接删除，无需确认
                  },
                  // 添加滑动过程中的动画
                  movementDuration: const Duration(milliseconds: 200), // 设置动画时长
                  dismissThresholds: const {
                    DismissDirection.endToStart: 0.5, // 设置滑动阈值
                  },
                  child: AnimatedContainer(
                    // 使用 AnimatedContainer 实现淡出动画
                    duration: const Duration(milliseconds: 200),
                    child: _buildGroupItem(group),
                  ),
                );
              },
            ),
          ),
          _buildAddGroupButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
    );
  }

  Widget _buildGroupItem(String group) {
    final isSelected = widget.selectedGroup == group;
    return Card(
      elevation: AppTheme.cardElevation,
      margin: const EdgeInsets.only(bottom: AppTheme.smallPadding),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
      ),
      child: InkWell(
        onTap: () {
          widget.onGroupChanged(group);
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.defaultPadding),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
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
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const Spacer(),
              if (isSelected)
                const Icon(
                  Icons.check,
                  color: AppTheme.primaryColor,
                ),
              if (group != '默认分组')
                const Icon(
                  Icons.chevron_left,
                  color: AppTheme.textSecondaryColor,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddGroupButton() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.defaultPadding),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFEEEEEE),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _showAddGroupDialog,
              icon: const Icon(Icons.add),
              label: const Text('新增分组'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新增分组'),
        content: TextField(
          controller: _newGroupController,
          decoration: const InputDecoration(
            labelText: '分组名称',
            hintText: '请输入分组名称',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final newGroup = _newGroupController.text.trim();
              if (newGroup.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请输入分组名称')),
                );
                return;
              }
              if (_groups.contains(newGroup)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('分组名称已存在')),
                );
                return;
              }
              setState(() {
                _groups.add(newGroup);
              });
              _newGroupController.clear();
              Navigator.pop(context);
              // 滚动到新增的分组
              Future.delayed(const Duration(milliseconds: 300), () {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              });
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

  @override
  void dispose() {
    _newGroupController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
