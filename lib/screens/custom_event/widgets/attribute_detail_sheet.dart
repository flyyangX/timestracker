import 'package:flutter/material.dart';
import '../../../themes/app_theme.dart';
import '../models/attribute_type.dart';
import '../models/custom_attribute.dart';

/// 属性详情设置表单组件
/// 用于配置具体属性的参数
class AttributeDetailSheet extends StatefulWidget {
  final AttributeType type;
  final Function(CustomAttribute) onAttributeCreated;

  const AttributeDetailSheet({
    super.key,
    required this.type,
    required this.onAttributeCreated,
  });

  @override
  State<AttributeDetailSheet> createState() => _AttributeDetailSheetState();
}

class _AttributeDetailSheetState extends State<AttributeDetailSheet> {
  final nameController = TextEditingController();
  final unitController = TextEditingController();
  final defaultValueController = TextEditingController();
  bool isRequired = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          _buildForm(),
          _buildBottomButton(context),
        ],
      ),
    );
  }

  /// 构建顶部标题栏
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.defaultPadding,
        vertical: AppTheme.defaultPadding * 1.5,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFEEEEEE),
            width: 1,
          ),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '设置${_getAttributeTypeLabel()}属性',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
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

  /// 构建表单内容
  Widget _buildForm() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 名称输入（所有类型都需要）
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: '属性名称',
                hintText: '例如：${_getAttributeTypeExample()}',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.defaultPadding),

            // 根据类型显示不同的字段
            if (widget.type == AttributeType.number) ...[
              // 单位输入
              TextField(
                controller: unitController,
                decoration: InputDecoration(
                  labelText: '单位',
                  hintText: '例如：个、元',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.defaultPadding),
              // 默认值输入
              TextField(
                controller: defaultValueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '默认值',
                  hintText: '输入默认数值',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],

            const SizedBox(height: AppTheme.defaultPadding),
            // 必填开关（所有类型都可以设置）
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: const Text('必填'),
                subtitle: const Text('记录事件时必须填写此属性'),
                value: isRequired,
                onChanged: (bool value) {
                  setState(() {
                    isRequired = value;
                  });
                },
                activeColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建底部按钮
  Widget _buildBottomButton(BuildContext context) {
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
            child: ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  // 创建数字属性并返回
                  final numberAttribute = CustomAttribute(
                    name: nameController.text,
                    type: widget.type,
                    options: null,
                    defaultValue: {
                      'unit': unitController.text,
                      'defaultValue': defaultValueController.text.isNotEmpty
                          ? double.tryParse(defaultValueController.text)
                          : null,
                      'isRequired': isRequired,
                    },
                  );

                  // 调用回调函数，传递属性数据
                  widget.onAttributeCreated(numberAttribute);
                  Navigator.pop(context);
                } else {
                  // 显示错误提示
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('请填写属性名称'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '确认添加',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 获取属性类型标签
  String _getAttributeTypeLabel() {
    switch (widget.type) {
      case AttributeType.number:
        return '数字';
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

  /// 获取属性类型示例
  String _getAttributeTypeExample() {
    switch (widget.type) {
      case AttributeType.number:
        return '完成次数、难度等级';
      case AttributeType.singleChoice:
        return '心情、天气';
      case AttributeType.multipleChoice:
        return '参与人员、标签';
      case AttributeType.text:
        return '备注、感想';
      case AttributeType.toggle:
        return '是否完成、是否重要';
      case AttributeType.date:
        return '截止日期、提醒日期';
    }
  }
}
