import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

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
    final sidebarColor =
        isDark ? const Color(0xFF09090B) : const Color(0xFF0F172A);

    return Container(
      width: 272,
      decoration: BoxDecoration(
        color: sidebarColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(3, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 18, 12, 10),
            child: shad.Card(
              padding: const EdgeInsets.all(12),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.06),
              borderColor: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Color(0xFF0F172A),
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          headerTitle ?? 'Campus Care',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Admin Console',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (headerExtra != null) ...[
                    const SizedBox(width: 8),
                    headerExtra!,
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
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
                color: Colors.white.withValues(alpha: 0.38),
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
      width: 272,
      backgroundColor: Colors.transparent,
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
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
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
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: item.isSelected
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: item.isSelected
              ? Colors.white.withValues(alpha: 0.18)
              : Colors.transparent,
        ),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
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
                      : Colors.white.withValues(alpha: 0.62),
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      color: item.isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.72),
                      fontWeight:
                          item.isSelected ? FontWeight.w700 : FontWeight.w500,
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
