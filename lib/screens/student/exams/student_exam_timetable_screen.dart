import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';

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
    'Mid-term',
    'Final',
    'Quiz',
    'Unit Test'
  ];

  // Static exam timetable data
  final List<Map<String, dynamic>> _exams = [
    {
      'id': '1',
      'subject': 'Mathematics',
      'examName': 'Mid-term Exam',
      'examType': 'Mid-term',
      'dateTime': DateTime.now().add(const Duration(days: 3, hours: 9)),
      'duration': '3 hours',
      'venue': 'Room 101',
      'totalMarks': 100,
      'isFirstHalf': true,
    },
    {
      'id': '2',
      'subject': 'Science',
      'examName': 'Mid-term Exam',
      'examType': 'Mid-term',
      'dateTime': DateTime.now().add(const Duration(days: 4, hours: 9)),
      'duration': '3 hours',
      'venue': 'Lab 2',
      'totalMarks': 100,
      'isFirstHalf': true,
    },
    {
      'id': '3',
      'subject': 'English',
      'examName': 'Unit Test',
      'examType': 'Unit Test',
      'dateTime': DateTime.now().add(const Duration(days: 7, hours: 14)),
      'duration': '2 hours',
      'venue': 'Room 203',
      'totalMarks': 50,
      'isFirstHalf': false,
    },
    {
      'id': '4',
      'subject': 'History',
      'examName': 'Quiz',
      'examType': 'Quiz',
      'dateTime': DateTime.now().add(const Duration(days: 2, hours: 10)),
      'duration': '1 hour',
      'venue': 'Room 105',
      'totalMarks': 25,
      'isFirstHalf': true,
    },
    {
      'id': '5',
      'subject': 'Computer Science',
      'examName': 'Final Exam',
      'examType': 'Final',
      'dateTime': DateTime.now().add(const Duration(days: 30, hours: 9)),
      'duration': '3 hours',
      'venue': 'Computer Lab',
      'totalMarks': 100,
      'isFirstHalf': true,
    },
  ];

  List<Map<String, dynamic>> get _filteredExams {
    final now = DateTime.now();
    final upcomingExams = _exams.where((exam) {
      final examDate = exam['dateTime'] as DateTime;
      return examDate.isAfter(now);
    }).toList();

    upcomingExams.sort((a, b) {
      final dateA = a['dateTime'] as DateTime;
      final dateB = b['dateTime'] as DateTime;
      return dateA.compareTo(dateB);
    });

    if (_selectedFilter == 'All') {
      return upcomingExams;
    }
    return upcomingExams
        .where((exam) => exam['examType'] == _selectedFilter)
        .toList();
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
      case 'unit test':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getTimeRemaining(DateTime examDate) {
    final now = DateTime.now();
    final difference = examDate.difference(now);

    if (difference.isNegative) {
      return 'Exam passed';
    }

    final days = difference.inDays;
    final hours = difference.inHours % 24;

    if (days == 0) {
      if (hours == 0) {
        final minutes = difference.inMinutes;
        return 'In $minutes minute${minutes > 1 ? 's' : ''}';
      }
      return 'In $hours hour${hours > 1 ? 's' : ''}';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Timetable'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_outlined),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.assessment_outlined),
            onPressed: () => Get.toNamed(AppRoutes.studentResults),
            tooltip: 'View Results',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Get.toNamed(AppRoutes.studentNotifications),
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.secondaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  context,
                  Icons.event_outlined,
                  '${_filteredExams.length}',
                  'Upcoming',
                  theme.colorScheme.primary,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
                _buildSummaryItem(
                  context,
                  Icons.schedule,
                  _filteredExams.isNotEmpty
                      ? _getTimeRemaining(
                          _filteredExams.first['dateTime'] as DateTime)
                      : 'N/A',
                  'Next Exam',
                  Colors.orange,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
                _buildSummaryItem(
                  context,
                  Icons.calendar_month,
                  _filteredExams.isNotEmpty
                      ? DateFormat('MMM dd')
                          .format(_filteredExams.first['dateTime'] as DateTime)
                      : 'N/A',
                  'Date',
                  Colors.green,
                ),
              ],
            ),
          ),

          // Exams Table
          Expanded(
            child: _filteredExams.isEmpty
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
                                  .withOpacity(0.5),
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
                              DataColumn(label: Text('Venue')),
                              DataColumn(label: Text('Type')),
                              DataColumn(label: Text('Marks')),
                              DataColumn(label: Text('Status')),
                            ],
                            rows: _filteredExams.map((exam) {
                              final subject = exam['subject'] as String;
                              final examType = exam['examType'] as String;
                              final examDate = exam['dateTime'] as DateTime;
                              final subjectColor = _getSubjectColor(subject);
                              final typeColor = _getExamTypeColor(examType);
                              final timeRemaining = _getTimeRemaining(examDate);
                              final isUrgent =
                                  examDate.difference(DateTime.now()).inDays <
                                      3;

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
                                            color:
                                                subjectColor.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            _getSubjectIcon(subject),
                                            color: subjectColor,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          subject,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Date
                                  DataCell(
                                    Text(
                                      DateFormat('MMM dd, yyyy')
                                          .format(examDate),
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                  // Time
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 16,
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          DateFormat('hh:mm a')
                                              .format(examDate),
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Duration
                                  DataCell(
                                    Text(
                                      exam['duration'] as String,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                  // Venue
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          size: 16,
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          exam['venue'] as String,
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Type
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: typeColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        examType,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: typeColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Marks
                                  DataCell(
                                    Text(
                                      '${exam['totalMarks']}',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  // Status
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isUrgent
                                            ? Colors.red.withOpacity(0.1)
                                            : Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isUrgent
                                              ? Colors.red.withOpacity(0.3)
                                              : Colors.green.withOpacity(0.3),
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
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Exam Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _filters.map((filter) {
            return RadioListTile<String>(
              title: Text(filter),
              value: filter,
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
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

  void _showExamDetails(BuildContext context, Map<String, dynamic> exam) {
    final theme = Theme.of(context);
    final subject = exam['subject'] as String;
    final subjectColor = _getSubjectColor(subject);
    final examDate = exam['dateTime'] as DateTime;

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
            // Handle bar
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
                    color: subjectColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getSubjectIcon(subject),
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
                        subject,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        exam['examName'] as String,
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

            // Details
            _buildDetailRow(
              context,
              Icons.calendar_today,
              'Date',
              DateFormat('EEEE, MMMM dd, yyyy').format(examDate),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              Icons.access_time,
              'Time',
              DateFormat('hh:mm a').format(examDate),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              Icons.timelapse,
              'Duration',
              exam['duration'] as String,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              Icons.location_on_outlined,
              'Venue',
              exam['venue'] as String,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              Icons.grade_outlined,
              'Total Marks',
              '${exam['totalMarks']}',
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              Icons.category_outlined,
              'Exam Type',
              exam['examType'] as String,
            ),

            const SizedBox(height: 24),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Add to calendar
                },
                icon: const Icon(Icons.calendar_month),
                label: const Text('Add to Calendar'),
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
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
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
