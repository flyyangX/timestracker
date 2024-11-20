import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';
import '../../models/event.dart';
import '../../models/event_record_entry.dart';
import '../../models/field_value.dart';
import '../../services/record_service.dart';
import 'package:uuid/uuid.dart';
import '../../screens/custom_event/models/custom_attribute.dart';
import '../../screens/custom_event/models/attribute_type.dart';

class AddRecordScreen extends StatefulWidget {
  final Event event;

  const AddRecordScreen({
    super.key,
    required this.event,
  });

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recordService = RecordService();
  final _attributeValues = <String, FieldValue>{};
  final _noteController = TextEditingController();
  String _location = '';
  int _mood = 3;
  bool _isImportant = false;
  final List<String> _tags = [];
  final List<String> _images = [];
  double? _duration;
  DateTime _selectedDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.event.attributes != null) {
      for (var attr in widget.event.attributes!) {
        _attributeValues[attr.name] = FieldValue(
          value: attr.defaultValue?['defaultValue'],
          visible: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 自定义顶部区域
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE3DFFC), // 浅紫色
                  Colors.white,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // 顶部导航栏
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 取消按钮
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF8E8E93),
                          ),
                          child: const Text(
                            '取消',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        // 标题
                        const Text(
                          '新记录',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A148C),
                          ),
                        ),
                        // 保存按钮
                        ElevatedButton(
                          onPressed: _saveRecord,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7E57C2),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor:
                                const Color(0xFF7E57C2).withOpacity(0.3),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            '保存',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // 事件信息展示
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // 事件图标
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3DFFC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: widget.event.icon != null
                              ? Icon(
                                  widget.event.icon,
                                  color: const Color(0xFF7E57C2),
                                  size: 24,
                                )
                              : widget.event.emoji != null
                                  ? Center(
                                      child: Text(
                                        widget.event.emoji!,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.event,
                                      color: Color(0xFF7E57C2),
                                      size: 24,
                                    ),
                        ),
                        const SizedBox(width: 16),
                        // 事件信息
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.event.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A148C),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.event.category,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF8E8E93),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 表单内容
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildTimeCard(),
                  const SizedBox(height: 16),
                  _buildBasicInfoCard(),
                  const SizedBox(height: 16),
                  if (widget.event.attributes != null) ...[
                    _buildCustomAttributesCard(),
                    const SizedBox(height: 16),
                  ],
                  _buildNoteCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: InkWell(
        onTap: _showDateTimePicker,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(
                Icons.access_time,
                color: Color(0xFF7E57C2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '记录时间',
                      style: TextStyle(
                        color: Color(0xFF757575),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(_selectedDateTime),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF757575),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '基础信息',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 心情评分
            _buildFieldWithVisibilityToggle(
              fieldName: '心情',
              isVisible: _attributeValues['mood']?.visible ?? true,
              onVisibilityChanged: (value) {
                setState(() {
                  _attributeValues['mood'] = FieldValue(
                    value: _mood,
                    visible: value,
                  );
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (index) {
                      final rating = index + 1;
                      return InkWell(
                        onTap: () => setState(() => _mood = rating),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: rating == _mood
                                ? const Color(0xFF7E57C2)
                                : const Color(0xFFEDE7F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            rating <= _mood
                                ? Icons.sentiment_very_satisfied
                                : Icons.sentiment_very_satisfied_outlined,
                            color: rating == _mood
                                ? Colors.white
                                : const Color(0xFF512DA8),
                            size: 28,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const Divider(),

            // 重要性标记
            _buildFieldWithVisibilityToggle(
              fieldName: '重要性',
              isVisible: _attributeValues['importance']?.visible ?? true,
              onVisibilityChanged: (value) {
                setState(() {
                  _attributeValues['importance'] = FieldValue(
                    value: _isImportant,
                    visible: value,
                  );
                });
              },
              child: _buildImportanceToggle(),
            ),
            const Divider(),

            // 持续时间
            _buildFieldWithVisibilityToggle(
              fieldName: '持续时间',
              isVisible: _attributeValues['duration']?.visible ?? true,
              onVisibilityChanged: (value) {
                setState(() {
                  _attributeValues['duration'] = FieldValue(
                    value: _duration,
                    visible: value,
                  );
                });
              },
              child: _buildDurationInput(),
            ),
            const SizedBox(height: 16),

            // 位置信息
            _buildFieldWithVisibilityToggle(
              fieldName: '位置',
              isVisible: _attributeValues['location']?.visible ?? true,
              onVisibilityChanged: (value) {
                setState(() {
                  _attributeValues['location'] = FieldValue(
                    value: _location,
                    visible: value,
                  );
                });
              },
              child: _buildLocationInput(),
            ),
            const SizedBox(height: 16),

            // 标签
            _buildFieldWithVisibilityToggle(
              fieldName: '标签',
              isVisible: _attributeValues['tags']?.visible ?? true,
              onVisibilityChanged: (value) {
                setState(() {
                  _attributeValues['tags'] = FieldValue(
                    value: _tags,
                    visible: value,
                  );
                });
              },
              child: _buildTagsSection(),
            ),
          ],
        ),
      ),
    );
  }

  // 构建自定义属性卡片
  Widget _buildCustomAttributesCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '自定义属性',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...widget.event.attributes!
                .map((attr) => _buildAttributeInput(attr)),
          ],
        ),
      ),
    );
  }

  // 构建备注卡片
  Widget _buildNoteCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '备注',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: '添加备注...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构���重要性标记
  Widget _buildImportanceToggle() {
    return SwitchListTile(
      title: const Text('标记为重要'),
      subtitle: const Text('标记后可以快速筛选重要事件'),
      value: _isImportant,
      onChanged: (value) => setState(() => _isImportant = value),
      activeColor: const Color(0xFF7E57C2),
    );
  }

  // 构建持续时间输入
  Widget _buildDurationInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '持续时间',
          style: TextStyle(
            color: Color(0xFF757575),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: '输入持续时间（分钟）',
            border: OutlineInputBorder(),
            suffixText: '分钟',
          ),
          onChanged: (value) {
            setState(() {
              _duration = double.tryParse(value);
            });
          },
        ),
      ],
    );
  }

  // 构建位置信息输入
  Widget _buildLocationInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '位置',
          style: TextStyle(
            color: Color(0xFF757575),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: const InputDecoration(
            hintText: '输入位置信息',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on),
          ),
          onChanged: (value) => setState(() => _location = value),
        ),
      ],
    );
  }

  // 构建标签选择
  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '标签',
          style: TextStyle(
            color: Color(0xFF757575),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ..._tags.map((tag) => Chip(
                  label: Text(tag),
                  onDeleted: () {
                    setState(() {
                      _tags.remove(tag);
                    });
                  },
                )),
            ActionChip(
              label: const Text('添加标签'),
              onPressed: _showAddTagDialog,
              avatar: const Icon(Icons.add, size: 16),
            ),
          ],
        ),
      ],
    );
  }

  // 添加一个通用的字段包装器
  Widget _buildFieldWithVisibilityToggle({
    required String fieldName,
    required Widget child,
    required bool isVisible,
    required Function(bool) onVisibilityChanged,
  }) {
    return Row(
      children: [
        Expanded(child: child),
        IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color:
                isVisible ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
          ),
          onPressed: () => onVisibilityChanged(!isVisible),
        ),
      ],
    );
  }

  // 构建属性输入控件
  Widget _buildAttributeInput(CustomAttribute attr) {
    return _buildFieldWithVisibilityToggle(
      fieldName: attr.name,
      isVisible: _attributeValues[attr.name]?.visible ?? true,
      onVisibilityChanged: (value) {
        setState(() {
          _attributeValues[attr.name] = FieldValue(
            value: _attributeValues[attr.name]?.value,
            visible: value,
          );
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            attr.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.smallPadding),
          // 根据属性类型构建不同的输入控件
          _buildAttributeField(attr),
        ],
      ),
    );
  }

  // 构建具体的属性字段
  Widget _buildAttributeField(CustomAttribute attr) {
    switch (attr.type) {
      case AttributeType.number:
        return _buildNumberField(attr);
      case AttributeType.singleChoice:
        return _buildSingleChoiceField(attr);
      case AttributeType.multipleChoice:
        return _buildMultiChoiceField(attr);
      case AttributeType.text:
        return _buildTextField(attr);
      case AttributeType.toggle:
        return _buildToggleField(attr);
      case AttributeType.date:
        return _buildDateField(attr);
    }
  }

  void _showDateTimePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _saveRecord() async {
    if (_formKey.currentState!.validate()) {
      try {
        // 处理属性值，确保类型正确
        final processedAttributes = <String, FieldValue>{};

        // 处理默认字段
        processedAttributes['mood'] = FieldValue(
          value: _mood.toString(), // 转换为字符串
          visible: _attributeValues['mood']?.visible ?? true,
        );

        processedAttributes['importance'] = FieldValue(
          value: _isImportant.toString(), // 转换为字符串
          visible: _attributeValues['importance']?.visible ?? true,
        );

        if (_duration != null) {
          processedAttributes['duration'] = FieldValue(
            value: _duration.toString(), // 转换为字符串
            visible: _attributeValues['duration']?.visible ?? true,
          );
        }

        if (_location.isNotEmpty) {
          processedAttributes['location'] = FieldValue(
            value: _location,
            visible: _attributeValues['location']?.visible ?? true,
          );
        }

        if (_tags.isNotEmpty) {
          processedAttributes['tags'] = FieldValue(
            value: _tags.join(','), // 转换为字符串
            visible: _attributeValues['tags']?.visible ?? true,
          );
        }

        // 处理自定义属性
        if (widget.event.attributes != null) {
          for (var attr in widget.event.attributes!) {
            final value = _attributeValues[attr.name]?.value;
            if (value != null) {
              // 根据属性类型处理值
              var processedValue = value;
              if (value is double || value is int) {
                processedValue = value.toString();
              } else if (value is DateTime) {
                processedValue = value.toIso8601String();
              } else if (value is List) {
                processedValue = value.map((item) => item.toString()).join(',');
              } else if (value is bool) {
                processedValue = value.toString();
              }

              processedAttributes[attr.name] = FieldValue(
                value: processedValue,
                visible: _attributeValues[attr.name]?.visible ?? true,
              );
            }
          }
        }

        // 创建记录
        final record = EventRecordEntry(
          id: const Uuid().v4(),
          eventId: widget.event.id,
          timestamp: _selectedDateTime,
          location: _location,
          note: _noteController.text,
          duration: _duration,
          mood: _mood,
          isImportant: _isImportant,
          tags: _tags,
          attributeValues: processedAttributes,
          images: _images,
        );

        // 保存记录
        await _recordService.saveRecord(record);

        if (mounted) {
          // 显示成功提示
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('记录已保存'),
              backgroundColor: Colors.green,
            ),
          );
          // 返回上一页
          Navigator.pop(context, true);
        }
      } catch (e) {
        // 显示错误提示
        if (mounted) {
          print('Save Error: $e'); // 调试用
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('保存失败：$e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // 显示添加标签对话框
  void _showAddTagDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加标签'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '标签名称',
            hintText: '请输入标签名称',
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
            onPressed: () {
              final tag = controller.text.trim();
              if (tag.isNotEmpty) {
                setState(() {
                  _tags.add(tag);
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请输入标签名称')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  // 修改各个字段构建方法，移除其中的可见性控制，因为已经由_buildFieldWithVisibilityToggle统一处理
  Widget _buildNumberField(CustomAttribute attr) {
    return TextFormField(
      initialValue: _attributeValues[attr.name]?.value?.toString(),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: '请输入${attr.name}',
        border: const OutlineInputBorder(),
        suffixText: attr.defaultValue?['unit'] ?? '',
      ),
      onChanged: (value) {
        setState(() {
          _attributeValues[attr.name] = FieldValue(
            value: double.tryParse(value),
            visible: _attributeValues[attr.name]?.visible ?? true,
          );
        });
      },
    );
  }

  Widget _buildSingleChoiceField(CustomAttribute attr) {
    return Wrap(
      spacing: AppTheme.smallPadding,
      children: attr.options!.map((option) {
        final isSelected = _attributeValues[attr.name]?.value == option;
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _attributeValues[attr.name] = FieldValue(
                value: selected ? option : null,
                visible: _attributeValues[attr.name]?.visible ?? true,
              );
            });
          },
          selectedColor: AppTheme.primaryColor,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultiChoiceField(CustomAttribute attr) {
    _attributeValues[attr.name] ??=
        FieldValue(value: <String>[], visible: true);
    return Wrap(
      spacing: AppTheme.smallPadding,
      children: attr.options!.map((option) {
        final isSelected = (_attributeValues[attr.name]?.value as List<String>?)
                ?.contains(option) ??
            false;
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              final list =
                  (_attributeValues[attr.name]?.value as List<String>? ?? [])
                      .toList();
              if (selected) {
                list.add(option);
              } else {
                list.remove(option);
              }
              _attributeValues[attr.name] = FieldValue(
                value: list,
                visible: _attributeValues[attr.name]?.visible ?? true,
              );
            });
          },
          selectedColor: AppTheme.primaryColor,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField(CustomAttribute attr) {
    return TextFormField(
      initialValue: _attributeValues[attr.name]?.value?.toString(),
      maxLines: 3,
      decoration: InputDecoration(
        hintText: '请输入${attr.name}',
        border: const OutlineInputBorder(),
      ),
      onChanged: (value) {
        setState(() {
          _attributeValues[attr.name] = FieldValue(
            value: value,
            visible: _attributeValues[attr.name]?.visible ?? true,
          );
        });
      },
    );
  }

  Widget _buildToggleField(CustomAttribute attr) {
    _attributeValues[attr.name] ??= FieldValue(value: false, visible: true);
    return SwitchListTile(
      title: Text(attr.name),
      value: _attributeValues[attr.name]?.value ?? false,
      onChanged: (value) {
        setState(() {
          _attributeValues[attr.name] = FieldValue(
            value: value,
            visible: _attributeValues[attr.name]?.visible ?? true,
          );
        });
      },
      activeColor: AppTheme.primaryColor,
    );
  }

  Widget _buildDateField(CustomAttribute attr) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _attributeValues[attr.name]?.value ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          setState(() {
            _attributeValues[attr.name] = FieldValue(
              value: picked,
              visible: _attributeValues[attr.name]?.visible ?? true,
            );
          });
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ),
        child: Text(
          _attributeValues[attr.name]?.value != null
              ? '${_attributeValues[attr.name]!.value.year}-${_attributeValues[attr.name]!.value.month}-${_attributeValues[attr.name]!.value.day}'
              : '请选择日期',
        ),
      ),
    );
  }
}
