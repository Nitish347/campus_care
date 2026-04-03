import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/widgets/cards/stat_card.dart';
import 'package:campus_care/widgets/cards/dashboard_card.dart';
import 'package:campus_care/widgets/responsive/responsive_grid.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/common/section_header.dart';
import 'package:campus_care/widgets/admin/admin_app_bar.dart';
import 'package:campus_care/widgets/admin/admin_sidebar.dart';

import '../../controllers/admin_controller.dart';
import '../../controllers/class_controller.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  // Build sidebar sections (reused for both sidebar and drawer)
  List<SidebarSection> _buildSidebarSections() {
    return [
      SidebarSection(
        title: 'Main',
        items: [
          SidebarItem(
            icon: Icons.home_rounded,
            title: 'Home',
            isSelected: true,
            onTap: () {},
          ),
        ],
      ),
      SidebarSection(
        title: 'Student Management',
        items: [
          SidebarItem(
            icon: Icons.people_rounded,
            title: 'Student List',
            onTap: () => Get.toNamed(AppRoutes.studentList),
          ),
          SidebarItem(
            icon: Icons.person_add_rounded,
            title: 'Add Student',
            onTap: () => Get.toNamed(AppRoutes.addStudent),
          ),
        ],
      ),
      SidebarSection(
        title: 'Staff Management',
        items: [
          SidebarItem(
            icon: Icons.badge_rounded,
            title: 'Teacher List',
            onTap: () => Get.toNamed(AppRoutes.teacherList),
          ),
          SidebarItem(
            icon: Icons.person_add_alt_1_rounded,
            title: 'Add Teacher',
            onTap: () => Get.toNamed(AppRoutes.addTeacher),
          ),
          SidebarItem(
            icon: Icons.admin_panel_settings_rounded,
            title: 'Admin List',
            onTap: () => Get.toNamed(AppRoutes.adminList),
          ),
        ],
      ),
      SidebarSection(
        title: 'Academic',
        items: [
          SidebarItem(
            icon: Icons.class_rounded,
            title: 'Classes',
            onTap: () => Get.toNamed(AppRoutes.classManagement),
          ),
          SidebarItem(
            icon: Icons.book_rounded,
            title: 'Subjects',
            onTap: () => Get.toNamed(AppRoutes.subjectManagement),
          ),
          SidebarItem(
            icon: Icons.schedule_rounded,
            title: 'Timetable',
            onTap: () => Get.toNamed(AppRoutes.timetable),
          ),
          SidebarItem(
            icon: Icons.how_to_reg_rounded,
            title: 'Attendance',
            onTap: () => Get.toNamed(AppRoutes.adminAttendance),
          ),
          SidebarItem(
            icon: Icons.restaurant_menu_rounded,
            title: 'Lunch Management',
            onTap: () => Get.toNamed(AppRoutes.adminLunchManagement),
          ),
          SidebarItem(
            icon: Icons.directions_bus_rounded,
            title: 'Transport',
            onTap: () => Get.toNamed(AppRoutes.adminTransportManagement),
          ),
          SidebarItem(
            icon: Icons.assignment_rounded,
            title: 'Homework',
            onTap: () => Get.toNamed(AppRoutes.adminHomework),
          ),
          SidebarItem(
            icon: Icons.assignment_rounded,
            title: 'Examinations',
            onTap: () => Get.toNamed(AppRoutes.adminExaminations),
          ),
        ],
      ),
      SidebarSection(
        title: 'Communication',
        items: [
          SidebarItem(
            icon: Icons.campaign_rounded,
            title: 'Notices & Events',
            onTap: () => Get.toNamed(AppRoutes.noticeManagement),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final classController = Get.find<ClassController>();
    classController.fetchClasses();

    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1200;
    final isTablet = size.width > 800 && size.width <= 1200;
    final showDrawerButton = !isDesktop;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AdminAppBar(
        showMenuButton: showDrawerButton,
      ),
      drawer: showDrawerButton
          ? AdminDrawer(sections: _buildSidebarSections())
          : null,
      body: Row(
        children: [
          if (isDesktop) AdminSidebar(sections: _buildSidebarSections()),
          Expanded(
            child: _buildMainContent(context, isDesktop, isTablet),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(
      BuildContext context, bool isDesktop, bool isTablet) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Banner
          Obx(() {
            final adminName =
                Get.find<AuthController>().currentAdmin?.fullName ?? 'Admin';
            return _WelcomeBanner(adminName: adminName, isDark: isDark);
          }),

          // Content
          ResponsivePadding(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 28),

                // Quick Stats
                SectionHeader(
                  title: 'Quick Stats',
                  subtitle: 'Overview of your institution',
                ),
                const SizedBox(height: 16),
                Obx(() {
                  final stats = Get.find<AdminController>().dashboardStats;
                  return ResponsiveGrid(
                    childAspectRatio: kIsWeb ? 1.6 : 1.1,
                    children: [
                      StatCard(
                        icon: Icons.people_rounded,
                        title: 'Total Students',
                        value: stats['students']?.toString() ?? '0',
                        color: const Color(0xFF2563EB),
                      ),
                      StatCard(
                        icon: Icons.badge_rounded,
                        title: 'Total Teachers',
                        value: stats['teachers']?.toString() ?? '0',
                        color: const Color(0xFF059669),
                      ),
                      StatCard(
                        icon: Icons.class_rounded,
                        title: 'Total Classes',
                        value: '24',
                        color: const Color(0xFF7C3AED),
                      ),
                      StatCard(
                        icon: Icons.event_rounded,
                        title: "Today's Events",
                        value: '0',
                        color: const Color(0xFFF59E0B),
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 32),

                // Quick Access
                SectionHeader(
                  title: 'Quick Access',
                  subtitle: 'Navigate to key management areas',
                ),
                const SizedBox(height: 16),
                ResponsiveGrid(
                  childAspectRatio: kIsWeb ? 1.1 : 0.95,
                  children: [
                    DashboardCard(
                      icon: Icons.people_rounded,
                      title: 'Student Management',
                      subtitle: 'Manage students',
                      onTap: () => Get.toNamed(AppRoutes.studentList),
                      iconColor: const Color(0xFF2563EB),
                    ),
                    DashboardCard(
                      icon: Icons.badge_rounded,
                      title: 'Teacher Management',
                      subtitle: 'Manage teachers',
                      onTap: () => Get.toNamed(AppRoutes.teacherList),
                      iconColor: const Color(0xFF059669),
                    ),
                    DashboardCard(
                      icon: Icons.class_rounded,
                      title: 'Classes & Subjects',
                      subtitle: 'Manage classes',
                      onTap: () => Get.toNamed(AppRoutes.classManagement),
                      iconColor: const Color(0xFF7C3AED),
                    ),
                    DashboardCard(
                      icon: Icons.schedule_rounded,
                      title: 'Timetable',
                      subtitle: 'View schedule',
                      onTap: () => Get.toNamed(AppRoutes.timetable),
                      iconColor: const Color(0xFFF59E0B),
                    ),
                    DashboardCard(
                      icon: Icons.how_to_reg_rounded,
                      title: 'Attendance',
                      subtitle: 'Manage attendance',
                      onTap: () => Get.toNamed(AppRoutes.adminAttendance),
                      iconColor: const Color(0xFF0D9488),
                    ),
                    DashboardCard(
                      icon: Icons.restaurant_menu_rounded,
                      title: 'Lunch Management',
                      subtitle: 'Track student meals',
                      onTap: () => Get.toNamed(AppRoutes.adminLunchManagement),
                      iconColor: const Color(0xFF7C3AED),
                    ),
                    DashboardCard(
                      icon: Icons.directions_bus_rounded,
                      title: 'Transport',
                      subtitle: 'Manage routes & vans',
                      onTap: () =>
                          Get.toNamed(AppRoutes.adminTransportManagement),
                      iconColor: const Color(0xFF0EA5E9),
                    ),
                    DashboardCard(
                      icon: Icons.assignment_rounded,
                      title: 'Homework',
                      subtitle: 'Manage homework',
                      onTap: () => Get.toNamed(AppRoutes.adminHomework),
                      iconColor: const Color(0xFF4F46E5),
                    ),
                    DashboardCard(
                      icon: Icons.assignment_rounded,
                      title: 'Examinations',
                      subtitle: 'Manage exams & timetables',
                      onTap: () => Get.toNamed(AppRoutes.adminExaminations),
                      iconColor: const Color(0xFFE11D48),
                    ),
                    DashboardCard(
                      icon: Icons.campaign_rounded,
                      title: 'Notices & Events',
                      subtitle: 'Announcements',
                      onTap: () => Get.toNamed(AppRoutes.noticeManagement),
                      iconColor: const Color(0xFF0891B2),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Welcome banner shown at top of dashboard
class _WelcomeBanner extends StatelessWidget {
  final String adminName;
  final bool isDark;

  const _WelcomeBanner({required this.adminName, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1E293B),
                  const Color(0xFF0F172A),
                ],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E40AF),
                  Color(0xFF3B82F6),
                ],
              ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '👋',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  adminName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Here's what's happening at your school today",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.dashboard_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}
