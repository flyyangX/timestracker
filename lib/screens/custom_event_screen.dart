// 显示属性详情设置表单
void _showAttributeDetailSheet(AttributeType type) {
  // ... 其他代码保持不变 ...

  // 修改 SnackBar 部分
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
          '已添加${_getAttributeTypeLabel(type)}属性：${_attributeNameController.text}'),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(AppTheme.defaultPadding),
    ),
  );

  // 错误提示部分也需要修改
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('请填写完整信息'),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(AppTheme.defaultPadding),
    ),
  );
}
