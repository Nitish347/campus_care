import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/controllers/subject_controller.dart';
import 'package:campus_care/controllers/teacher_controller.dart';
import 'package:campus_care/widgets/inputs/class_section_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/controllers/timetable_controller.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/screens/admin/academic/add_timetable_screen.dart';
import 'package:campus_care/models/timetable_model.dart';
import 'package:campus_care/widgets/common/empty_state.dart';

import 'package:campus_care/widgets/admin/admin_page_header.dart';

class TimetableScreen extends GetView<TimetableController> {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controllers are initialized
    if (!Get.isRegistered<TimetableController>()) {
      Get.put(TimetableController());
    }
    // Perform put if not already registered to ensure they are available
    if (!Get.isRegistered<SubjectController>()) {
      Get.put(SubjectController());
    }
    if (!Get.isRegistered<TeacherController>()) {
      Get.put(TeacherController());
    }

    final authController = Get.find<AuthController>();
    final subjectController = Get.find<SubjectController>();
    final teacherController = Get.find<TeacherController>();

    return Scaffold(
      appBar: AdminPageHeader(
        title: 'School Timetable',
        subtitle: 'View class schedules',
        icon: Icons.calendar_month,
        showBreadcrumb: true,
        breadcrumbLabel: 'Timetable',
        showBackButton: true,
        actions: [
          HeaderActionButton(
            icon: Icons.refresh_rounded,
            label: 'Refresh',
            onPressed: () {
              controller.loadTimetables();
              // Also refresh subjects and teachers to ensure fresh data for mapping
              subjectController.fetchSubjects();
              teacherController.loadTeachers();
            },
          ),
          if (authController.isAdmin()) ...[
            const SizedBox(width: 8),
            HeaderActionButton(
              icon: Icons.add_rounded,
              label: 'Add Timetable',
              onPressed: () async {
                await Get.toNamed(AppRoutes.addTimetable);
                // Refresh when returning from add screen
                controller.loadTimetables(
                  classId: controller.selectedClass,
                  section: controller.selectedSection,
                );
              },
            ),
          ],
        ],
      ),
      body: Obx(
        () => Column(
          children: [
            // Edit Button (shown when timetable exists)
            if (controller.currentTimetable != null && authController.isAdmin())
              Container(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Get.to(() => AddTimetableScreen(
                            timetable: controller.currentTimetable!,
                          ));
                      // Refresh after editing
                      controller.loadTimetables(
                        classId: controller.selectedClass,
                        section: controller.selectedSection,
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Timetable'),
                  ),
                ),
              ),
            // Class and Section Selection

            ClassSectionDropDown(onChangedClass: (val) {
              controller.selectClass(val);
            }, onChangedSection: (val) {
              controller.selectSection(val);
            }),

            // Timetable View
            Expanded(
              child: Obx(() {
                if (controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.selectedClass == null ||
                    controller.selectedSection == null) {
                  return const EmptyState(
                    icon: Icons.schedule,
                    title: 'Select Class and Section',
                    message:
                        'Please select a class and section to view timetable',
                  );
                }

                if (controller.currentTimetable == null) {
                  return EmptyState(
                    icon: Icons.event_busy,
                    title: 'No timetable found',
                    message: 'Create a timetable for this class and section',
                    // action: ElevatedButton.icon(
                    //   onPressed: () async {
                    //     await Get.toNamed(AppRoutes.addTimetable);
                    //     // Refresh when returning
                    //     controller.loadTimetables(
                    //       classId: controller.selectedClass,
                    //       section: controller.selectedSection,
                    //     );
                    //   },
                    //   icon: const Icon(Icons.add),
                    //   label: const Text('Create Timetable'),
                    // ),
                  );
                }

                return _buildTimetable(context);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimetable(BuildContext context) {
    final theme = Theme.of(context);
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    final timetable = controller.currentTimetable!;

    return DefaultTabController(
      length: days.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            indicatorColor: theme.colorScheme.primary,
            tabs: days
                .map((day) => Tab(
                      text: day,
                      icon: Icon(_getDayIcon(day)),
                    ))
                .toList(),
          ),
          Expanded(
            child: TabBarView(
              children: days.map((day) {
                final daySchedule = timetable.weeklySchedule[day] ?? [];

                if (daySchedule.isEmpty) {
                  return EmptyState(
                    icon: Icons.event_busy,
                    title: 'No classes scheduled',
                    message: 'No classes scheduled for $day',
                  );
                }

                return _buildDayTimetable(context, day, daySchedule);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayTimetable(
    BuildContext context,
    String day,
    List<TimeTableItem> periods,
  ) {
    final theme = Theme.of(context);
    final subjectController = Get.find<SubjectController>();
    final teacherController = Get.find<TeacherController>();

    return Container(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: periods.length,
        itemBuilder: (context, index) {
          final period = periods[index];

          // Resolve IDs to names
          final subjectName = subjectController.subjects
                  .firstWhereOrNull((s) => s.id == period.subject)
                  ?.name ??
              period.subject; // Fallback to ID/Text if not found

          final teacherName = teacherController.teachers
                  .firstWhereOrNull((t) => t.id == period.teacherId)
                  ?.fullName ??
              period.teacherId;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: BorderSide(
                    color: _getTypeColor(theme, period.type),
                    width: 4,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Period Number and Time
                    Container(
                      width: 80,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            period.period,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            period.startTime,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            period.endTime,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Subject and Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  subjectName,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getTypeColor(theme, period.type)
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  period.type.toUpperCase(),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: _getTypeColor(theme, period.type),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            theme,
                            Icons.person,
                            'Teacher: $teacherName',
                          ),
                          if (period.room != null && period.room!.isNotEmpty)
                            _buildDetailRow(
                              theme,
                              Icons.room,
                              'Room: ${period.room}',
                            ),
                          _buildDetailRow(
                            theme,
                            Icons.access_time,
                            '${period.startTime} - ${period.endTime}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDayIcon(String day) {
    switch (day) {
      case 'Monday':
        return Icons.calendar_today;
      case 'Tuesday':
        return Icons.calendar_view_week;
      case 'Wednesday':
        return Icons.calendar_view_day;
      case 'Thursday':
        return Icons.event;
      case 'Friday':
        return Icons.event_available;
      case 'Saturday':
        return Icons.weekend;
      default:
        return Icons.calendar_today;
    }
  }

  Color _getTypeColor(ThemeData theme, String type) {
    switch (type.toLowerCase()) {
      case 'lab':
        return Colors.blue;
      case 'break':
        return Colors.orange;
      case 'lunch':
        return Colors.green;
      case 'sports':
        return Colors.purple;
      default:
        return theme.colorScheme.primary;
    }
  }
}
