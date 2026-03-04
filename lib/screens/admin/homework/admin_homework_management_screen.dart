import 'package:campus_care/widgets/common/summary_card.dart';
import 'package:campus_care/widgets/inputs/class_section_dropdown.dart';
import 'package:campus_care/widgets/inputs/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/models/homework_model.dart';
import 'package:campus_care/controllers/homework_controller.dart';
import 'package:campus_care/controllers/class_controller.dart';
import 'package:campus_care/controllers/subject_controller.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/screens/admin/homework/admin_add_edit_homework_screen.dart';

class AdminHomeworkManagementScreen extends StatelessWidget {
  const AdminHomeworkManagementScreen({super.key});

  /// Resolves a class ID to its display name (e.g. "Class 10").
  /// Falls back to the raw ID if the class is not found.
  String _getClassName(String classId) {
    try {
      final classController = Get.find<ClassController>();
      final match =
          classController.classes.firstWhereOrNull((c) => c.id == classId);
      return match?.name ?? classId;
    } catch (_) {
      return classId;
    }
  }

  /// Resolves a subject ID to its display name (e.g. "Mathematics").
  /// Falls back to the raw ID if not found.
  String _getSubjectName(String subjectId) {
    try {
      final subjectController = Get.find<SubjectController>();
      final match =
          subjectController.subjects.firstWhereOrNull((s) => s.id == subjectId);
      return match?.name ?? subjectId;
    } catch (_) {
      return subjectId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final HomeworkController controller = Get.put(HomeworkController());
    // Ensure class/subject controllers are ready for name lookups
    Get.put(ClassController());
    Get.put(SubjectController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Homework Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_outlined),
            onPressed: () => _showFilterDialog(context, controller),
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.clearFilters(),
            tooltip: 'Clear Filters',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHomeworkDialog(context, controller),
        icon: const Icon(Icons.add),
        label: const Text('Add Homework'),
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.3),
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Column(
              children: [
                ClassSectionDropDown(
                  onChangedClass: (classId) =>
                      controller.setClassFilter(classId),
                  onChangedSection: (section) =>
                      controller.setSectionFilter(section),
                  padding: 0,
                ),
                const SizedBox(height: 12),
                Obx(() => CustomDropdown<String>(
                      labelText: 'Subject',
                      value: controller.selectedSubject.value,
                      prefixIcon: const Icon(Icons.book),
                      items: [
                        'All',
                        'Mathematics',
                        'Science',
                        'English',
                        'History',
                        'Computer Science'
                      ]
                          .map((subject) => DropdownMenuItem(
                                value: subject,
                                child: Text(subject),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) controller.setSubjectFilter(value);
                      },
                    )),
              ],
            ),
          ),

          // Summary Header
          Obx(() {
            final filteredHomework = controller.getFilteredHomework();
            final activeCount = filteredHomework
                .where((h) => _getStatus(h.dueDate) == 'Active')
                .length;
            final overdueCount = filteredHomework
                .where((h) => _getStatus(h.dueDate) == 'Overdue')
                .length;

            return SummaryCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    theme,
                    Icons.assignment_outlined,
                    '${filteredHomework.length}',
                    'Total',
                    theme.colorScheme.primary,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                  _buildSummaryItem(
                    theme,
                    Icons.pending_actions,
                    '$activeCount',
                    'Active',
                    Colors.blue,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                  _buildSummaryItem(
                    theme,
                    Icons.warning_amber,
                    '$overdueCount',
                    'Overdue',
                    Colors.red,
                  ),
                ],
              ),
            );
          }),

          // Homework List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final filteredHomework = controller.getFilteredHomework();

              if (filteredHomework.isEmpty) {
                return EmptyState(
                  icon: Icons.assignment_outlined,
                  title: 'No homework',
                  message: controller.selectedSubject.value == 'All'
                      ? 'No homework assignments created yet'
                      : 'No homework found for ${controller.selectedSubject.value}',
                );
              }

              return ResponsivePadding(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: filteredHomework.length,
                  itemBuilder: (context, index) {
                    final homework = filteredHomework[index];
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
                        onTap: () =>
                            _showHomeworkDetails(context, homework, controller),
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
                                      _getSubjectName(homework.subject),
                                      style:
                                          theme.textTheme.labelMedium?.copyWith(
                                        color: subjectColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Priority Badge
                                  if (homework.priority.isNotEmpty)
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
                                        homework.priority.toUpperCase(),
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
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
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
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
                                    DateFormat('MMM dd, yyyy - hh:mm a')
                                        .format(homework.dueDate),
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
                                    '${_getClassName(homework.classId)} - ${homework.section}',
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
                                      color: theme.colorScheme.primaryContainer
                                          .withOpacity(0.5),
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
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
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
                                          const Icon(
                                            Icons.grade,
                                            size: 16,
                                            color: Colors.purple,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${homework.totalMarks} Marks',
                                            style: theme.textTheme.labelMedium
                                                ?.copyWith(
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
                                    icon: const Icon(Icons.edit_outlined),
                                    iconSize: 20,
                                    onPressed: () => _showEditHomeworkDialog(
                                        context, homework, controller),
                                    tooltip: 'Edit',
                                    color: theme.colorScheme.primary,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    iconSize: 20,
                                    color: theme.colorScheme.error,
                                    onPressed: () => _showDeleteConfirmation(
                                        context, homework, controller),
                                    tooltip: 'Delete',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    ThemeData theme,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
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

  void _showFilterDialog(BuildContext context, HomeworkController controller) {
    final subjects = [
      'All',
      'Mathematics',
      'Science',
      'English',
      'History',
      'Computer Science'
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Subject'),
        content: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: subjects.map((subject) {
                return RadioListTile<String>(
                  title: Text(subject),
                  value: subject,
                  groupValue: controller.selectedSubject.value,
                  onChanged: (value) {
                    if (value != null) controller.setSubjectFilter(value);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            )),
        actions: [
          TextButton(
            onPressed: () {
              controller.setSubjectFilter('All');
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

  void _showHomeworkDetails(BuildContext context, HomeWorkModel homework,
      HomeworkController controller) {
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
                Icon(Icons.calendar_today,
                    size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Due: ${DateFormat('EEEE, MMMM dd, yyyy - hh:mm a').format(homework.dueDate)}',
                    style: theme.textTheme.bodyMedium,
                  ),
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
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.class_, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Class: ${_getClassName(homework.classId)} - Section ${homework.section}',
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
                      _showEditHomeworkDialog(context, homework, controller);
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
                      _showDeleteConfirmation(context, homework, controller);
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

  void _showAddHomeworkDialog(
      BuildContext context, HomeworkController controller) {
    Get.to(() => const AdminAddEditHomeworkScreen());
  }

  void _showEditHomeworkDialog(BuildContext context, HomeWorkModel homework,
      HomeworkController controller) {
    Get.to(() => AdminAddEditHomeworkScreen(homework: homework));
  }

  void _showDeleteConfirmation(BuildContext context, HomeWorkModel homework,
      HomeworkController controller) {
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
            onPressed: () async {
              Navigator.pop(context);
              await controller.deleteHomework(homework.id);
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
