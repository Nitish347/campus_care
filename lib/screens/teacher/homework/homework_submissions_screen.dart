import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/models/homework_model.dart';
import 'package:campus_care/models/homework_submission_model.dart';
import 'package:campus_care/controllers/homework_controller.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';

class HomeworkSubmissionsScreen extends StatefulWidget {
  final HomeWorkModel homework;

  const HomeworkSubmissionsScreen({
    super.key,
    required this.homework,
  });

  @override
  State<HomeworkSubmissionsScreen> createState() =>
      _HomeworkSubmissionsScreenState();
}

class _HomeworkSubmissionsScreenState extends State<HomeworkSubmissionsScreen> {
  final HomeworkController _homeworkController = Get.put(HomeworkController());
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Submitted', 'Pending', 'Graded'];

  // Static student data for demonstration
  final List<Map<String, dynamic>> _students = List.generate(5, (index) {
    return {
      'id': 'student${index + 1}',
      'name': 'Student ${index + 1}',
      'studentId': 'STU2024${(index + 1).toString().padLeft(3, '0')}',
      'avatar': null,
    };
  });

  List<Map<String, dynamic>> get _filteredStudents {
    final submissions =
        _homeworkController.getHomeworkSubmissions(widget.homework.id);

    if (_selectedFilter == 'All') {
      return _students;
    }

    return _students.where((student) {
      final submission = submissions.firstWhereOrNull(
        (sub) => sub.studentId == student['id'],
      );

      if (submission == null) {
        return _selectedFilter == 'Pending';
      }

      switch (_selectedFilter) {
        case 'Submitted':
          return submission.isSubmitted && !submission.isGraded;
        case 'Pending':
          return submission.isPending;
        case 'Graded':
          return submission.isGraded;
        default:
          return true;
      }
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'graded':
        return Colors.green;
      case 'submitted':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'graded':
        return Icons.check_circle;
      case 'submitted':
        return Icons.upload_file;
      case 'pending':
        return Icons.pending;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = _homeworkController.getSubmissionStats(widget.homework.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Homework Submissions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_outlined),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          // Homework Info Card
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.homework.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.homework.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${DateFormat('MMM dd, yyyy').format(widget.homework.dueDate)}',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.class_,
                        size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Class ${widget.homework.classId} - ${widget.homework.section}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Statistics Summary
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  Icons.people_outline,
                  '${stats['total']}',
                  'Total',
                  theme.colorScheme.primary,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
                _buildStatItem(
                  context,
                  Icons.upload_file,
                  '${stats['submitted']}',
                  'Submitted',
                  Colors.blue,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
                _buildStatItem(
                  context,
                  Icons.check_circle_outline,
                  '${stats['graded']}',
                  'Graded',
                  Colors.green,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
                _buildStatItem(
                  context,
                  Icons.pending_outlined,
                  '${stats['pending']}',
                  'Pending',
                  Colors.orange,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Student List
          Expanded(
            child: _filteredStudents.isEmpty
                ? EmptyState(
                    icon: Icons.people_outline,
                    title: 'No students found',
                    message: _selectedFilter == 'All'
                        ? 'No students in this class'
                        : 'No students with $_selectedFilter status',
                  )
                : ResponsivePadding(
                    child: Obx(() {
                      final submissions = _homeworkController.submissions;
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = _filteredStudents[index];
                          final submission = submissions.firstWhereOrNull(
                            (sub) =>
                                sub.homeworkId == widget.homework.id &&
                                sub.studentId == student['id'],
                          );

                          return _buildStudentCard(
                            context,
                            student,
                            submission,
                          );
                        },
                      );
                    }),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
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

  Widget _buildStudentCard(
    BuildContext context,
    Map<String, dynamic> student,
    HomeworkSubmission? submission,
  ) {
    final theme = Theme.of(context);
    final status = submission?.status ?? 'pending';
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigate to student homework detail
          _navigateToStudentDetail(student, submission);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  (student['name'] as String).substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Student Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student['name'] as String,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${student['studentId']}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (submission?.submittedAt != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Submitted: ${DateFormat('MMM dd, hh:mm a').format(submission!.submittedAt!)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Status and Marks
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          status.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (submission?.isGraded == true) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${submission!.marksObtained}/${widget.homework.totalMarks}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Status'),
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

  void _navigateToStudentDetail(
    Map<String, dynamic> student,
    HomeworkSubmission? submission,
  ) {
    Get.toNamed(
      AppRoutes.studentHomeworkDetail,
      arguments: {
        'homework': widget.homework,
        'student': student,
        'submission': submission,
      },
    );
  }
}
