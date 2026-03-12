import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import 'course_list_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'review_page.dart';

class AppShell extends StatefulWidget {
  final AppSettings settings;
  final ValueChanged<AppSettings> onSettingsChanged;

  const AppShell({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        settings: widget.settings,
        onOpenTab: (index) => setState(() => _index = index),
      ),
      CourseListPage(settings: widget.settings),
      const ReviewPage(),
      ProfilePage(
        settings: widget.settings,
        onSettingsChanged: widget.onSettingsChanged,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _NavItem(icon: Icons.home_rounded, label: 'Home', active: _index == 0, onTap: () => setState(() => _index = 0)),
              _NavItem(icon: Icons.menu_book_rounded, label: 'Lessons', active: _index == 1, onTap: () => setState(() => _index = 1)),
              _NavItem(icon: Icons.refresh_rounded, label: 'Review', active: _index == 2, onTap: () => setState(() => _index = 2)),
              _NavItem(icon: Icons.person_outline_rounded, label: 'Profile', active: _index == 3, onTap: () => setState(() => _index = 3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bg = active ? const Color(0xFFF0FBF7) : Colors.transparent;
    final fg = active ? const Color(0xFF6F9E92) : Theme.of(context).hintColor;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: fg),
              const SizedBox(height: 4),
              Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}
