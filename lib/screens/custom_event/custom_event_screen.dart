import 'package:flutter/material.dart';
import 'dart:io';
import '../../models/event.dart';
import '../../themes/app_theme.dart';
import 'models/attribute_type.dart';
import 'models/custom_attribute.dart';
import 'widgets/event_name_section.dart';
import 'widgets/basic_properties.dart';
import 'widgets/custom_attributes.dart';
import 'widgets/reminder_settings.dart';
import 'widgets/attribute_detail_sheet.dart';
import '../../services/event_service.dart';
import '../../services/template_service.dart';
import '../../models/event_template.dart';

class CustomEventScreen extends StatefulWidget {
  final Event? initialEvent;

  const CustomEventScreen({
    super.key,
    this.initialEvent,
  });

  @override
  State<CustomEventScreen> createState() => _CustomEventScreenState();
}

class _CustomEventScreenState extends State<CustomEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  IconData? _selectedIcon = Icons.event;
  String? _selectedEmoji;
  File? _selectedImage;
  String _selectedGroup = '默认分组';
  bool _quickRecord = false;
  bool _periodicReminder = false;
  bool _missedReminder = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  String? _reminderFrequency = '每天';
  List<CustomAttribute> _attributes = [];

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
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppTheme.defaultPadding),
                  child: Column(
                    children: [
                      // 事件名称和图标部分
                      EventNameSection(
                        nameController: _nameController,
                        selectedIcon: _selectedIcon,
                        selectedEmoji: _selectedEmoji,
                        selectedImage: _selectedImage,
                        onIconChanged: (icon) {
                          setState(() {
                            _selectedIcon = icon;
                            _selectedEmoji = null;
                            _selectedImage = null;
                          });
                        },
                        onEmojiSelected: (emoji) {
                          setState(() {
                            _selectedEmoji = emoji;
                            _selectedIcon = null;
                            _selectedImage = null;
                          });
                        },
                        onImageSelected: (image) {
                          setState(() {
                            _selectedImage = image;
                            _selectedIcon = null;
                            _selectedEmoji = null;
                          });
                        },
                      ),
                      const SizedBox(height: AppTheme.defaultPadding),

                      // 基本属性部分
                      BasicProperties(
                        selectedGroup: _selectedGroup,
                        quickRecord: _quickRecord,
                        onGroupChanged: (group) {
                          setState(() => _selectedGroup = group);
                        },
                        onQuickRecordChanged: (value) {
                          setState(() => _quickRecord = value);
                        },
                      ),
                      const SizedBox(height: AppTheme.defaultPadding),

                      // 自定义属性部分
                      CustomAttributes(
                        onAttributesChanged: (attributes) {
                          setState(() => _attributes = attributes);
                        },
                      ),
                      const SizedBox(height: AppTheme.defaultPadding),

                      // 提醒设置部分
                      ReminderSettings(
                        eventName: _nameController.text,
                        periodicReminder: _periodicReminder,
                        missedReminder: _missedReminder,
                        reminderTime: _reminderTime,
                        reminderFrequency: _reminderFrequency ?? '每天',
                        onPeriodicReminderChanged: (value) {
                          setState(() => _periodicReminder = value);
                        },
                        onMissedReminderChanged: (value) {
                          setState(() => _missedReminder = value);
                        },
                        onReminderTimeChanged: (time) {
                          setState(() => _reminderTime = time);
                        },
                        onReminderFrequencyChanged: (frequency) {
                          setState(() => _reminderFrequency = frequency);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.defaultPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          Row(
            children: [
              // 预设为模版按钮
              ElevatedButton.icon(
                onPressed: _saveAsTemplate,
                icon: const Icon(Icons.save_alt),
                label: const Text('预设为模版'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.defaultPadding,
                    vertical: AppTheme.smallPadding,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.defaultPadding),
              // 保存按钮
              ElevatedButton(
                onPressed: _saveEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.defaultPadding,
                    vertical: AppTheme.smallPadding,
                  ),
                ),
                child: const Text('保存'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _saveEvent() {
    // 验证必填字段
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入事件名称')),
      );
      return;
    }

    try {
      // 创建事件对象
      final event = Event(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        icon: _selectedIcon,
        emoji: _selectedEmoji,
        imagePath: _selectedImage?.path,
        category: _selectedGroup,
        quickRecord: _quickRecord,
        attributes: _attributes,
        lastOccurrence: null,
      );

      // 保存事件
      EventService().saveEvent(event);

      // 返回主页
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败：$e')),
      );
    }
  }

  // 保存为模版
  void _saveAsTemplate() async {
    // 验证必填字段
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入事件名称')),
      );
      return;
    }

    if (_selectedGroup.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择分组')),
      );
      return;
    }

    try {
      // 创建模版对象
      final template = EventTemplate(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        group: _selectedGroup,
        icon: _selectedIcon,
        emoji: _selectedEmoji,
        imagePath: _selectedImage?.path,
        quickRecord: _quickRecord,
        periodicReminder: _periodicReminder,
        missedReminder: _missedReminder,
        reminderTime: {
          'hour': _reminderTime.hour,
          'minute': _reminderTime.minute,
        },
        reminderFrequency: _reminderFrequency,
        attributes: _attributes,
      );

      // 保存模版
      final templateService = TemplateService();
      await templateService.saveTemplate(template);

      // 显示成功提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已将"${_nameController.text}"保存为模版'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(AppTheme.defaultPadding),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      // 显示错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存模版失败：$e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(AppTheme.defaultPadding),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  // 示属性详情设置表单
  void _showAttributeDetailSheet(AttributeType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AttributeDetailSheet(
        type: type,
        onSave: (attribute) {
          setState(() {
            _attributes.add(attribute);
          });
          Navigator.pop(context);

          // 显示成功提示
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '已添加${_getAttributeTypeLabel(type)}属性：${_attributeNameController.text}',
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(AppTheme.defaultPadding),
            ),
          );
        },
      ),
    );
  }

  // 获取属性类型标签
  String _getAttributeTypeLabel(AttributeType type) {
    switch (type) {
      case AttributeType.text:
        return '文本';
      case AttributeType.number:
        return '数值';
      case AttributeType.toggle:
        return '开关';
      case AttributeType.singleChoice:
        return '单选';
      case AttributeType.multipleChoice:
        return '多选';
      case AttributeType.date:
        return '日期';
      default:
        return '';
    }
  }
}
