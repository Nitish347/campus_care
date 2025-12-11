import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/controllers/theme_controller.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/widgets/cards/dashboard_card.dart';
import 'package:campus_care/widgets/cards/stat_card.dart';
import 'package:campus_care/widgets/responsive/responsive_grid.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/common/section_header.dart';
import 'package:campus_care/widgets/common/info_card.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  // Static UI data
  static const _activeHomework = 3;
  static const _overdueHomework = 1;
  static const _attendancePercentage = 95;
  static const _pendingFees = 2;
  static const _totalPendingAmount = 5500.0;

  // Static events data
  static final _events = [
    {
      'title': 'Annual Sports Day',
      'date': DateTime.now().add(const Duration(days: 10)),
    },
    {
      'title': 'Science Fair',
      'date': DateTime.now().add(const Duration(days: 20)),
    },
    {
      'title': 'Parent-Teacher Meeting',
      'date': DateTime.now().add(const Duration(days: 5)),
    },
  ];

  // Static notices data
  static final _notices = [
    {
      'title': 'Holiday Notice',
      'description': 'School will be closed on Friday',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'priority': 'high',
    },
    {
      'title': 'Fee Payment Reminder',
      'description': 'Please pay the pending fees',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'priority': 'medium',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.school_rounded,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('School Stream'),
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
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => Get.toNamed(AppRoutes.studentNotifications),
                tooltip: 'Notifications',
              ),
              // Badge for unread notifications (optional - can be added later)
            ],
          ),
          const SizedBox(width: 8),
          Obx(() => PopupMenuButton<String>(
                icon: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    authController.currentStudent?.name
                            .substring(0, 1)
                            .toUpperCase() ??
                        'S',
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
                    onTap: () => Get.toNamed(AppRoutes.studentProfile),
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
        child: ResponsivePadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Obx(() => Text(
                    'Welcome back, ${authController.currentStudent?.name ?? 'Student'}! 👋',
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
              SectionHeader(title: 'Quick Stats'),
              const SizedBox(height: 12),
              ResponsiveGrid(
                childAspectRatio: 1.1,
                children: [
                  StatCard(
                    icon: Icons.assignment_outlined,
                    title: 'Active Homework',
                    value: '$_activeHomework',
                    color: theme.colorScheme.primary,
                  ),
                  StatCard(
                    icon: Icons.check_circle_outline,
                    title: 'Attendance',
                    value: '$_attendancePercentage%',
                    color: theme.colorScheme.error,
                  ),
                  StatCard(
                    icon: Icons.warning_amber_outlined,
                    title: 'Overdue',
                    value: '$_overdueHomework',
                    color: Colors.orange,
                    isPositiveChange: false,
                  ),
                  StatCard(
                    icon: Icons.medical_services_outlined,
                    title: 'Pending Fees',
                    value: '₹${_totalPendingAmount.toStringAsFixed(0)}',
                    color: theme.colorScheme.secondary,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Dashboard Cards
              SectionHeader(title: 'Quick Access'),
              const SizedBox(height: 12),
              ResponsiveGrid(
                childAspectRatio: 0.95,
                children: [
                  DashboardCard(
                    icon: Icons.assignment_outlined,
                    title: 'Homework',
                    subtitle: '$_activeHomework active',
                    onTap: () => Get.toNamed(AppRoutes.studentHomework),
                    iconColor: theme.colorScheme.primary,
                  ),
                  DashboardCard(
                    icon: Icons.calendar_today_outlined,
                    title: 'Attendance',
                    subtitle: '$_attendancePercentage% present',
                    onTap: () => Get.toNamed(AppRoutes.studentAttendance),
                    iconColor: theme.colorScheme.secondary,
                  ),
                  DashboardCard(
                    icon: Icons.medical_services,
                    title: 'Medical Reports',
                    subtitle: '4 reports',
                    onTap: () => Get.toNamed(AppRoutes.studentMedicalReports),
                    iconColor: Colors.red,
                  ),
                  DashboardCard(
                    icon: Icons.assignment_outlined,
                    title: 'Exams',
                    subtitle: '5 upcoming',
                    onTap: () => Get.toNamed(AppRoutes.studentExamTimetable),
                    iconColor: Colors.purple,
                  ),
                  DashboardCard(
                    icon: Icons.schedule_outlined,
                    title: 'Timetable',
                    subtitle: 'View schedule',
                    onTap: () => Get.toNamed(AppRoutes.studentTimetable),
                    iconColor: Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Upcoming Events
              SectionHeader(
                title: 'Upcoming Events',
                // actionLabel: 'View All',
                // onAction: () {},
              ),
              const SizedBox(height: 12),
              ..._events.take(3).map((event) {
                final eventDate = event['date'] as DateTime;
                return InfoCard(
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.event,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: Text(event['title'] as String),
                    subtitle: Text(
                      DateFormat('MMM dd, yyyy').format(eventDate),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              }),
              const SizedBox(height: 24),

              // Recent Notices
              SectionHeader(
                title: 'Recent Notices',
                // actionLabel: 'View All',
                // onAction: () {},
              ),
              const SizedBox(height: 12),
              ..._notices.take(3).map((notice) {
                final noticeDate = notice['date'] as DateTime;
                final priority = notice['priority'] as String;
                Color priorityColor;
                switch (priority) {
                  case 'high':
                    priorityColor = Colors.red;
                    break;
                  case 'medium':
                    priorityColor = Colors.orange;
                    break;
                  default:
                    priorityColor = Colors.blue;
                }
                return InfoCard(
                  child: ListTile(
                    leading: Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: priorityColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    title: Text(notice['title'] as String),
                    subtitle: Text(
                      DateFormat('MMM dd, yyyy').format(noticeDate),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: NavigationBar(
      //   selectedIndex: 0,
      //   onDestinationSelected: (index) {
      //     switch (index) {
      //       case 0:
      //         break;
      //       case 1:
      //         Get.toNamed(AppRoutes.studentProfile);
      //         break;
      //       case 2:
      //         Get.toNamed(AppRoutes.studentHomework);
      //         break;
      //       case 3:
      //         Get.toNamed(AppRoutes.studentAttendance);
      //         break;
      //       // case 4:
      //       //   Get.toNamed(AppRoutes.studentFees);
      //       //   break;
      //     }
      //   },
      //   destinations: const [
      //     NavigationDestination(
      //       icon: Icon(Icons.home_outlined),
      //       selectedIcon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     NavigationDestination(
      //       icon: Icon(Icons.person_outlined),
      //       selectedIcon: Icon(Icons.person),
      //       label: 'Profile',
      //     ),
      //     NavigationDestination(
      //       icon: Icon(Icons.assignment_outlined),
      //       selectedIcon: Icon(Icons.assignment),
      //       label: 'Homework',
      //     ),
      //     NavigationDestination(
      //       icon: Icon(Icons.calendar_today_outlined),
      //       selectedIcon: Icon(Icons.calendar_today),
      //       label: 'Attendance',
      //     ),
      //     // NavigationDestination(
      //     //   icon: Icon(Icons.payment_outlined),
      //     //   selectedIcon: Icon(Icons.payment),
      //     //   label: 'Fees',
      //     // ),
      //   ],
      // ),
    );
  }
}
