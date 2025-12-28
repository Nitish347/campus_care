import 'package:campus_care/widgets/common/summary_card.dart';
import 'package:campus_care/widgets/inputs/class_section_dropdown.dart';
import 'package:campus_care/widgets/inputs/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/models/homework_model.dart';
import 'package:campus_care/screens/teacher/homework/add_edit_homework_screen.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';

class TeacherHomeworkManagementScreen extends StatefulWidget {
  const TeacherHomeworkManagementScreen({super.key});

  @override
  State<TeacherHomeworkManagementScreen> createState() => _TeacherHomeworkManagementScreenState();
}

class _TeacherHomeworkManagementScreenState extends State<TeacherHomeworkManagementScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Mathematics', 'Science', 'English'];

  // Static homework data using HomeWorkModel
  final List<HomeWorkModel> _homework = [
    HomeWorkModel(
      id: '1',
      title: 'Math Assignment - Chapter 5',
      description: 'Complete exercises 1-20 from textbook',
      subject: 'Mathematics',
      teacherId: 'teacher1',
      classId: 'class_5a',
      section: 'A',
      assignedStudents: ['student1', 'student2', 'student3'],
      dueDate: DateTime.now().add(const Duration(days: 3)),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      priority: 'high',
      totalMarks: 20,
      attachments: ['worksheet.pdf'],
    ),
    HomeWorkModel(
      id: '2',
      title: 'Science Project',
      description: 'Prepare a model on solar system',
      subject: 'Science',
      teacherId: 'teacher1',
      classId: 'class_5a',
      section: 'A',
      assignedStudents: ['student1', 'student2'],
      dueDate: DateTime.now().add(const Duration(days: 7)),
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      priority: 'medium',
      totalMarks: 30,
    ),
    HomeWorkModel(
      id: '3',
      title: 'English Essay',
      description: 'Write an essay on environmental conservation',
      subject: 'English',
      teacherId: 'teacher1',
      classId: 'class_5b',
      section: 'B',
      assignedStudents: ['student1', 'student2', 'student3', 'student4'],
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      priority: 'high',
      totalMarks: 25,
    ),
  ];

  List<HomeWorkModel> get _filteredHomework {
    if (_selectedFilter == 'All') {
      return _homework;
    }
    return _homework.where((hw) => hw.subject == _selectedFilter).toList();
  }

  String _getStatus(DateTime dueDate) {
    final now = DateTime.now();
    if (dueDate.isBefore(now)) {
      return 'Overdue';
    } else if (dueDate.difference(now).inDays <= 2) {
      return 'Due Soon';
    }
    return 'Active';
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'due soon':
        return Colors.blue;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overdueCount = _homework.where((h) => _getStatus(h.dueDate) == 'Overdue').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Homework'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_outlined),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
            tooltip: 'Search',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHomeworkDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Homework'),
      ),
      body: Column(
        children: [
        ClassSectionDropDown(onChangedClass: (String classId) {  }, onChangedSection: (String classId) {  },),

          // Summary Header
          SummaryCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  context,
                  Icons.assignment_outlined,
                  '${_homework.length}',
                  'Total',
                  theme.colorScheme.primary,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
                _buildSummaryItem(
                  context,
                  Icons.pending_actions,
                  '${_homework.where((h) => _getStatus(h.dueDate) == 'Active').length}',
                  'Active',
                  Colors.blue,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
                _buildSummaryItem(
                  context,
                  Icons.warning_amber,
                  '$overdueCount',
                  'Overdue',
                  Colors.red,
                ),
              ],
            ),
          ),

          // Homework List
          Expanded(
            child: _filteredHomework.isEmpty
                ? EmptyState(
                    icon: Icons.assignment_outlined,
                    title: 'No homework',
                    message: _selectedFilter == 'All'
                        ? 'No homework assignments created yet'
                        : 'No homework found for $_selectedFilter',
                  )
                : ResponsivePadding(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: _filteredHomework.length,
                      itemBuilder: (context, index) {
                        final homework = _filteredHomework[index];
                        final subjectColor = _getSubjectColor(homework.subject);
                        final status = _getStatus(homework.dueDate);
                        final statusColor = _getStatusColor(status);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: theme.colorScheme.outlineVariant,
                              width: 1,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _showHomeworkDetails(context, homework),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header Row
                                  Row(
                                    children: [
                                      // Subject Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: subjectColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          homework.subject,
                                          style: theme.textTheme.labelMedium?.copyWith(
                                            color: subjectColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Priority Badge
                                      if (homework.priority case final priority?)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: homework.priority == 'high'
                                                ? Colors.red.withOpacity(0.1)
                                                : homework.priority == 'medium'
                                                    ? Colors.orange.withOpacity(0.1)
                                                    : Colors.blue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            priority.toUpperCase(),
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: homework.priority == 'high'
                                                  ? Colors.red
                                                  : homework.priority == 'medium'
                                                      ? Colors.orange
                                                      : Colors.blue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      const Spacer(),
                                      // Status Badge
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
                                        child: Text(
                                          status,
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: statusColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Title and Description
                                  Text(
                                    homework.title,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    homework.description,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 12),

                                  // Info Row
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat('MMM dd, yyyy - hh:mm a').format(homework.dueDate),
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(
                                        Icons.class_,
                                        size: 16,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${homework.classId} - ${homework.section}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Bottom Row - Students and Actions
                                  Row(
                                    children: [
                                      // Students Count
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.people,
                                              size: 16,
                                              color: theme.colorScheme.primary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${homework.assignedStudents.length} Students',
                                              style: theme.textTheme.labelMedium?.copyWith(
                                                color: theme.colorScheme.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (homework.totalMarks != null) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.purple.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.grade,
                                                size: 16,
                                                color: Colors.purple,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${homework.totalMarks} Marks',
                                                style: theme.textTheme.labelMedium?.copyWith(
                                                  color: Colors.purple,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      const Spacer(),
                                      // Action Buttons
                                      IconButton(
                                        icon: const Icon(Icons.visibility_outlined),
                                        iconSize: 20,
                                        onPressed: () => Get.toNamed(
                                          AppRoutes.homeworkSubmissions,
                                          arguments: homework,
                                        ),
                                        tooltip: 'View Submissions',
                                        color: theme.colorScheme.primary,
                                      ),
                                      // IconButton(
                                      //   icon: const Icon(Icons.edit_outlined),
                                      //   iconSize: 20,
                                      //   onPressed: () =>
                                      //       _showEditHomeworkDialog(
                                      //           context, homework),
                                      //   tooltip: 'Edit',
                                      //   color: theme.colorScheme.primary,
                                      // ),
                                      // IconButton(
                                      //   icon: const Icon(Icons.delete_outline),
                                      //   iconSize: 20,
                                      //   color: theme.colorScheme.error,
                                      //   onPressed: () =>
                                      //       _showDeleteConfirmation(
                                      //           context, homework),
                                      //   tooltip: 'Delete',
                                      // ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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
          style: theme.textTheme.titleLarge?.copyWith(
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Subject'),
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

  void _showHomeworkDetails(BuildContext context, HomeWorkModel homework) {
    final theme = Theme.of(context);
    final subjectColor = _getSubjectColor(homework.subject);

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
            Text(
              homework.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: subjectColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                homework.subject,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: subjectColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Description
            Text(
              'Description',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              homework.description,
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 24),

            // Details
            Row(
              children: [
                Icon(Icons.calendar_today, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Due: ${DateFormat('EEEE, MMMM dd, yyyy - hh:mm a').format(homework.dueDate)}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.people, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Assigned to ${homework.assignedStudents.length} students',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showEditHomeworkDialog(context, homework);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showDeleteConfirmation(context, homework);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAddHomeworkDialog(BuildContext context) {
    Get.to(() => const AddEditHomeworkScreen());
  }

  void _showEditHomeworkDialog(BuildContext context, HomeWorkModel homework) {
    Get.to(() => AddEditHomeworkScreen(homework: homework));
  }

  void _showDeleteConfirmation(BuildContext context, HomeWorkModel homework) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Homework'),
        content: Text('Are you sure you want to delete "${homework.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Implement delete
              Navigator.pop(context);
              Get.snackbar(
                'Success',
                'Homework deleted successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
