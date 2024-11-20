# Custom Event Module Structure

## 目录结构
lib/screens/custom_event/
├── INS.md                         # 本文档：模块说明和结构文档
├── models/                        # 数据模型
│   ├── attribute_type.dart        # 属性类型枚举
│   └── custom_attribute.dart      # 自定义属性类
├── widgets/                       # UI组件
│   ├── event_name_section.dart    # 事件名称和图标部分
│   ├── basic_properties.dart      # 基本属性部分（分组和快速记录）
│   ├── custom_attributes.dart     # 自定义属性部分
│   ├── reminder_settings.dart     # 提醒设置部分
│   └── icon_picker.dart          # 图标选择器
└── custom_event_screen.dart       # 新建事件主页面

## 组件说明

### Models
- `attribute_type.dart`: 定义属性类型枚举
- `custom_attribute.dart`: 定义自定义属性类

### Widgets
- `event_name_section.dart`: 事件名称输入和图标选择
- `basic_properties.dart`: 分组选择和快速记录开关
- `custom_attributes.dart`: 自定义属性列表和添加功能
- `reminder_settings.dart`: 定期提醒和未完成提醒设置
- `icon_picker.dart`: 图标选择器（预设图标和自定义图片）

## 更新记录

### 2024-03-xx - 初始化结构
- 创建基础目录结构
- 添加模型文件
- 创建组件文件

### 2024-03-xx - 重构组件结构
- 按功能模块拆分组件
- 优化组件间的通信
- 实现平滑的动画效果