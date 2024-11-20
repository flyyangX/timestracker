import 'package:flutter/material.dart';
import '../../../themes/app_theme.dart';
import 'icon_picker.dart';
import 'dart:io';

class EventNameSection extends StatelessWidget {
  final TextEditingController nameController;
  final IconData? selectedIcon;
  final String? selectedEmoji;
  final File? selectedImage;
  final Function(IconData)? onIconChanged;
  final Function(String)? onEmojiSelected;
  final Function(File)? onImageSelected;

  const EventNameSection({
    super.key,
    required this.nameController,
    this.selectedIcon,
    this.selectedEmoji,
    this.selectedImage,
    this.onIconChanged,
    this.onEmojiSelected,
    this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppTheme.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.defaultPadding),
        child: Row(
          children: [
            // 图标选择按钮
            InkWell(
              onTap: () => _showIconPicker(context),
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppTheme.gradientStart,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: _buildIcon(),
                ),
              ),
            ),
            const SizedBox(width: AppTheme.defaultPadding),
            // 事件名称输入框
            Expanded(
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: '输入事件名称',
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontSize: 18,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建图标显示
  Widget _buildIcon() {
    if (selectedImage != null) {
      return ClipOval(
        child: SizedBox(
          width: 48,
          height: 48,
          child: Image.file(
            selectedImage!,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (selectedEmoji != null) {
      return FittedBox(
        fit: BoxFit.contain,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            selectedEmoji!,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      );
    } else {
      return Icon(
        selectedIcon ?? Icons.event,
        color: AppTheme.primaryColor,
        size: 24,
      );
    }
  }

  void _showIconPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => IconPicker(
        selectedIcon: selectedIcon ?? Icons.event,
        selectedEmoji: selectedEmoji,
        selectedImage: selectedImage,
        onIconSelected: onIconChanged,
        onEmojiSelected: onEmojiSelected,
        onImageSelected: onImageSelected,
      ),
    );
  }
}
