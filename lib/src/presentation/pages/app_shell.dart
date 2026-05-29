import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../providers/navigation_provider.dart';
import 'home_page.dart';
import 'calendar_page.dart';
import 'settings_page.dart';

class AppShell extends StatelessWidget {
  const AppShell({Key? key}) : super(key: key);

  final List<Widget> _pages = const [
    HomePage(),
    CalendarPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true, // Allows pages to draw behind the translucent bottom navigation bar
      body: IndexedStack(
        index: navProvider.currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 20.0,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
            child: BottomNavigationBar(
              currentIndex: navProvider.currentIndex,
              onTap: (index) => navProvider.setIndex(index),
              backgroundColor: isDark
                  ? Colors.black.withOpacity(0.4)
                  : Colors.white.withOpacity(0.55),
              selectedItemColor: AppColors.emeraldGreen,
              unselectedItemColor: isDark ? Colors.white54 : Colors.black45,
              showSelectedLabels: true,
              showUnselectedLabels: false,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.alarm),
                  activeIcon: Icon(Icons.alarm, color: AppColors.emeraldGreen),
                  label: 'Sholat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month_outlined),
                  activeIcon: Icon(Icons.calendar_month, color: AppColors.emeraldGreen),
                  label: 'Kalender',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings, color: AppColors.emeraldGreen),
                  label: 'Pengaturan',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
