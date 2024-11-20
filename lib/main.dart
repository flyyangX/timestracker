import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'themes/app_theme.dart';
import 'routes/routes.dart';
import 'routes/route_names.dart';
import 'providers/event_provider.dart';
import 'providers/template_provider.dart';
import 'package:device_preview/device_preview.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) =>
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => EventProvider()),
            ChangeNotifierProvider(create: (_) => TemplateProvider()),
          ],
          child: const TimesTrackerApp(),
        ),
    ),
  );
}

class TimesTrackerApp extends StatelessWidget {
  const TimesTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TimesTracker',
      theme: AppTheme.getThemeData(),
      initialRoute: RouteNames.home,
      onGenerateRoute: AppRouter.generateRoute,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
    );
  }
}
