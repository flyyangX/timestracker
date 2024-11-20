import 'package:flutter/material.dart';
import '../../../themes/app_theme.dart';
import '../models/attribute_type.dart';
import '../models/custom_attribute.dart';
import 'attribute_type_sheet.dart';

class AttributeList extends StatefulWidget {
  const AttributeList({super.key});

  @override
  State<AttributeList> createState() => _AttributeListState();
}

class _AttributeListState extends State<AttributeList> {
  // 属性列表
  final List<CustomAttribute> _attributes = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '属性',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppTheme.smallPadding),
        Card(
          elevation: AppTheme.cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
          ),
          child: Column(
            children: [
              if (_attributes.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(AppTheme.defaultPadding),
                  child: Text(
                    '点击下方按钮添加属性',
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ),
              // 属性列表
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final item = _attributes.removeAt(oldIndex);
                    _attributes.insert(newIndex, item);
                  });
                },
                children: _attributes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final attribute = entry.value;
                  return _buildAttributeCard(attribute, index);
                }).toList(),
              ),
              // 添加属性按钮
              Padding(
                padding: const EdgeInsets.all(AppTheme.defaultPadding),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: _showAddAttributeSheet,
                        icon:
                            const Icon(Icons.add, color: AppTheme.primaryColor),
                        label: const Text(
                          '添加属性',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttributeCard(CustomAttribute attribute, int index) {
    return Card(
      key: ValueKey(attribute),
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.defaultPadding,
        vertical: AppTheme.smallPadding,
      ),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.defaultPadding),
        child: Row(
          children: [
            // 删除按钮
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              color: Colors.red,
              onPressed: () {
                setState(() {
                  _attributes.removeAt(index);
                });
                // 显示撤销提示
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('已删除属性"${attribute.name}"'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.all(AppTheme.defaultPadding),
                    action: SnackBarAction(
                      label: '撤销',
                      onPressed: () {
                        setState(() {
                          _attributes.insert(index, attribute);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
            // 属性信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        attribute.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: attribute.defaultValue?['isRequired'] == true
                              ? Colors.red.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          attribute.defaultValue?['isRequired'] == true
                              ? '必填'
                              : '非必填',
                          style: TextStyle(
                            fontSize: 12,
                            color: attribute.defaultValue?['isRequired'] == true
                                ? Colors.red
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getAttributeTypeLabel(attribute.type),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  if (_hasDefaultValue(attribute)) ...[
                    const SizedBox(height: 4),
                    Text(
                      _getDefaultValueText(attribute),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // 拖动排序按钮
            ReorderableDragStartListener(
              index: index,
              child: const Icon(
                Icons.drag_handle,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAttributeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AttributeTypeSheet(
          onTypeSelected: (attribute) {
            setState(() {
              _attributes.add(attribute);
            });
          },
        );
      },
    );
  }

  String _getAttributeTypeLabel(AttributeType type) {
    switch (type) {
      case AttributeType.number:
        return '数值属性';
      case AttributeType.singleChoice:
        return '单选属性';
      case AttributeType.multipleChoice:
        return '多选属性';
      case AttributeType.text:
        return '文本属性';
      case AttributeType.toggle:
        return '开关属性';
      case AttributeType.date:
        return '日期属性';
    }
  }

  bool _hasDefaultValue(CustomAttribute attribute) {
    if (attribute.defaultValue == null) return false;

    switch (attribute.type) {
      case AttributeType.number:
        return attribute.defaultValue!['defaultValue'] != null ||
            attribute.defaultValue!['unit'] != null;
      case AttributeType.singleChoice:
      case AttributeType.multipleChoice:
        return attribute.defaultValue!['defaultValues'] != null &&
            (attribute.defaultValue!['defaultValues'] as List).isNotEmpty;
      case AttributeType.text:
        return attribute.defaultValue!['defaultValue']?.isNotEmpty == true;
      case AttributeType.toggle:
        return attribute.defaultValue!['defaultValue'] != null;
      case AttributeType.date:
        return attribute.defaultValue!['defaultValue'] != null;
    }
  }

  String _getDefaultValueText(CustomAttribute attribute) {
    if (attribute.defaultValue == null) return '';

    switch (attribute.type) {
      case AttributeType.number:
        final value = attribute.defaultValue!['defaultValue'];
        final unit = attribute.defaultValue!['unit'];
        if (value == null) return unit != null ? '单位: $unit' : '';
        return '默认值: $value${unit ?? ''}';

      case AttributeType.singleChoice:
        final value = attribute.defaultValue!['defaultValue'];
        return value != null ? '默认值: $value' : '';

      case AttributeType.multipleChoice:
        final values = attribute.defaultValue!['defaultValues'] as List;
        return values.isNotEmpty ? '默认值: ${values.join(", ")}' : '';

      case AttributeType.text:
        final value = attribute.defaultValue!['defaultValue'];
        return value != null ? '默认值: $value' : '';

      case AttributeType.toggle:
        final value = attribute.defaultValue!['defaultValue'] as bool;
        return '默认值: ${value ? "开启" : "关闭"}';

      case AttributeType.date:
        final value = attribute.defaultValue!['defaultValue'];
        if (value == null) return '';
        final date = DateTime.parse(value);
        return '默认值: ${date.year}-${date.month}-${date.day}';
    }
  }
}
