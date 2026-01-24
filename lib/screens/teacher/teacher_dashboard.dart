import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/controllers/theme_controller.dart';
import 'package:campus_care/controllers/teacher_timetable_controller.dart';
import 'package:campus_care/controllers/homework_controller.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/widgets/cards/dashboard_card.dart';
import 'package:campus_care/widgets/cards/stat_card.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final TeacherTimetableController _timetableController =
      Get.put(TeacherTimetableController());
  final HomeworkController _homeworkController = Get.put(HomeworkController());

  @override
  void initState() {
    super.initState();
    _timetableController.fetchTeacherTimetable();
    _homeworkController.fetchHomework();
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Obx(() {
              final teacher = authController.currentTeacher;
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.secondaryContainer,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            teacher?.fullName ?? 'Teacher',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            teacher?.email ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: theme.colorScheme.primary,
                      child: Icon(
                        Icons.person,
                        size: 32,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),

            // Quick Stats
            Text(
              'Quick Stats',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final timetableStats = _timetableController.getStats();
              final homeworkStats = _homeworkController.homeworkList.length;
              final todayPeriods = timetableStats['todayPeriods'] ?? 0;

              return GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.5,
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
            Text(
              'Today\'s Schedule',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
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
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
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
            Text(
              'Quick Access',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.2,
              children: [
                DashboardCard(
                  icon: Icons.assignment_outlined,
                  title: 'Manage Homework',
                  subtitle: 'Assign & review',
                  onTap: () => Get.toNamed(AppRoutes.teacherHomeworkManagement),
                  iconColor: theme.colorScheme.primary,
                ),
                DashboardCard(
                  icon: Icons.fact_check_outlined,
                  title: 'Mark Attendance',
                  subtitle: 'Daily attendance',
                  onTap: () => Get.toNamed(AppRoutes.attendance),
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
                DashboardCard(
                  icon: Icons.chat_outlined,
                  title: 'Communication',
                  subtitle: 'Chat & notices',
                  onTap: () => Get.toNamed(AppRoutes.chatList),
                  iconColor: Colors.blue,
                ),
                DashboardCard(
                  icon: Icons.person_outlined,
                  title: 'My Profile',
                  subtitle: 'View details',
                  onTap: () => Get.toNamed(AppRoutes.teacherProfile),
                  iconColor: Colors.teal,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
