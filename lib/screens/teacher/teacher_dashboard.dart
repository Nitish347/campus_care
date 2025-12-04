import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/controllers/theme_controller.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/widgets/cards/dashboard_card.dart';
import 'package:campus_care/widgets/cards/stat_card.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final theme = Theme.of(context);

    // Sample data - in real app, this would come from services
    final totalClasses = 5;
    final totalStudents = 120;
    final pendingHomework = 8;
    final todayAttendance = 95;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.school_rounded,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Teacher Dashboard'),
          ],
        ),
        actions: [
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
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          Obx(() => PopupMenuButton<String>(
                icon: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    authController.currentUser?.name
                            .substring(0, 1)
                            .toUpperCase() ??
                        'T',
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
                    onTap: () => Get.toNamed(AppRoutes.teacherProfile),
                  ),
                  PopupMenuItem(
                    child: Row(
                      children: [
                        Icon(Icons.settings, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        const Text('Settings'),
                      ],
                    ),
                    onTap: () {},
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Obx(() => Text(
                  'Welcome, ${authController.currentUser?.name ?? 'Teacher'}! 👋',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                )),
            const SizedBox(height: 8),
            Text(
              'Here\'s your overview for today',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Quick Stats
            Text(
              'Quick Stats',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                StatCard(
                  icon: Icons.class_outlined,
                  title: 'Total Classes',
                  value: '$totalClasses',
                  color: theme.colorScheme.primary,
                ),
                StatCard(
                  icon: Icons.people_outlined,
                  title: 'Total Students',
                  value: '$totalStudents',
                  color: theme.colorScheme.secondary,
                ),
                StatCard(
                  icon: Icons.assignment_outlined,
                  title: 'Pending Homework',
                  value: '$pendingHomework',
                  color: Colors.orange,
                ),
                StatCard(
                  icon: Icons.check_circle_outline,
                  title: 'Today\'s Attendance',
                  value: '$todayAttendance%',
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Access Cards
            Text(
              'Quick Access',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
              children: [
                DashboardCard(
                  icon: Icons.assignment_outlined,
                  title: 'Manage Homework',
                  subtitle: 'Assign & review',
                  onTap: () => Get.toNamed(AppRoutes.teacherHomeworkManagement),
                  iconColor: theme.colorScheme.primary,
                ),
                DashboardCard(
                  icon: Icons.checklist_outlined,
                  title: 'Mark Attendance',
                  subtitle: 'Take attendance',
                  onTap: () =>
                      Get.toNamed(AppRoutes.teacherAttendanceManagement),
                  iconColor: theme.colorScheme.secondary,
                ),
                DashboardCard(
                  icon: Icons.edit_outlined,
                  title: 'Manage Exams',
                  subtitle: 'Exams & marks',
                  onTap: () => Get.toNamed(AppRoutes.examManagement),
                  iconColor: theme.colorScheme.tertiary,
                ),
                DashboardCard(
                  icon: Icons.schedule_outlined,
                  title: 'Timetable',
                  subtitle: 'View schedule',
                  onTap: () => Get.toNamed(AppRoutes.teacherTimetable),
                  iconColor: Colors.orange,
                ),
                DashboardCard(
                  icon: Icons.chat_bubble_outline,
                  title: 'Communication',
                  subtitle: 'Chat with parents',
                  onTap: () => Get.toNamed(AppRoutes.chatList),
                  iconColor: Colors.purple,
                ),
                DashboardCard(
                  icon: Icons.person_outline,
                  title: 'Profile & Leave',
                  subtitle: 'Manage profile',
                  onTap: () => Get.toNamed(AppRoutes.teacherProfile),
                  iconColor: Colors.teal,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Today's Schedule
            Text(
              'Today\'s Schedule',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '9:00',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: const Text('Mathematics - Class 5A'),
                    subtitle: const Text('Room 101'),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '10:00',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: const Text('Science - Class 5B'),
                    subtitle: const Text('Room 102'),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              // Already on dashboard
              break;
            case 1:
              Get.toNamed(AppRoutes.teacherProfile);
              break;
            case 2:
              Get.toNamed(AppRoutes.homework);
              break;
            case 3:
              Get.toNamed(AppRoutes.attendance);
              break;
            case 4:
              Get.toNamed(AppRoutes.chatList);
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Homework',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Attendance',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outlined),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
        ],
      ),
    );
  }
}
