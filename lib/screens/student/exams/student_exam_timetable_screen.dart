import 'package:campus_care/controllers/exam_controller.dart';
import 'package:campus_care/models/exam_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/student/student_app_bar.dart';

class StudentExamTimetableScreen extends StatefulWidget {
  const StudentExamTimetableScreen({super.key});

  @override
  State<StudentExamTimetableScreen> createState() =>
      _StudentExamTimetableScreenState();
}

class _StudentExamTimetableScreenState
    extends State<StudentExamTimetableScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'final',
    'mid-term',
    'quiz',
    'assignment',
  ];

  @override
  void initState() {
    super.initState();
    // Ensure ExamController is initialized and fetches data
    Get.put(ExamController());
  }

  List<ExamModel> _getFilteredExams(List<ExamModel> exams) {
    final now = DateTime.now();
    var upcoming = exams.where((e) => e.examDate.isAfter(now)).toList();
    upcoming.sort((a, b) => a.examDate.compareTo(b.examDate));

    if (_selectedFilter == 'All') return upcoming;
    return upcoming.where((e) => e.type == _selectedFilter).toList();
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
        return Colors.blue;
      case 'science':
        return Colors.green;
      case 'english':
        return Colors.purple;
      case 'history':
        return Colors.brown;
      case 'computer science':
        return Colors.orange;
      default:
        return Colors.teal;
    }
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
        return Icons.calculate_outlined;
      case 'science':
        return Icons.science_outlined;
      case 'english':
        return Icons.menu_book_outlined;
      case 'history':
        return Icons.history_edu_outlined;
      case 'computer science':
        return Icons.computer_outlined;
      default:
        return Icons.book_outlined;
    }
  }

  Color _getExamTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'final':
        return Colors.red;
      case 'mid-term':
        return Colors.orange;
      case 'quiz':
        return Colors.blue;
      case 'assignment':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getTimeRemaining(DateTime examDate) {
    final now = DateTime.now();
    final difference = examDate.difference(now);

    if (difference.isNegative) return 'Exam passed';

    final days = difference.inDays;
    final hours = difference.inHours % 24;

    if (days == 0) {
      if (hours == 0) {
        final minutes = difference.inMinutes;
        return 'In $minutes min${minutes > 1 ? 's' : ''}';
      }
      return 'In $hours hr${hours > 1 ? 's' : ''}';
    } else if (days == 1) {
      return 'Tomorrow';
    } else if (days < 7) {
      return 'In $days days';
    } else {
      final weeks = (days / 7).floor();
      return 'In $weeks week${weeks > 1 ? 's' : ''}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<ExamController>();

    return Scaffold(
      appBar: StudentAppBar(
        title: 'Exam Timetable',
        extraActions: [
          Obx(() => controller.isLoading.value
              ? const Padding(
                  padding: EdgeInsets.all(9),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => controller.fetchExams(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.refresh,
                        color: Colors.white, size: 20),
                  ),
                )),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _showFilterDialog,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.filter_list_outlined,
                  color: Colors.white, size: 20),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => Get.toNamed(AppRoutes.studentResults),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.assessment_outlined,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.examList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredExams = _getFilteredExams(controller.examList.toList());

        return Column(
          children: [
            _buildExamSummaryHero(context, filteredExams),

            // Exam Table
            Expanded(
              child: filteredExams.isEmpty
                  ? EmptyState(
                      icon: Icons.event_busy,
                      title: 'No upcoming exams',
                      message: _selectedFilter == 'All'
                          ? 'You have no upcoming exams scheduled'
                          : 'No upcoming $_selectedFilter exams',
                    )
                  : ResponsivePadding(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: theme.colorScheme.outlineVariant,
                              width: 1,
                            ),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(
                                theme.colorScheme.primaryContainer
                                    .withValues(alpha: 0.5),
                              ),
                              headingTextStyle:
                                  theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                              dataRowMinHeight: 60,
                              dataRowMaxHeight: 80,
                              columnSpacing: 24,
                              horizontalMargin: 16,
                              columns: const [
                                DataColumn(label: Text('Subject')),
                                DataColumn(label: Text('Date')),
                                DataColumn(label: Text('Time')),
                                DataColumn(label: Text('Duration')),
                                DataColumn(label: Text('Type')),
                                DataColumn(label: Text('Marks')),
                                DataColumn(label: Text('Status')),
                              ],
                              rows: filteredExams.map((exam) {
                                final subjectColor =
                                    _getSubjectColor(exam.subject);
                                final typeColor = _getExamTypeColor(exam.type);
                                final timeRemaining =
                                    _getTimeRemaining(exam.examDate);
                                final isUrgent = exam.examDate
                                        .difference(DateTime.now())
                                        .inDays <
                                    3;
                                final durationText =
                                    exam.durationMinutes != null
                                        ? '${exam.durationMinutes} min'
                                        : '—';

                                return DataRow(
                                  onSelectChanged: (_) =>
                                      _showExamDetails(context, exam),
                                  cells: [
                                    // Subject
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: subjectColor.withValues(
                                                  alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              _getSubjectIcon(exam.subject),
                                              color: subjectColor,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            exam.subject,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Date
                                    DataCell(Text(
                                      DateFormat('MMM dd, yyyy')
                                          .format(exam.examDate),
                                      style: theme.textTheme.bodyMedium,
                                    )),
                                    // Time
                                    DataCell(Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.access_time,
                                            size: 16,
                                            color: theme
                                                .colorScheme.onSurfaceVariant),
                                        const SizedBox(width: 4),
                                        Text(
                                          DateFormat('hh:mm a')
                                              .format(exam.examDate),
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ],
                                    )),
                                    // Duration
                                    DataCell(Text(
                                      durationText,
                                      style: theme.textTheme.bodyMedium,
                                    )),
                                    // Type
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color:
                                              typeColor.withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          exam.type.toUpperCase(),
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: typeColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Marks
                                    DataCell(Text(
                                      '${exam.totalMarks.toInt()}',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600),
                                    )),
                                    // Status
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: isUrgent
                                              ? Colors.red
                                                  .withValues(alpha: 0.1)
                                              : Colors.green
                                                  .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color: isUrgent
                                                ? Colors.red
                                                    .withValues(alpha: 0.3)
                                                : Colors.green
                                                    .withValues(alpha: 0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isUrgent
                                                  ? Icons.warning_amber
                                                  : Icons.schedule,
                                              size: 14,
                                              color: isUrgent
                                                  ? Colors.red
                                                  : Colors.green,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              timeRemaining,
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                color: isUrgent
                                                    ? Colors.red
                                                    : Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildExamSummaryHero(
    BuildContext context,
    List<ExamModel> filteredExams,
  ) {
    final theme = Theme.of(context);
    final nextExam = filteredExams.isNotEmpty ? filteredExams.first : null;
    final nextTime =
        nextExam != null ? _getTimeRemaining(nextExam.examDate) : 'No exams';
    final nextDate = nextExam != null
        ? DateFormat('MMM dd').format(nextExam.examDate)
        : 'N/A';
    final nextSubject = nextExam?.subject ?? 'Schedule clear';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF0891B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0891B2).withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.event_note_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exam schedule',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      nextSubject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.16),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.24)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${filteredExams.length}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Exams',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.76),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _summaryHeroTile(
                  context,
                  icon: Icons.schedule_outlined,
                  label: 'Next',
                  value: nextTime,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryHeroTile(
                  context,
                  icon: Icons.calendar_month_outlined,
                  label: 'Date',
                  value: nextDate,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryHeroTile(
                  context,
                  icon: Icons.filter_alt_outlined,
                  label: 'Filter',
                  value: _selectedFilter == 'All' ? 'All' : _selectedFilter,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryHeroTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    final theme = Theme.of(context);
    final displayNames = {
      'All': 'All',
      'final': 'Final',
      'mid-term': 'Mid-term',
      'quiz': 'Quiz',
      'assignment': 'Assignment',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Exam Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return ListTile(
              title: Text(displayNames[filter] ?? filter),
              trailing: isSelected
                  ? Icon(Icons.check_rounded, color: theme.colorScheme.primary)
                  : null,
              selected: isSelected,
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedFilter = 'All';
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showExamDetails(BuildContext context, ExamModel exam) {
    final theme = Theme.of(context);
    final subjectColor = _getSubjectColor(exam.subject);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: subjectColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getSubjectIcon(exam.subject),
                    color: subjectColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exam.subject,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        exam.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildDetailRow(context, Icons.calendar_today, 'Date',
                DateFormat('EEEE, MMMM dd, yyyy').format(exam.examDate)),
            const SizedBox(height: 12),
            _buildDetailRow(context, Icons.access_time, 'Time',
                DateFormat('hh:mm a').format(exam.examDate)),
            const SizedBox(height: 12),
            if (exam.durationMinutes != null) ...[
              _buildDetailRow(context, Icons.timelapse, 'Duration',
                  '${exam.durationMinutes} minutes'),
              const SizedBox(height: 12),
            ],
            _buildDetailRow(context, Icons.grade_outlined, 'Total Marks',
                '${exam.totalMarks.toInt()}'),
            const SizedBox(height: 12),
            _buildDetailRow(context, Icons.category_outlined, 'Exam Type',
                exam.type.toUpperCase()),
            if (exam.instructions != null && exam.instructions!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildDetailRow(context, Icons.info_outline, 'Instructions',
                  exam.instructions!),
            ],

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Close'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
