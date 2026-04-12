import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/controllers/exam_controller.dart';
import 'package:campus_care/controllers/exam_type_controller.dart';
import 'package:campus_care/core/constants/app_constants.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/widgets/admin/admin_page_header.dart';
import 'package:campus_care/screens/admin/exam/admin_exam_type_screen.dart';
import 'package:campus_care/screens/admin/exam/admin_exam_timetable_screen.dart';

class AdminExaminationManagementScreen extends StatelessWidget {
  const AdminExaminationManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTeacherView = Get.isRegistered<AuthController>() &&
        Get.find<AuthController>().currentRole == AppConstants.roleTeacher;
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
                if (!isTeacherView) ...[
                  const SizedBox(width: 8),
                  HeaderActionButton(
                    icon: Icons.add_rounded,
                    label: 'Add',
                    onPressed: () => Get.toNamed(AppRoutes.adminAddExamType),
                  ),
                ],
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: TabBar(
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                indicatorColor: theme.colorScheme.primary,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.class_rounded),
                    text: 'Exam Schedules',
                  ),
                  Tab(
                    icon: Icon(Icons.table_chart_rounded),
                    text: 'Exam Timetables',
                  ),
                ],
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
