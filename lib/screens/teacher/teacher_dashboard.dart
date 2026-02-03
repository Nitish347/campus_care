import 'package:campus_care/controllers/class_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/controllers/theme_controller.dart';
import 'package:campus_care/controllers/teacher_timetable_controller.dart';
import 'package:campus_care/controllers/homework_controller.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/widgets/cards/dashboard_card.dart';
import 'package:campus_care/widgets/cards/stat_card.dart';
import 'package:campus_care/widgets/responsive/responsive_grid.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/common/section_header.dart';
import 'package:campus_care/widgets/common/info_card.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final TeacherTimetableController _timetableController =
      Get.put(TeacherTimetableController());
  final HomeworkController _homeworkController = Get.put(HomeworkController());
  final classController = Get.find<ClassController>();

  @override
  void initState() {
    super.initState();
    _timetableController.fetchTeacherTimetable();
    _homeworkController.fetchHomework();
    classController.fetchClasses();
  }

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
                    authController.currentTeacher?.fullName
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
        child: ResponsivePadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Obx(() => Text(
                    'Welcome back, ${authController.currentTeacher?.fullName ?? 'Teacher'}! 👋',
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
            Obx(() {
              final timetableStats = _timetableController.getStats();
              final homeworkStats = _homeworkController.homeworkList.length;
              final todayPeriods = timetableStats['todayPeriods'] ?? 0;

              return ResponsiveGrid(
                childAspectRatio: 1.1,
                children: [
                  StatCard(
                    icon: Icons.class_outlined,
                    title: 'Total Classes',
                    value: '${timetableStats['totalClasses'] ?? 0}',
                    color: theme.colorScheme.primary,
                  ),
                  StatCard(
                    icon: Icons.assignment_outlined,
                    title: 'Pending Homework',
                    value: '$homeworkStats',
                    color: Colors.orange,
                  ),
                  StatCard(
                    icon: Icons.event_outlined,
                    title: 'Today\'s Classes',
                    value: '$todayPeriods',
                    color: Colors.green,
                  ),
                  StatCard(
                    icon: Icons.book_outlined,
                    title: 'Subjects',
                    value: '${timetableStats['totalSubjects'] ?? 0}',
                    color: Colors.purple,
                  ),
                ],
              );
            }),
            const SizedBox(height: 24),

            // Today's Schedule
            SectionHeader(title: 'Today\'s Schedule'),
            const SizedBox(height: 12),
            Obx(() {
              final todaysClasses = _timetableController.getTodaysClasses();

              if (_timetableController.isLoading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (todaysClasses.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 48,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No classes scheduled for today',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: todaysClasses.take(3).map((period) {
                  return InfoCard(
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.book,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      title: Text(period.subject),
                      subtitle: Text('Period ${period.period}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            period.startTime,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            period.endTime,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
            const SizedBox(height: 24),

            // Quick Access
            SectionHeader(title: 'Quick Access'),
            const SizedBox(height: 12),
            ResponsiveGrid(
              childAspectRatio: 0.95,
              children: [
                DashboardCard(
                  icon: Icons.people_outlined,
                  title: 'Student Management',
                  subtitle: 'Manage students',
                  onTap: () => Get.toNamed(AppRoutes.studentList),
                  iconColor: theme.colorScheme.primary,
                ),
                DashboardCard(
                  icon: Icons.schedule_outlined,
                  title: 'Timetable',
                  subtitle: 'View schedule',
                  onTap: () => Get.toNamed(AppRoutes.timetable),
                  iconColor: Colors.orange,
                ),
                DashboardCard(
                  icon: Icons.restaurant_menu,
                  title: 'Lunch Management',
                  subtitle: 'Track student meals',
                  onTap: () => Get.toNamed(AppRoutes.adminLunchManagement),
                  iconColor: Colors.deepPurple,
                ),
                DashboardCard(
                  icon: Icons.assignment_outlined,
                  title: 'Homework',
                  subtitle: 'Manage homework',
                  onTap: () => Get.toNamed(AppRoutes.adminHomework),
                  iconColor: Colors.indigo,
                ),
                DashboardCard(
                  icon: Icons.announcement_outlined,
                  title: 'Notices & Events',
                  subtitle: 'Announcements',
                  onTap: () => Get.toNamed(AppRoutes.noticeManagement),
                  iconColor: Colors.teal,
                ),
                // DashboardCard(
                //   icon: Icons.assignment_outlined,
                //   title: 'Manage Homework',
                //   subtitle: 'Assign & review',
                //   onTap: () => Get.toNamed(AppRoutes.teacherHomeworkManagement),
                //   iconColor: theme.colorScheme.primary,
                // ),
                DashboardCard(
                  icon: Icons.fact_check_outlined,
                  title: 'Mark Attendance',
                  subtitle: 'Daily attendance',
                  onTap: () => Get.toNamed(AppRoutes.adminAttendance),
                  iconColor: Colors.green,
                ),
                DashboardCard(
                  icon: Icons.assignment_turned_in_outlined,
                  title: 'Exams & Marks',
                  subtitle: 'Enter marks',
                  onTap: () => Get.toNamed(AppRoutes.examManagement),
                  iconColor: Colors.orange,
                ),
                DashboardCard(
                  icon: Icons.schedule_outlined,
                  title: 'My Timetable',
                  subtitle: 'View schedule',
                  onTap: () => Get.toNamed(AppRoutes.teacherTimetable),
                  iconColor: Colors.purple,
                ),
                // DashboardCard(
                //   icon: Icons.chat_outlined,
                //   title: 'Communication',
                //   subtitle: 'Chat & notices',
                //   onTap: () => Get.toNamed(AppRoutes.chatList),
                //   iconColor: Colors.blue,
                // ),
                // DashboardCard(
                //   icon: Icons.person_outlined,
                //   title: 'My Profile',
                //   subtitle: 'View details',
                //   onTap: () => Get.toNamed(AppRoutes.teacherProfile),
                //   iconColor: Colors.teal,
                // ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ));
  }
}
