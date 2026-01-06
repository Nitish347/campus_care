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
import 'package:campus_care/widgets/common/institute_context_indicator.dart';

import '../../controllers/admin_controller.dart';
import '../../controllers/admin/admin_auth_controller.dart';
import '../../controllers/theme_controller.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1200;
    final isTablet = size.width > 800 && size.width <= 1200;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.school_rounded,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Campus Care Admin'),
          ],
        ),
        actions: [
          // Institute Context Indicator (shows when super admin is managing an institute)
          GetBuilder<ThemeController>(
            builder: (themeController) => IconButton(
              icon: Icon(
                theme.brightness == Brightness.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: () => themeController.toggleTheme(),
              tooltip: 'Toggle theme',
            ),
          ),
          const InstituteContextIndicator(),
          IconButton(
            onPressed: () {
              // TODO: Implement notifications
            },
            icon: const Icon(Icons.notifications_outlined),
          ),
          const SizedBox(width: 8),
          Obx(() => PopupMenuButton<String>(
                icon: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    authController.currentAdmin?.fullName
                            .substring(0, 1)
                            .toUpperCase() ??
                        'A',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Row(
                      children: [
                        Icon(Icons.person, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        const Text('Profile'),
                      ],
                    ),
                    onTap: () {
                      Get.toNamed(AppRoutes.adminProfile);
                    },
                  ),
                  PopupMenuItem(
                    child: Row(
                      children: [
                        Icon(Icons.settings, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        const Text('Settings'),
                      ],
                    ),
                    onTap: () {
                      // TODO: Navigate to settings
                    },
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: theme.colorScheme.error),
                        const SizedBox(width: 8),
                        const Text('Logout'),
                      ],
                    ),
                    onTap: () => authController.logout(),
                  ),
                ],
              )),
          const SizedBox(width: 16),
        ],
      ),
      drawer: isDesktop ? null : _buildDrawer(context),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(context),
          Expanded(
            child: _buildMainContent(context, isDesktop, isTablet),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: _buildSidebarContent(context),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: _buildSidebarContent(context),
    );
  }

  Widget _buildSidebarContent(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: 24),

        // Dashboard Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                Icons.dashboard_rounded,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Dashboard',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              _buildSidebarItem(
                context,
                icon: Icons.home_outlined,
                title: 'Home',
                isSelected: true,
                onTap: () {},
              ),
              const SizedBox(height: 8),
              _buildSidebarSection('Student Management'),
              _buildSidebarItem(
                context,
                icon: Icons.people_outlined,
                title: 'Student List',
                onTap: () => Get.toNamed(AppRoutes.studentList),
              ),
              _buildSidebarItem(
                context,
                icon: Icons.person_add_outlined,
                title: 'Add Student',
                onTap: () => Get.toNamed(AppRoutes.addStudent),
              ),
              const SizedBox(height: 16),
              _buildSidebarSection('Staff Management'),
              _buildSidebarItem(
                context,
                icon: Icons.person_outlined,
                title: 'Teacher List',
                onTap: () => Get.toNamed(AppRoutes.teacherList),
              ),
              _buildSidebarItem(
                context,
                icon: Icons.person_add_outlined,
                title: 'Add Teacher',
                onTap: () => Get.toNamed(AppRoutes.addTeacher),
              ),
              _buildSidebarItem(
                context,
                icon: Icons.admin_panel_settings_outlined,
                title: 'Admin List',
                onTap: () => Get.toNamed(AppRoutes.adminList),
              ),
              const SizedBox(height: 16),
              _buildSidebarSection('Academic Management'),
              _buildSidebarItem(
                context,
                icon: Icons.class_outlined,
                title: 'Classes & Subjects',
                onTap: () => Get.toNamed(AppRoutes.classManagement),
              ),
              _buildSidebarItem(
                context,
                icon: Icons.schedule_outlined,
                title: 'Timetable',
                onTap: () => Get.toNamed(AppRoutes.timetable),
              ),
              _buildSidebarItem(
                context,
                icon: Icons.how_to_reg_outlined,
                title: 'Attendance',
                onTap: () => Get.toNamed(AppRoutes.adminAttendance),
              ),
              _buildSidebarItem(
                context,
                icon: Icons.how_to_reg_outlined,
                title: 'Attendance',
                onTap: () => Get.toNamed(AppRoutes.adminAttendance),
              ),
              const SizedBox(height: 16),
              _buildSidebarSection('Examination'),
              _buildSidebarItem(
                context,
                icon: Icons.quiz_outlined,
                title: 'Exam Scheduler',
                onTap: () => Get.toNamed(AppRoutes.examScheduler),
              ),
              const SizedBox(height: 16),
              _buildSidebarSection('Fee Management'),
              _buildSidebarItem(
                context,
                icon: Icons.payment_outlined,
                title: 'Fee Management',
                onTap: () => Get.toNamed(AppRoutes.feeManagement),
              ),
              const SizedBox(height: 16),
              _buildSidebarSection('Health & Medical'),
              _buildSidebarItem(
                context,
                icon: Icons.medical_services_outlined,
                title: 'Medical Records',
                onTap: () => Get.toNamed(AppRoutes.medicalDashboard),
              ),
              const SizedBox(height: 16),
              _buildSidebarSection('Communication'),
              _buildSidebarItem(
                context,
                icon: Icons.announcement_outlined,
                title: 'Notices & Events',
                onTap: () => Get.toNamed(AppRoutes.noticeManagement),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSidebarItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(
      BuildContext context, bool isDesktop, bool isTablet) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: ResponsivePadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Obx(() => Text(
                  'Welcome back, ${Get.find<AuthController>().currentAdmin?.fullName ?? 'Admin'}! 👋',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                )),
            const SizedBox(height: 8),
            Text(
              'Here\'s what\'s happening at your school today',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),

            // Quick Stats
            SectionHeader(title: 'Quick Stats'),
            const SizedBox(height: 12),
            Obx(() {
              final stats = Get.find<AdminController>().dashboardStats;
              return ResponsiveGrid(
                childAspectRatio: kIsWeb ? 1.6 : 1.1,
                children: [
                  StatCard(
                    icon: Icons.people_outlined,
                    title: 'Total Students',
                    value: stats['students']?.toString() ?? '0',
                    color: theme.colorScheme.primary,
                  ),
                  StatCard(
                    icon: Icons.person_outlined,
                    title: 'Total Teachers',
                    value: stats['teachers']?.toString() ?? '0',
                    color: theme.colorScheme.secondary,
                  ),
                  StatCard(
                    icon: Icons.class_outlined,
                    title: 'Total Classes',
                    value: '24', // TODO: Implement Class stats API
                    color: Colors.purple,
                  ),
                  StatCard(
                    icon: Icons.event_outlined,
                    title: 'Today\'s Events',
                    value: '0', // TODO: Implement Events stats API
                    color: Colors.orange,
                  ),
                ],
              );
            }),

            const SizedBox(height: 24),

            // Quick Access
            SectionHeader(title: 'Quick Access'),
            const SizedBox(height: 12),
            ResponsiveGrid(
              childAspectRatio: kIsWeb ? 1.1 : 0.95,
              children: [
                DashboardCard(
                  icon: Icons.people_outlined,
                  title: 'Student Management',
                  subtitle: 'Manage students',
                  onTap: () => Get.toNamed(AppRoutes.studentList),
                  iconColor: theme.colorScheme.primary,
                ),
                DashboardCard(
                  icon: Icons.person_outlined,
                  title: 'Teacher Management',
                  subtitle: 'Manage teachers',
                  onTap: () => Get.toNamed(AppRoutes.teacherList),
                  iconColor: theme.colorScheme.secondary,
                ),
                DashboardCard(
                  icon: Icons.class_outlined,
                  title: 'Classes & Subjects',
                  subtitle: 'Manage classes',
                  onTap: () => Get.toNamed(AppRoutes.classManagement),
                  iconColor: Colors.purple,
                ),
                DashboardCard(
                  icon: Icons.schedule_outlined,
                  title: 'Timetable',
                  subtitle: 'View schedule',
                  onTap: () => Get.toNamed(AppRoutes.timetable),
                  iconColor: Colors.orange,
                ),
                DashboardCard(
                  icon: Icons.how_to_reg_outlined,
                  title: 'Attendance',
                  subtitle: 'Manage attendance',
                  onTap: () => Get.toNamed(AppRoutes.adminAttendance),
                  iconColor: Colors.teal,
                ),
                DashboardCard(
                  icon: Icons.how_to_reg_outlined,
                  title: 'Attendance',
                  subtitle: 'Manage attendance',
                  onTap: () => Get.toNamed(AppRoutes.adminAttendance),
                  iconColor: Colors.teal,
                ),
                DashboardCard(
                  icon: Icons.quiz_outlined,
                  title: 'Examinations',
                  subtitle: 'Manage exams',
                  onTap: () => Get.toNamed(AppRoutes.examScheduler),
                  iconColor: Colors.red,
                ),
                DashboardCard(
                  icon: Icons.payment_outlined,
                  title: 'Fee Management',
                  subtitle: 'Manage fees',
                  onTap: () => Get.toNamed(AppRoutes.feeManagement),
                  iconColor: Colors.green,
                ),
                DashboardCard(
                  icon: Icons.medical_services_outlined,
                  title: 'Medical Records',
                  subtitle: 'Health records',
                  onTap: () => Get.toNamed(AppRoutes.medicalDashboard),
                  iconColor: Colors.pink,
                ),
                DashboardCard(
                  icon: Icons.announcement_outlined,
                  title: 'Notices & Events',
                  subtitle: 'Announcements',
                  onTap: () => Get.toNamed(AppRoutes.noticeManagement),
                  iconColor: Colors.teal,
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
