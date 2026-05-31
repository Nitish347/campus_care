import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/controllers/exam_controller.dart';
import 'package:campus_care/controllers/exam_type_controller.dart';
import 'package:campus_care/widgets/admin/admin_page_header.dart';
import 'package:campus_care/screens/admin/exam/admin_exam_type_screen.dart';
import 'package:campus_care/screens/admin/exam/admin_exam_timetable_screen.dart';

class AdminExaminationManagementScreen extends StatefulWidget {
  const AdminExaminationManagementScreen({super.key});

  @override
  State<AdminExaminationManagementScreen> createState() =>
      _AdminExaminationManagementScreenState();
}

class _AdminExaminationManagementScreenState
    extends State<AdminExaminationManagementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging &&
          _currentTabIndex != _tabController.index) {
        setState(() => _currentTabIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
      body: Column(
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
              child: Row(
                children: [
                  Expanded(
                    child: _buildAnimatedTab(
                      title: 'Exam Schedules',
                      icon: Icons.class_rounded,
                      index: 0,
                      accent: const Color(0xFF2563EB),
                    ),
                  ),
                  Expanded(
                    child: _buildAnimatedTab(
                      title: 'Exam Timetables',
                      icon: Icons.table_chart_rounded,
                      index: 1,
                      accent: const Color(0xFF059669),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                AdminExamTypeScreen(),
                AdminExamTimetableScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTab({
    required String title,
    required IconData icon,
    required int index,
    required Color accent,
  }) {
    final selected = _currentTabIndex == index;
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
        setState(() => _currentTabIndex = index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: selected ? Colors.white : Colors.transparent,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selected ? accent : Colors.black54),
            const SizedBox(width: 7),
            Flexible(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? accent : Colors.black54,
                  fontSize: 13.5,
                ),
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
