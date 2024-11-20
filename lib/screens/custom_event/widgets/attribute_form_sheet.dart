import 'package:flutter/material.dart';
import '../../../themes/app_theme.dart';
import '../models/attribute_type.dart';
import '../models/custom_attribute.dart';

/// 属性配置表单组件
class AttributeFormSheet extends StatefulWidget {
  final AttributeType type;
  final CustomAttribute? attribute;
  final Function(CustomAttribute) onAttributeCreated;

  const AttributeFormSheet({
    super.key,
    required this.type,
    this.attribute,
    required this.onAttributeCreated,
  });

  @override
  State<AttributeFormSheet> createState() => _AttributeFormSheetState();
}

class _AttributeFormSheetState extends State<AttributeFormSheet> {
  // 通用控制器
  final _nameController = TextEditingController();
  bool _isRequired = false;

  // 数值属性控制器
  final _unitController = TextEditingController();
  final _defaultValueController = TextEditingController();

  // 多选属性控制器
  final List<Map<String, dynamic>> _options = [];
  final List<String> _selectedDefaultOptions = [];
  String? _selectedDefaultOption;

  // 添加日期属性控制器
  DateTime? _selectedDate;

  // 添加开关属性控制器
  bool _defaultToggleValue = false;

  // 添加文本属性控制器
  final _defaultTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 如果是编辑模式，加载现有属性数据
    if (widget.attribute != null) {
      _loadAttributeData();
    }
  }

  void _loadAttributeData() {
    final attribute = widget.attribute!;
    _nameController.text = attribute.name;
    _isRequired = attribute.defaultValue?['isRequired'] ?? false;

    switch (attribute.type) {
      case AttributeType.number:
        _unitController.text = attribute.defaultValue?['unit'] ?? '';
        _defaultValueController.text =
            attribute.defaultValue?['defaultValue']?.toString() ?? '';
        break;

      case AttributeType.singleChoice:
        _options.clear();
        for (var option in attribute.options ?? []) {
          _options.add({
            'value': option,
            'isVisible': true,
          });
        }
        _selectedDefaultOption = attribute.defaultValue?['defaultValue'];
        break;

      case AttributeType.multipleChoice:
        _options.clear();
        for (var option in attribute.options ?? []) {
          _options.add({
            'value': option,
            'isVisible': true,
          });
        }
        _selectedDefaultOptions.clear();
        _selectedDefaultOptions.addAll(
            (attribute.defaultValue?['defaultValues'] as List<String>?) ?? []);
        break;

      case AttributeType.text:
        _defaultTextController.text =
            attribute.defaultValue?['defaultValue'] ?? '';
        break;

      case AttributeType.toggle:
        _defaultToggleValue = attribute.defaultValue?['defaultValue'] ?? false;
        break;

      case AttributeType.date:
        if (attribute.defaultValue?['defaultValue'] != null) {
          _selectedDate =
              DateTime.parse(attribute.defaultValue!['defaultValue']);
        }
        break;
    }
  }

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
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 名称输入
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '名称',
                      hintText: '请输入属性名称',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppTheme.defaultPadding * 2),

                  // 根据属性类型显示不同的选项管理界面
                  if (widget.type == AttributeType.singleChoice)
                    _buildSingleChoiceOptions()
                  else if (widget.type == AttributeType.multipleChoice)
                    _buildMultiChoiceOptions(),

                  const SizedBox(height: AppTheme.defaultPadding),
                  // 必填开关
                  Card(
                    elevation: AppTheme.cardElevation,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.cardBorderRadius),
                    ),
                    child: SwitchListTile(
                      title: const Text('必填'),
                      subtitle: const Text('记录事件时必须填写此属性'),
                      value: _isRequired,
                      onChanged: (value) => setState(() => _isRequired = value),
                      activeColor: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomButton(),
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
          Text(
            widget.attribute != null ? '编辑属性' : '新建属性',
            style: const TextStyle(
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

  Widget _buildBottomButton() {
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
              onPressed: _validateAndSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                widget.attribute != null ? '保存' : '新建',
                style: const TextStyle(
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

  // 日期选择器
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _validateAndSave() {
    // 1. 基础验证
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入属性名称')),
      );
      return;
    }

    // 2. 根据属性类型进行特定验证
    if ((widget.type == AttributeType.singleChoice ||
            widget.type == AttributeType.multipleChoice) &&
        _options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请添加至少一个选项')),
      );
      return;
    }

    // 3. 创建属性对象
    final attribute = CustomAttribute(
      name: _nameController.text,
      type: widget.type,
      options: widget.type == AttributeType.singleChoice ||
              widget.type == AttributeType.multipleChoice
          ? _options
              .where((option) => option['isVisible'] as bool)
              .map((option) => option['value'] as String)
              .toList()
          : null,
      defaultValue: _getDefaultValue(),
    );

    // 4. 调用回调函数并返回
    widget.onAttributeCreated(attribute);
  }

  Map<String, dynamic> _getDefaultValue() {
    Map<String, dynamic> defaultValue = {
      'isRequired': _isRequired,
    };

    switch (widget.type) {
      case AttributeType.number:
        defaultValue['unit'] = _unitController.text;
        defaultValue['defaultValue'] = _defaultValueController.text.isNotEmpty
            ? double.tryParse(_defaultValueController.text)
            : null;
        break;

      case AttributeType.text:
        defaultValue['defaultValue'] = _defaultTextController.text;
        break;

      case AttributeType.toggle:
        defaultValue['defaultValue'] = _defaultToggleValue;
        break;

      case AttributeType.date:
        defaultValue['defaultValue'] = _selectedDate?.toIso8601String();
        break;

      case AttributeType.multipleChoice:
        defaultValue['defaultValues'] = _selectedDefaultOptions
            .where((value) => _options
                .where((option) => option['isVisible'] as bool)
                .map((option) => option['value'] as String)
                .contains(value))
            .toList();
        break;

      case AttributeType.singleChoice:
        defaultValue['defaultValue'] = _selectedDefaultOption;
        break;
    }

    return defaultValue;
  }

  String _getAttributeTypeLabel() {
    switch (widget.type) {
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

  Widget _buildSingleChoiceOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '选项管理',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppTheme.defaultPadding),

        // 选项列表
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final item = _options.removeAt(oldIndex);
              _options.insert(newIndex, item);
            });
          },
          children: _options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            return Container(
              key: ValueKey(option),
              margin: const EdgeInsets.only(bottom: AppTheme.smallPadding),
              child: Row(
                children: [
                  // 删除按钮
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    color: Colors.red,
                    onPressed: () {
                      setState(() {
                        _options.removeAt(index);
                        if (_selectedDefaultOption == option['value']) {
                          _selectedDefaultOption = null;
                        }
                      });
                    },
                  ),
                  // 选项输入框
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(
                          text: option['value'] as String),
                      onChanged: (value) {
                        setState(() {
                          final oldValue = option['value'] as String;
                          option['value'] = value;
                          if (_selectedDefaultOption == oldValue) {
                            _selectedDefaultOption = value;
                          }
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: '请输入选项内容',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  // 默认值复选框
                  Checkbox(
                    value: _selectedDefaultOption == option['value'],
                    onChanged: (bool? value) {
                      setState(() {
                        // 单选属性：选中前选项时，取消其他选项的选中状态
                        if (value == true) {
                          _selectedDefaultOption = option['value'] as String;
                        } else if (_selectedDefaultOption == option['value']) {
                          _selectedDefaultOption = null;
                        }
                      });
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  // 显示/隐藏按钮
                  IconButton(
                    icon: Icon(
                      option['isVisible'] as bool
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: option['isVisible'] as bool
                          ? AppTheme.primaryColor
                          : AppTheme.textSecondaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        option['isVisible'] = !(option['isVisible'] as bool);
                        if (!option['isVisible'] &&
                            _selectedDefaultOption == option['value']) {
                          _selectedDefaultOption = null;
                        }
                      });
                    },
                  ),
                  // 拖动排序按钮
                  ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle),
                  ),
                ],
              ),
            );
          }).toList(),
        ),

        // 添加选项按钮
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _options.add({
                'value': '',
                'isVisible': true,
              });
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('添加选项'),
        ),
      ],
    );
  }

  Widget _buildMultiChoiceOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '选项管理',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: AppTheme.defaultPadding),

        // 选项列表
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final item = _options.removeAt(oldIndex);
              _options.insert(newIndex, item);
            });
          },
          children: _options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            return Container(
              key: ValueKey(option),
              margin: const EdgeInsets.only(bottom: AppTheme.smallPadding),
              child: Row(
                children: [
                  // 删除按钮
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    color: Colors.red,
                    onPressed: () {
                      setState(() {
                        _options.removeAt(index);
                        _selectedDefaultOptions.remove(option['value']);
                      });
                    },
                  ),
                  // 选项输入框
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(
                          text: option['value'] as String),
                      onChanged: (value) {
                        setState(() {
                          final oldValue = option['value'] as String;
                          option['value'] = value;
                          if (_selectedDefaultOptions.contains(oldValue)) {
                            _selectedDefaultOptions.remove(oldValue);
                            _selectedDefaultOptions.add(value);
                          }
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: '请输入选项内容',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  // 默认值复选框
                  Checkbox(
                    value: _selectedDefaultOptions.contains(option['value']),
                    onChanged: (bool? value) {
                      setState(() {
                        // 多选属性：可以选中多个选项
                        if (value == true) {
                          _selectedDefaultOptions
                              .add(option['value'] as String);
                        } else {
                          _selectedDefaultOptions.remove(option['value']);
                        }
                      });
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  // 显示/隐藏按钮
                  IconButton(
                    icon: Icon(
                      option['isVisible'] as bool
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: option['isVisible'] as bool
                          ? AppTheme.primaryColor
                          : AppTheme.textSecondaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        option['isVisible'] = !(option['isVisible'] as bool);
                        if (!option['isVisible']) {
                          _selectedDefaultOptions.remove(option['value']);
                        }
                      });
                    },
                  ),
                  // 拖动排序按钮
                  ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle),
                  ),
                ],
              ),
            );
          }).toList(),
        ),

        // 添加选项按钮
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _options.add({
                'value': '',
                'isVisible': true,
              });
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('添加选项'),
        ),
      ],
    );
  }

  Widget _buildTextOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 默认值输入框
        TextField(
          controller: _defaultTextController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: '默认值',
            hintText: '请输入默认文本（选填）',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildDateOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 默认日期选择
        InkWell(
          onTap: () => _selectDate(context),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: '默认值',
              hintText: '请选择默认日期（选填）',
              border: OutlineInputBorder(),
            ),
            child: Text(
              _selectedDate != null
                  ? '${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}'
                  : '未设置',
            ),
          ),
        ),
      ],
    );
  }
}
