import 'package:flutter/material.dart';
import '../../../themes/app_theme.dart';
import '../models/custom_attribute.dart';
import 'attribute_type_sheet.dart';
import 'attribute_form_sheet.dart';
import 'attribute_item.dart';

class CustomAttributes extends StatefulWidget {
  // 添加回调函数，用于通知父组件属性列表的变化
  final Function(List<CustomAttribute>)? onAttributesChanged;

  const CustomAttributes({
    super.key,
    this.onAttributesChanged,
  });

  @override
  State<CustomAttributes> createState() => _CustomAttributesState();
}

class _CustomAttributesState extends State<CustomAttributes> {
  // 属性列表
  final List<CustomAttribute> _attributes = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '自定义属性',
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
                    widget.onAttributesChanged?.call(_attributes);
                  });
                },
                children: _attributes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final attribute = entry.value;
                  return Dismissible(
                    key: ValueKey(attribute),
                    // 左滑删除
                    background: Container(
                      alignment: Alignment.centerLeft,
                      padding:
                          const EdgeInsets.only(left: AppTheme.defaultPadding),
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
                      child: const Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            '删除',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 右滑修改
                    secondaryBackground: Container(
                      alignment: Alignment.centerRight,
                      padding:
                          const EdgeInsets.only(right: AppTheme.defaultPadding),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF4CAF50), // 浅绿色
                            Color(0xFF2E7D32), // 深绿色
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius:
                            BorderRadius.circular(AppTheme.cardBorderRadius),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '修改',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.edit, color: Colors.white),
                        ],
                      ),
                    ),
                    // 支持双向滑动
                    direction: DismissDirection.horizontal,
                    // 滑动确认回调
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        // 左滑删除
                        setState(() {
                          _attributes.removeAt(index);
                          widget.onAttributesChanged?.call(_attributes);
                        });
                        // 显示撤销提示
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('已删除属性"${attribute.name}"'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin:
                                const EdgeInsets.all(AppTheme.defaultPadding),
                            action: SnackBarAction(
                              label: '撤销',
                              onPressed: () {
                                setState(() {
                                  _attributes.insert(index, attribute);
                                  widget.onAttributesChanged?.call(_attributes);
                                });
                              },
                            ),
                          ),
                        );
                        return true;
                      } else {
                        // 右滑修改
                        _showEditAttributeSheet(context, index, attribute);
                        return false;
                      }
                    },
                    child: InkWell(
                      onTap: () =>
                          _showEditAttributeSheet(context, index, attribute),
                      child: AttributeItem(
                        key: ValueKey(attribute),
                        attribute: attribute,
                        onDelete: () {
                          setState(() {
                            _attributes.removeAt(index);
                            widget.onAttributesChanged?.call(_attributes);
                          });
                        },
                      ),
                    ),
                  );
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
              // 通知父组件属性列表已更新
              widget.onAttributesChanged?.call(_attributes);
              // 显示成功提示
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('已添加属性"${attribute.name}"'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(AppTheme.defaultPadding),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            });
          },
        );
      },
    );
  }

  void _showEditAttributeSheet(
      BuildContext context, int index, CustomAttribute attribute) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AttributeFormSheet(
        type: attribute.type,
        attribute: attribute, // 传递现有属性数据
        onAttributeCreated: (updatedAttribute) {
          setState(() {
            _attributes[index] = updatedAttribute;
            widget.onAttributesChanged?.call(_attributes);
          });
          Navigator.pop(context);
          // 显示成功提示
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已更新属性"${updatedAttribute.name}"'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(AppTheme.defaultPadding),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      ),
    );
  }
}
