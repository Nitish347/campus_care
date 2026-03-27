import 'package:flutter/material.dart';
import 'package:campus_care/widgets/admin/admin_page_header.dart';
import 'package:campus_care/screens/admin/exam/admin_exam_type_screen.dart';
import 'package:campus_care/screens/admin/exam/admin_exam_timetable_screen.dart';

class AdminExaminationManagementScreen extends StatelessWidget {
  const AdminExaminationManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const AdminPageHeader(
              subtitle: 'Manage examination categories and timetables',
              icon: Icons.assignment_rounded,
              showBreadcrumb: true,
              breadcrumbLabel: 'Examinations',
              showBackButton: true,
              title: Text('Examination Management'),
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
