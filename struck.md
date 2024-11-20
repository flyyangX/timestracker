lib/
├── main.dart               // 应用程序入口文件
├── app.dart                // 应用程序根组件（通常是 MaterialApp 或 CupertinoApp）
├── routes/                 // 路由相关文件
│   ├── routes.dart         // 路由表
│   ├── route_names.dart    // 路由名称常量
├── screens/                // 页面组件（每个页面一个文件夹）
│   ├── home/               // 主页
│   │   ├── home_screen.dart
│   │   ├── home_view_model.dart
│   │   ├── home_widgets.dart
│   ├── login/
│       ├── login_screen.dart
│       ├── login_view_model.dart
│       ├── login_widgets.dart
├── widgets/                // 通用的独立小组件
│   ├── custom_button.dart
│   ├── loading_indicator.dart
├── models/                 // 数据模型（通常配合 JSON 和后端接口使用）
│   ├── user_model.dart
│   ├── product_model.dart
├── services/               // 网络请求或业务逻辑
│   ├── api_service.dart
│   ├── auth_service.dart
├── utils/                  // 工具类和常量
│   ├── constants.dart      // 应用中常量
│   ├── helpers.dart        // 工具函数
├── themes/                 // 主题相关文件
│   ├── app_theme.dart
│   ├── light_theme.dart
│   ├── dark_theme.dart
├── localization/           // 国际化支持
│   ├── app_localizations.dart
│   ├── en.json
│   ├── zh.json
├── providers/              // 状态管理（如使用 Provider、Riverpod 等）
│   ├── theme_provider.dart
│   ├── user_provider.dart
└── assets/                 // 静态资源文件夹（在项目根目录）
    ├── images/
    ├── fonts/
    ├── translations/