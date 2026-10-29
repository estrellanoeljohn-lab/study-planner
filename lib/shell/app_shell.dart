import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: kDivider, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (i) => navigationShell.goBranch(
            i,
            initialLocation: i == navigationShell.currentIndex,
          ),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.today_outlined),
              selectedIcon: Icon(Icons.today, color: kPrimary),
              label: 'Today',
            ),
            NavigationDestination(
              icon: const Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book, color: kPrimary),
              label: 'Courses',
            ),
            NavigationDestination(
              icon: const Icon(Icons.timer_outlined),
              selectedIcon: Icon(Icons.timer, color: kPrimary),
              label: 'Focus',
            ),
            NavigationDestination(
              icon: const Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart, color: kPrimary),
              label: 'Stats',
            ),
          ],
        ),
      ),
    );
  }
}
