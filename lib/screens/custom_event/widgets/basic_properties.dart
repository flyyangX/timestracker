import 'package:flutter/material.dart';
import '../../../themes/app_theme.dart';
import 'group_picker.dart';

class BasicProperties extends StatelessWidget {
  final String selectedGroup;
  final bool quickRecord;
  final Function(String) onGroupChanged;
  final Function(bool) onQuickRecordChanged;

  const BasicProperties({
    super.key,
    required this.selectedGroup,
    required this.quickRecord,
    required this.onGroupChanged,
    required this.onQuickRecordChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppTheme.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
      ),
      child: Column(
        children: [
          // 分组选择
          ListTile(
            title: const Text('分组'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedGroup,
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () => _showGroupPicker(context),
          ),
          const Divider(height: 1),
          // 快速记录开关
          SwitchListTile(
            title: const Text('快速记录'),
            value: quickRecord,
            onChanged: onQuickRecordChanged,
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  void _showGroupPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GroupPicker(
        selectedGroup: selectedGroup,
        onGroupChanged: onGroupChanged,
      ),
    );
  }
}
