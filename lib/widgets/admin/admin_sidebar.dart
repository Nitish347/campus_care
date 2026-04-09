import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Data class for sidebar navigation items
class SidebarItem {
  final IconData icon;
  final String title;
  final String? route;
  final VoidCallback? onTap;
  final bool isSelected;

  const SidebarItem({
    required this.icon,
    required this.title,
    this.route,
    this.onTap,
    this.isSelected = false,
  });
}

/// Data class for sidebar sections
class SidebarSection {
  final String title;
  final List<SidebarItem> items;

  const SidebarSection({required this.title, required this.items});
}

/// Full-width sidebar for desktop layout
class AdminSidebar extends StatelessWidget {
  final List<SidebarSection> sections;
  final String? headerTitle;
  final Widget? headerExtra;

  const AdminSidebar({
    super.key,
    required this.sections,
    this.headerTitle,
    this.headerExtra,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : const Color(0xFF1E293B),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              children: [
                for (final section in sections) ...[
                  _SidebarSectionHeader(title: section.title),
                  const SizedBox(height: 4),
                  for (final item in section.items) _SidebarNavItem(item: item),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            child: Text(
              'Campus Care v1.0',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Drawer version (for mobile/tablet)
class AdminDrawer extends StatelessWidget {
  final List<SidebarSection> sections;
  final String? headerTitle;

  const AdminDrawer({
    super.key,
    required this.sections,
    this.headerTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 260,
      backgroundColor: const Color(0xFF1E293B),
      child: AdminSidebar(sections: sections, headerTitle: headerTitle),
    );
  }
}

class _SidebarSectionHeader extends StatelessWidget {
  final String title;

  const _SidebarSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  final SidebarItem item;

  const _SidebarNavItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        gradient: item.isSelected
            ? const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: item.onTap ??
              (item.route != null ? () => Get.toNamed(item.route!) : null),
          hoverColor: Colors.white.withValues(alpha: 0.07),
          splashColor: Colors.white.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                // Left accent bar for selected
                if (item.isSelected)
                  Container(
                    width: 3,
                    height: 18,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )
                else
                  const SizedBox(width: 13),
                Icon(
                  item.icon,
                  color: item.isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.55),
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      color: item.isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.65),
                      fontWeight: item.isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                if (item.isSelected)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
