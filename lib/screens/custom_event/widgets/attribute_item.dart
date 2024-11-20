import 'package:flutter/material.dart';
import '../../../themes/app_theme.dart';
import '../models/custom_attribute.dart';
import '../models/attribute_type.dart';

class AttributeItem extends StatelessWidget {
  final CustomAttribute attribute;
  final VoidCallback? onDelete;

  const AttributeItem({
    super.key,
    required this.attribute,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.defaultPadding,
        vertical: AppTheme.smallPadding,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 删除按钮
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: AppTheme.defaultPadding),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.remove,
                color: Colors.red,
                size: 20,
              ),
              onPressed: onDelete,
            ),
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        attribute.defaultValue?['isRequired'] == true
                            ? '必填'
                            : '选填',
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
                  _getAttributeDescription(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),

          // 拖动排序按钮
          const Icon(
            Icons.drag_handle,
            color: AppTheme.textSecondaryColor,
          ),
        ],
      ),
    );
  }

  String _getAttributeDescription() {
    String typeLabel = _getAttributeTypeLabel();
    String defaultValue = _getDefaultValueText();
    return '$typeLabel${defaultValue.isNotEmpty ? ' • $defaultValue' : ''}';
  }

  String _getAttributeTypeLabel() {
    switch (attribute.type) {
      case AttributeType.number:
        return '数值';
      case AttributeType.singleChoice:
        return '单选';
      case AttributeType.multipleChoice:
        return '多选';
      case AttributeType.text:
        return '文本';
      case AttributeType.toggle:
        return '开关';
      case AttributeType.date:
        return '日期';
    }
  }

  String _getDefaultValueText() {
    if (attribute.defaultValue == null) return '';

    switch (attribute.type) {
      case AttributeType.number:
        final value = attribute.defaultValue!['defaultValue'];
        final unit = attribute.defaultValue!['unit'];
        if (value == null) return unit?.isNotEmpty == true ? '单位: $unit' : '';
        return '默认值: $value${unit ?? ''}';

      case AttributeType.text:
        final value = attribute.defaultValue!['defaultValue'];
        if (value == null || value.isEmpty) return '';
        return '默认值: $value';

      case AttributeType.toggle:
        final value = attribute.defaultValue!['defaultValue'];
        if (value == null) return '';
        return '默认值: ${value ? '开启' : '关闭'}';

      case AttributeType.date:
        final value = attribute.defaultValue!['defaultValue'];
        if (value == null) return '';
        final date = DateTime.parse(value);
        return '默认值: ${date.year}-${date.month}-${date.day}';

      case AttributeType.singleChoice:
        final value = attribute.defaultValue!['defaultValue'];
        if (value == null) return '';
        return '默认值: $value';

      case AttributeType.multipleChoice:
        final values =
            attribute.defaultValue!['defaultValues'] as List<String>?;
        if (values == null || values.isEmpty) return '';
        return '默认值: ${values.join(", ")}';
    }
  }
}
