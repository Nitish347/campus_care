import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/controllers/super_admin_controller.dart';
import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/widgets/cards/stat_card.dart';
import 'package:campus_care/widgets/responsive/responsive_grid.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/common/section_header.dart';
import 'package:campus_care/models/admin/admin.dart';
import 'package:campus_care/screens/super_admin/school_details_screen.dart';

class SuperAdminDashboard extends StatelessWidget {
  const SuperAdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SuperAdminController());
    final authController = Get.find<AuthController>();
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1200;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.admin_panel_settings,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Super Admin Dashboard'),
          ],
        ),
        actions: [
          // Show selected school if any
          Obx(() {
            final selectedSchool = controller.selectedSchool;
            if (selectedSchool != null) {
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.school,
                      size: 16,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      selectedSchool.instituteName,
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => controller.clearSelectedSchool(),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                'SA',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onSelected: (value) {
              if (value == 'logout') {
                authController.logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: theme.colorScheme.error),
                    const SizedBox(width: 8),
                    const Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: isDesktop ? null : _buildDrawer(context, controller),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(context, controller),
          Expanded(
            child: _buildMainContent(context, isDesktop),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, SuperAdminController controller) {
    return Drawer(
      child: _buildSidebarContent(context, controller),
    );
  }

  Widget _buildSidebar(BuildContext context, SuperAdminController controller) {
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
      child: _buildSidebarContent(context, controller),
    );
  }

  Widget _buildSidebarContent(
      BuildContext context, SuperAdminController controller) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: 24),
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
                'Super Admin',
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
                title: 'Dashboard',
                isSelected: true,
                onTap: () {},
              ),
              const SizedBox(height: 8),
              _buildSidebarSection('School Management'),
              _buildSidebarItem(
                context,
                icon: Icons.school_outlined,
                title: 'All Schools',
                onTap: () => Get.toNamed(AppRoutes.instituteManagement),
              ),
              _buildSidebarItem(
                context,
                icon: Icons.add_business,
                title: 'Add School',
                onTap: () => Get.toNamed(AppRoutes.addEditInstitute),
              ),
              const SizedBox(height: 16),
              _buildSidebarSection('Cross-School'),
              _buildSidebarItem(
                context,
                icon: Icons.people_outlined,
                title: 'All Students',
                onTap: () {
                  controller.clearSelectedSchool();
                  controller.loadAllStudents();
                },
              ),
              _buildSidebarItem(
                context,
                icon: Icons.person_outlined,
                title: 'All Teachers',
                onTap: () {
                  controller.clearSelectedSchool();
                  controller.loadAllTeachers();
                },
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

  Widget _buildMainContent(BuildContext context, bool isDesktop) {
    final theme = Theme.of(context);
    final controller = Get.find<SuperAdminController>();

    return SingleChildScrollView(
      child: ResponsivePadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, Super Admin! 👋',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage all schools and monitor the entire Campus Care platform',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Global Stats
            SectionHeader(title: 'Platform Statistics'),
            const SizedBox(height: 12),
            Obx(() {
              final stats = controller.dashboardStats;
              return ResponsiveGrid(
                childAspectRatio: isDesktop ? 1.6 : 1.1,
                children: [
                  StatCard(
                    icon: Icons.school_outlined,
                    title: 'Total Schools',
                    value: stats['schools']?.toString() ?? '0',
                    color: theme.colorScheme.primary,
                  ),
                  StatCard(
                    icon: Icons.people_outlined,
                    title: 'Total Students',
                    value: stats['students']?.toString() ?? '0',
                    color: theme.colorScheme.secondary,
                  ),
                  StatCard(
                    icon: Icons.person_outlined,
                    title: 'Total Teachers',
                    value: stats['teachers']?.toString() ?? '0',
                    color: Colors.purple,
                  ),
                  StatCard(
                    icon: Icons.class_outlined,
                    title: 'Total Classes',
                    value: stats['classes']?.toString() ?? '0',
                    color: Colors.orange,
                  ),
                ],
              );
            }),
            const SizedBox(height: 24),

            // Schools List
            SectionHeader(
              title: 'Schools',
              action: TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add School'),
                onPressed: () => Get.toNamed(AppRoutes.addEditInstitute),
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final schools = controller.schools;
              if (schools.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 64,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No schools found',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first school to get started',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () =>
                                Get.toNamed(AppRoutes.addEditInstitute),
                            icon: const Icon(Icons.add),
                            label: const Text('Add School'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return Card(
                child: Column(
                  children: schools.take(10).map((school) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          school.instituteName.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(school.instituteName),
                      subtitle: Text(
                        '${school.email} • ${school.city ?? "Unknown City"}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Student count if available from stats
                          if (school is Admin)
                            Text(
                              '${(school as dynamic).stats?['students'] ?? 0} students',
                              style: theme.textTheme.bodySmall,
                            ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: () {
                              controller.selectSchool(school);
                              Get.to(
                                () => SchoolDetailsScreen(school: school),
                              );
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        controller.selectSchool(school);
                        Get.toNamed(
                          AppRoutes.instituteDetail,
                          arguments: school,
                        );
                      },
                    );
                  }).toList(),
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
