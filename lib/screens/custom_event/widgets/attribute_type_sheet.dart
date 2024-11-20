import 'package:flutter/material.dart';
import '../../../themes/app_theme.dart';
import '../models/attribute_type.dart';
import '../models/custom_attribute.dart';
import 'attribute_form_sheet.dart';

/// 属性类型选择表单组件
/// 用于显示所有可用的属性类型，并处理用户的选择
class AttributeTypeSheet extends StatelessWidget {
  /// 当用户选择属性类型时的回调函数
  final Function(CustomAttribute) onTypeSelected;

  /// 构造函数
  /// [onTypeSelected] 必须提供，用于处理属性类型的选择
  const AttributeTypeSheet({
    super.key,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    // 底部表单容器
    return Container(
      height: MediaQuery.of(context).size.height * 0.8, // 设置高度为屏幕高度的80%
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20), // 顶部圆角
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          _buildTypeList(context),
        ],
      ),
    );
  }

  /// 构建顶部标题栏
  /// 包含标题文本和关闭按钮
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.defaultPadding,
        vertical: AppTheme.defaultPadding * 1.5,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFEEEEEE), // 底部分割线颜色
            width: 1,
          ),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 标题文本
          const Text(
            '选择你需要的属性类型',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          // 关闭按钮
          Positioned(
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建属性类型列表
  /// 显示所有可用的属性类型选项
  Widget _buildTypeList(BuildContext context) {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.all(AppTheme.defaultPadding),
        children: [
          // 数值属性
          _buildTypeButton(
            context,
            type: AttributeType.number,
            title: '数值属性',
            description: '用于记录具有数值和单位的属性，如：完成次数、难度等级',
            icon: Icons.numbers,
          ),
          const SizedBox(height: AppTheme.defaultPadding),

          // 单选属性
          _buildTypeButton(
            context,
            type: AttributeType.singleChoice,
            title: '单选属性',
            description: '用于从多个选项中选择一个，如：心情、天气',
            icon: Icons.radio_button_checked,
          ),
          const SizedBox(height: AppTheme.defaultPadding),

          // 多选属性
          _buildTypeButton(
            context,
            type: AttributeType.multipleChoice,
            title: '多选属性',
            description: '用于从多个选项中选择多个，如：参与人员、标签',
            icon: Icons.check_box,
          ),
          const SizedBox(height: AppTheme.defaultPadding),

          // 文本属性
          _buildTypeButton(
            context,
            type: AttributeType.text,
            title: '文本性',
            description: '用于记录文字内容，如：备注、感想',
            icon: Icons.text_fields,
          ),
          const SizedBox(height: AppTheme.defaultPadding),

          // 开关属性
          _buildTypeButton(
            context,
            type: AttributeType.toggle,
            title: '开关属性',
            description: '用于表示是或否的状态，如：是否完成、是否重要',
            icon: Icons.toggle_on,
          ),
          const SizedBox(height: AppTheme.defaultPadding),

          // 日期属性
          _buildTypeButton(
            context,
            type: AttributeType.date,
            title: '日期属性',
            description: '用于选择日期，如：截止日期、提醒日期',
            icon: Icons.calendar_today,
          ),
        ],
      ),
    );
  }

  /// 构建属性类型按钮
  /// [context] - 构建上下文
  /// [icon] - 属性类型图标
  /// [title] - 属性类型标题
  /// [description] - 属性类型描述
  /// [type] - 属性类型枚举值
  Widget _buildTypeButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required AttributeType type,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.defaultPadding),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: InkWell(
          onTap: () {
            // 显示新建属性表单
            _showAttributeForm(context, type);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.defaultPadding),
            child: Row(
              children: [
                // 属性类型图标
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.gradientStart,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppTheme.defaultPadding),
                // 属性类型信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // 描述
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // 右侧箭头图标
                const Icon(
                  Icons.chevron_right,
                  color: AppTheme.textSecondaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAttributeForm(BuildContext context, AttributeType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AttributeFormSheet(
        type: type,
        onAttributeCreated: (attribute) {
          // 先关闭属性表单
          Navigator.pop(context);
          // 再关闭类型选表��创建的属性
          Navigator.pop(context);
          onTypeSelected(attribute);
        },
      ),
    );
  }
}
