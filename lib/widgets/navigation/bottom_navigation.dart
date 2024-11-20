import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';
import 'navigation_item.dart';

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final List<NavigationItem> items;

  const BottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.cardBorderRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        backgroundColor: Colors.transparent,
        elevation: 0,
        onDestinationSelected: onDestinationSelected,
        destinations: items
            .map((item) => NavigationDestination(
                  icon: Icon(
                    item.icon,
                    color: AppTheme.iconInactiveColor,
                  ),
                  selectedIcon: Icon(
                    item.activeIcon,
                    color: AppTheme.primaryColor,
                  ),
                  label: item.label,
                ))
            .toList(),
      ),
    );
  }
}
