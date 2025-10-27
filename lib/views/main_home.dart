import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_buddy_app/view_models/theme_provider.dart';
import 'home.dart';
import 'study_materials/study_materials.dart';
import 'deadlines/deadlines.dart';

class MainHome extends StatefulWidget {
  const MainHome({super.key});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> with TickerProviderStateMixin {
  int _currentIndex = 0;
  final List<Widget> _pages = const [Home(), StudyMaterials(), Deadlines()];

  void _onItemTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.isDarkMode;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: _buildModernNavBar(theme, isDark),
    );
  }

  Widget _buildModernNavBar(ThemeProvider theme, bool isDark) {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.menu_book_rounded, 'label': 'Study'},
      {'icon': Icons.alarm_rounded, 'label': 'Deadlines'},
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        color: isDark
            ? const Color(0xFF0C1B1F).withOpacity(0.95)
            : Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (index) {
                final isActive = _currentIndex == index;
                final item = items[index];
        
                return GestureDetector(
                  onTap: () => _onItemTapped(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutQuad,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? theme.bannerStart.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: isActive ? 36 : 30,
                          width: isActive ? 36 : 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive
                                ? theme.bannerStart.withOpacity(0.2)
                                : Colors.transparent,
                            boxShadow: isActive
                                ? [
                                    // BoxShadow(
                                    //   color: theme.bannerStart.withOpacity(0.4),
                                    //   blurRadius: 10,
                                    //   spreadRadius: 1,
                                    // )
                                  ]
                                : [],
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            size: isActive ? 22 : 22,
                            color: isActive
                                ? theme.bannerStart
                                : theme.subTextColor.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 5),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: TextStyle(
                            color: isActive
                                ? theme.bannerStart
                                : theme.subTextColor.withOpacity(0.7),
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.w400,
                            fontSize: 12,
                          ),
                          child: Text(item['label'] as String),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
