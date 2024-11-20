import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/new_event_screen.dart';
import '../screens/custom_event/custom_event_screen.dart';
import 'route_names.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const HomePage());

      case RouteNames.newEvent:
        return MaterialPageRoute(builder: (_) => const NewEventScreen());

      case RouteNames.customEvent:
        return MaterialPageRoute(builder: (_) => const CustomEventScreen());

      // TODO: 添加其他路由

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
