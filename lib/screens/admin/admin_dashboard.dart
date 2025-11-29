import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/core/routes/app_routes.dart';

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
            const Text('School Stream Admin'),
          ],
        ),
        actions: [
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
                    authController.currentUser?.name
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
                      // TODO: Navigate to profile
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
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSidebarItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: isSelected
            ? theme.colorScheme.primaryContainer
            : Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
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
    final crossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 2);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          Obx(() => Text(
                'Welcome back, ${Get.find<AuthController>().currentUser?.name ?? 'Admin'}! 👋',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )),

          Text(
            'Here\'s what\'s happening at your school today.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 32),

          // Quick Stats Cards
          Expanded(
            child: GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  context,
                  icon: Icons.people_outlined,
                  title: 'Total Students',
                  value: '1,234',
                  color: theme.colorScheme.primary,
                ),
                _buildStatCard(
                  context,
                  icon: Icons.person_outlined,
                  title: 'Total Teachers',
                  value: '89',
                  color: theme.colorScheme.secondary,
                ),
                _buildStatCard(
                  context,
                  icon: Icons.class_outlined,
                  title: 'Total Classes',
                  value: '24',
                  color: theme.colorScheme.tertiary,
                ),
                _buildStatCard(
                  context,
                  icon: Icons.event_outlined,
                  title: 'Today\'s Events',
                  value: '5',
                  color: Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
