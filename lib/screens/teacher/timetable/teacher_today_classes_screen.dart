import 'package:campus_care/controllers/teacher_timetable_controller.dart';
import 'package:campus_care/models/timetable_model.dart';
import 'package:campus_care/widgets/admin/admin_page_header.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TeacherTodayClassesScreen extends StatefulWidget {
  const TeacherTodayClassesScreen({super.key});

  @override
  State<TeacherTodayClassesScreen> createState() =>
      _TeacherTodayClassesScreenState();
}

class _TeacherTodayClassesScreenState extends State<TeacherTodayClassesScreen> {
  late final TeacherTimetableController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<TeacherTimetableController>()
        ? Get.find<TeacherTimetableController>()
        : Get.put(TeacherTimetableController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchTeacherTimetable();
    });
  }

  Color _resolveSubjectColor(String subject, ThemeData theme) {
    final normalized = subject.trim().toLowerCase();
    if (normalized.contains('math')) return const Color(0xFF2563EB);
    if (normalized.contains('science')) return const Color(0xFF059669);
    if (normalized.contains('english')) return const Color(0xFF7C3AED);
    if (normalized.contains('history')) return const Color(0xFFD97706);
    return theme.colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Column(
        children: [
          AdminPageHeader(
            title: const Text('Today Classes'),
            subtitle: 'All classes scheduled for today',
            icon: Icons.today_rounded,
            showBackButton: true,
            showBreadcrumb: true,
            breadcrumbLabel: 'Today Classes',
            actions: [
              HeaderActionButton(
                icon: Icons.refresh_rounded,
                label: 'Refresh',
                onPressed: _controller.fetchTeacherTimetable,
              ),
            ],
          ),
          Expanded(
            child: Obx(() {
              final todaysClasses = _controller.getTodaysClasses();

              if (_controller.isLoading.value && todaysClasses.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (todaysClasses.isEmpty) {
                return const EmptyState(
                  icon: Icons.event_busy_rounded,
                  title: 'No classes today',
                  message: 'You do not have any classes scheduled for today.',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                itemCount: todaysClasses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final classItem = todaysClasses[index];
                  return _TodayClassCard(
                    classItem: classItem,
                    color: _resolveSubjectColor(classItem.subject, theme),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _TodayClassCard extends StatelessWidget {
  final TimeTableItem classItem;
  final Color color;

  const _TodayClassCard({
    required this.classItem,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 58,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classItem.subject,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${classItem.startTime} - ${classItem.endTime}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    classItem.room?.trim().isNotEmpty == true
                        ? 'Room: ${classItem.room}'
                        : 'Room not assigned',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'P${classItem.period}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
