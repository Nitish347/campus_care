import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/controllers/exam_controller.dart';
import 'package:campus_care/controllers/exam_type_controller.dart';
import 'package:campus_care/widgets/admin/admin_page_header.dart';
import 'package:campus_care/screens/admin/exam/admin_exam_type_screen.dart';
import 'package:campus_care/screens/admin/exam/admin_exam_timetable_screen.dart';

class AdminExaminationManagementScreen extends StatelessWidget {
  const AdminExaminationManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final examTypeController = Get.isRegistered<ExamTypeController>()
        ? Get.find<ExamTypeController>()
        : Get.put(ExamTypeController());
    final examController = Get.isRegistered<ExamController>()
        ? Get.find<ExamController>()
        : Get.put(ExamController());

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            AdminPageHeader(
              subtitle: 'Manage examination categories and timetables',
              icon: Icons.assignment_rounded,
              showBreadcrumb: true,
              breadcrumbLabel: 'Examinations',
              showBackButton: true,
              title: const Text('Examination Management'),
              actions: [
                HeaderActionButton(
                  icon: Icons.refresh_rounded,
                  label: 'Refresh',
                  onPressed: () {
                    examTypeController.fetchExamTypes();
                    examController.fetchExams();
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.22),
                  ),
                ),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  labelColor: theme.colorScheme.onPrimaryContainer,
                  unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                  indicator: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.class_rounded, size: 18),
                      text: 'Exam Schedules',
                    ),
                    Tab(
                      icon: Icon(Icons.table_chart_rounded, size: 18),
                      text: 'Exam Timetables',
                    ),
                  ],
                ),
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  AdminExamTypeScreen(),
                  AdminExamTimetableScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
