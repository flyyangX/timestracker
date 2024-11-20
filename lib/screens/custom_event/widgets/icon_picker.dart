import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../themes/app_theme.dart';

class IconPicker extends StatefulWidget {
  final IconData selectedIcon;
  final String? selectedEmoji;
  final File? selectedImage;
  final Function(IconData)? onIconSelected;
  final Function(String)? onEmojiSelected;
  final Function(File)? onImageSelected;

  const IconPicker({
    super.key,
    required this.selectedIcon,
    this.selectedEmoji,
    this.selectedImage,
    this.onIconSelected,
    this.onEmojiSelected,
    this.onImageSelected,
  });

  @override
  State<IconPicker> createState() => _IconPickerState();
}

class _IconPickerState extends State<IconPicker>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();
  File? _customIconImage;

  // 预设图标列表
  final List<IconData> _presetIcons = [
    Icons.local_cafe, // 咖啡
    Icons.restaurant, // 餐厅
    Icons.sports_basketball, // 运动
    Icons.book, // 阅读
    Icons.work, // 工作
    Icons.school, // 学习
    Icons.movie, // 电影
    Icons.music_note, // 音乐
    Icons.fitness_center, // 健身
    Icons.shopping_cart, // 购物
    Icons.pets, // 宠物
    Icons.favorite, // 爱好
    Icons.directions_run, // 跑步
    Icons.brush, // 绘画
    Icons.computer, // 电脑
    Icons.videogame_asset, // 游戏
    Icons.local_hospital, // 医疗
    Icons.home, // 家务
    Icons.flight, // 旅行
    Icons.attach_money, // 财务
  ];

  // 完整的emoji库
  final List<String> _emojiIcons = [
    // 表情符号
    '😀', '😃', '😄', '😁', '😅', '😂', '🤣', '😊', '😇', '🙂', '🙃', '😉',
    '😌', '😍',
    '🥰', '😘', '😗', '😙', '😚', '😋', '😛', '😝', '😜', '🤪', '🤨', '🧐',
    '🤓', '😎',
    // 手势
    '👍', '👎', '👊', '✊', '🤛', '🤜', '🤝', '👏', '🙌', '👐', '🤲', '🤝', '🙏',
    '✌️',
    // 动物
    '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯', '🦁', '🐮',
    '🐷', '🐸',
    // 食物
    '🍎', '🍐', '🍊', '🍋', '🍌', '🍉', '🍇', '🍓', '🍈', '🍒', '🍑', '🥭',
    '🍍', '🥥',
    // 运动
    '⚽️', '🏀', '🏈', '⚾', '🥎', '🎾', '🏐', '🏉', '🎱', '🏓', '🏸', '🏒', '🏑',
    '🥅',
    // 活动
    '🎭', '🎨', '🎪', '🎤', '🎧', '🎼', '🎹', '🥁', '🎷', '🎺', '🎸', '🪕',
    '🎻', '🎲',
    // 自然
    '🌸', '💮', '🏵️', '🌹', '🥀', '🌺', '🌻', '🌼', '🌷', '🌱', '🌲', '🌳',
    '🌴', '🌵',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPresetIconsGrid(),
                _buildEmojiIconsGrid(),
                _buildUploadSection(),
              ],
            ),
          ),
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
          const Text(
            '选择图标',
            style: TextStyle(
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

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: AppTheme.textSecondaryColor,
        indicatorColor: AppTheme.primaryColor,
        tabs: const [
          Tab(text: '预设'),
          Tab(text: 'Emoji'),
          Tab(text: '上传'),
        ],
      ),
    );
  }

  Widget _buildPresetIconsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppTheme.defaultPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: AppTheme.defaultPadding,
        mainAxisSpacing: AppTheme.defaultPadding,
      ),
      itemCount: _presetIcons.length,
      itemBuilder: (context, index) {
        final icon = _presetIcons[index];
        final isSelected = widget.selectedIcon == icon;
        return InkWell(
          onTap: () {
            if (widget.onIconSelected != null) {
              widget.onIconSelected!(icon);
            }
            Navigator.pop(context);
          },
          child: Container(
            decoration: BoxDecoration(
              color:
                  isSelected ? AppTheme.primaryColor : AppTheme.gradientStart,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppTheme.primaryColor,
                size: 28,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmojiIconsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppTheme.defaultPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: AppTheme.smallPadding,
        mainAxisSpacing: AppTheme.smallPadding,
      ),
      itemCount: _emojiIcons.length,
      itemBuilder: (context, index) {
        final emoji = _emojiIcons[index];
        final isSelected = widget.selectedEmoji == emoji;
        return InkWell(
          onTap: () {
            if (widget.onEmojiSelected != null) {
              widget.onEmojiSelected!(emoji);
            }
            Navigator.pop(context);
          },
          child: Container(
            decoration: BoxDecoration(
              color:
                  isSelected ? AppTheme.primaryColor : AppTheme.gradientStart,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    emoji,
                    style: TextStyle(
                      fontSize: 24,
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUploadSection() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.defaultPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_customIconImage != null || widget.selectedImage != null) ...[
            Container(
              width: 120,
              height: 120,
              margin: const EdgeInsets.only(bottom: AppTheme.defaultPadding),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.file(
                  _customIconImage ?? widget.selectedImage!,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (widget.onImageSelected != null &&
                    _customIconImage != null) {
                  widget.onImageSelected!(_customIconImage!);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.defaultPadding * 2,
                  vertical: AppTheme.defaultPadding,
                ),
              ),
              child: const Text('确认使用'),
            ),
            const SizedBox(height: AppTheme.defaultPadding),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildUploadButton(
                icon: Icons.photo_library,
                label: '从相册选择',
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              const SizedBox(width: AppTheme.defaultPadding),
              _buildUploadButton(
                icon: Icons.camera_alt,
                label: '拍摄照片',
                onTap: () => _pickImage(ImageSource.camera),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.defaultPadding * 2,
          vertical: AppTheme.defaultPadding,
        ),
        decoration: BoxDecoration(
          color: AppTheme.gradientStart,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (pickedFile != null) {
        setState(() {
          _customIconImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('选择图片时出现错误'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
