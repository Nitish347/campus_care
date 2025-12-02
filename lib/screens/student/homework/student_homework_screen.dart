import 'package:campus_care/widgets/common/summary_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';

class StudentHomeworkScreen extends StatefulWidget {
  const StudentHomeworkScreen({super.key});

  @override
  State<StudentHomeworkScreen> createState() => _StudentHomeworkScreenState();
}

class _StudentHomeworkScreenState extends State<StudentHomeworkScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Mathematics',
    'Science',
    'English',
    'History'
  ];

  // Enhanced static UI data with more details
  static final _activeHomework = [
    {
      'id': '1',
      'title': 'Math Assignment - Algebra',
      'description':
          'Complete exercises 1-20 from chapter 5. Focus on quadratic equations and factorization.',
      'subject': 'Mathematics',
      'dueDate': DateTime.now().add(const Duration(days: 3)),
      'priority': 'high',
      'progress': 0.6,
      'totalQuestions': 20,
      'completedQuestions': 12,
      'attachments': 2,
      'teacher': 'Mr. Brown',
    },
    {
      'id': '2',
      'title': 'Science Project - Photosynthesis',
      'description':
          'Create a detailed presentation on the photosynthesis process with diagrams.',
      'subject': 'Science',
      'dueDate': DateTime.now().add(const Duration(days: 7)),
      'priority': 'medium',
      'progress': 0.3,
      'totalQuestions': 1,
      'completedQuestions': 0,
      'attachments': 1,
      'teacher': 'Ms. Johnson',
    },
    {
      'id': '3',
      'title': 'English Essay - My Favorite Book',
      'description':
          'Write a 500-word essay about your favorite book and explain why you like it.',
      'subject': 'English',
      'dueDate': DateTime.now().add(const Duration(days: 5)),
      'priority': 'medium',
      'progress': 0.8,
      'totalQuestions': 1,
      'completedQuestions': 0,
      'attachments': 0,
      'teacher': 'Ms. Smith',
    },
    {
      'id': '4',
      'title': 'History Timeline',
      'description': 'Create a timeline of major events in World War II.',
      'subject': 'History',
      'dueDate': DateTime.now().add(const Duration(days: 2)),
      'priority': 'high',
      'progress': 0.4,
      'totalQuestions': 1,
      'completedQuestions': 0,
      'attachments': 3,
      'teacher': 'Mr. Davis',
    },
  ];

  static final _completedHomework = [
    {
      'id': '5',
      'title': 'History Assignment - Ancient Civilizations',
      'description':
          'Complete chapter 3 questions about ancient civilizations.',
      'subject': 'History',
      'dueDate': DateTime.now().subtract(const Duration(days: 5)),
      'completedDate': DateTime.now().subtract(const Duration(days: 6)),
      'priority': 'medium',
      'progress': 1.0,
      'grade': 'A',
      'teacher': 'Mr. Davis',
    },
    {
      'id': '6',
      'title': 'Math Quiz - Geometry',
      'description': 'Complete the geometry quiz from chapter 4.',
      'subject': 'Mathematics',
      'dueDate': DateTime.now().subtract(const Duration(days: 3)),
      'completedDate': DateTime.now().subtract(const Duration(days: 4)),
      'priority': 'low',
      'progress': 1.0,
      'grade': 'B+',
      'teacher': 'Mr. Brown',
    },
  ];

  static final _overdueHomework = [
    {
      'id': '7',
      'title': 'Geography Project - World Map',
      'description': 'Create a detailed map of continents with labels.',
      'subject': 'Geography',
      'dueDate': DateTime.now().subtract(const Duration(days: 2)),
      'priority': 'high',
      'progress': 0.2,
      'totalQuestions': 1,
      'completedQuestions': 0,
      'teacher': 'Ms. Anderson',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getPriorityColor(String priority, ThemeData theme) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return theme.colorScheme.primary;
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
      case 'geography':
        return Icons.public_outlined;
      default:
        return Icons.assignment_outlined;
    }
  }

  Color _getSubjectColor(String subject, ThemeData theme) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
        return Colors.blue;
      case 'science':
        return Colors.green;
      case 'english':
        return Colors.purple;
      case 'history':
        return Colors.brown;
      case 'geography':
        return Colors.teal;
      default:
        return theme.colorScheme.primary;
    }
  }

  String _getTimeRemaining(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.isNegative) {
      final days = difference.inDays.abs();
      return days == 0
          ? 'Overdue today'
          : 'Overdue by $days day${days > 1 ? 's' : ''}';
    }

    final days = difference.inDays;
    final hours = difference.inHours % 24;

    if (days == 0) {
      return hours == 0
          ? 'Due soon'
          : 'Due in $hours hour${hours > 1 ? 's' : ''}';
    } else if (days == 1) {
      return 'Due tomorrow';
    } else {
      return 'Due in $days days';
    }
  }

  List<Map<String, dynamic>> _filterHomework(
      List<Map<String, dynamic>> homework) {
    if (_selectedFilter == 'All') return homework;
    return homework.where((hw) => hw['subject'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Homework'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_outlined),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Get.toNamed(AppRoutes.studentNotifications),
            tooltip: 'Notifications',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Active'),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_filterHomework(_activeHomework).length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Completed'),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_filterHomework(_completedHomework).length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Overdue'),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_filterHomework(_overdueHomework).length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary Stats Card
          SummaryCard(child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  Icons.assignment_outlined,
                  '${_activeHomework.length}',
                  'Active',
                  theme.colorScheme.primary,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
                _buildStatItem(
                  context,
                  Icons.check_circle_outline,
                  '${_completedHomework.length}',
                  'Completed',
                  Colors.green,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
                _buildStatItem(
                  context,
                  Icons.warning_amber_outlined,
                  '${_overdueHomework.length}',
                  'Overdue',
                  Colors.red,
                ),
              ],
            ),
          ),

          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHomeworkList(
                    context, _filterHomework(_activeHomework), 'active'),
                _buildHomeworkList(
                    context, _filterHomework(_completedHomework), 'completed'),
                _buildHomeworkList(
                    context, _filterHomework(_overdueHomework), 'overdue'),
              ],
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
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
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

  Widget _buildHomeworkList(
    BuildContext context,
    List<Map<String, dynamic>> homework,
    String type,
  ) {
    final theme = Theme.of(context);

    if (homework.isEmpty) {
      String message;
      switch (type) {
        case 'overdue':
          message = 'Great! You have no overdue homework';
          break;
        case 'completed':
          message = 'No completed homework yet';
          break;
        default:
          message = 'You\'re all caught up!';
      }

      return EmptyState(
        icon: Icons.assignment_outlined,
        title: 'No homework',
        message: message,
      );
    }

    return ResponsivePadding(
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: homework.length,
        itemBuilder: (context, index) {
          final hw = homework[index];
          return _buildHomeworkCard(context, hw, type);
        },
      ),
    );
  }

  Widget _buildHomeworkCard(
    BuildContext context,
    Map<String, dynamic> hw,
    String type,
  ) {
    final theme = Theme.of(context);
    final dueDate = hw['dueDate'] as DateTime;
    final subject = hw['subject'] as String;
    final priority = hw['priority'] as String;
    final subjectColor = _getSubjectColor(subject, theme);
    final priorityColor = _getPriorityColor(priority, theme);
    final isOverdue = type == 'overdue';
    final isCompleted = type == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isOverdue
                ? Colors.red.withOpacity(0.3)
                : theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showHomeworkDetails(context, hw, type),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Subject Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: subjectColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getSubjectIcon(subject),
                        color: subjectColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title and Subject
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hw['title'] as String,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: subjectColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  subject,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: subjectColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (!isCompleted)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: priorityColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.flag,
                                        size: 12,
                                        color: priorityColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        priority.toUpperCase(),
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: priorityColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Grade badge for completed
                    if (isCompleted && hw['grade'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          hw['grade'] as String,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  hw['description'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // Progress bar for active homework
                if (!isCompleted && hw['progress'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${((hw['progress'] as double) * 100).toInt()}%',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: subjectColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: hw['progress'] as double,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(subjectColor),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),

                // Footer Row
                Row(
                  children: [
                    // Teacher
                    if (hw['teacher'] != null)
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                hw['teacher'] as String,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Attachments
                    if (!isCompleted &&
                        hw['attachments'] != null &&
                        hw['attachments'] > 0)
                      Row(
                        children: [
                          Icon(
                            Icons.attach_file,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${hw['attachments']}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),

                    // Due date
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isOverdue
                            ? Colors.red.withOpacity(0.1)
                            : isCompleted
                                ? Colors.green.withOpacity(0.1)
                                : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCompleted ? Icons.check_circle : Icons.schedule,
                            size: 14,
                            color: isOverdue
                                ? Colors.red
                                : isCompleted
                                    ? Colors.green
                                    : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isCompleted
                                ? 'Completed'
                                : _getTimeRemaining(dueDate),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isOverdue
                                  ? Colors.red
                                  : isCompleted
                                      ? Colors.green
                                      : theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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

  void _showHomeworkDetails(
    BuildContext context,
    Map<String, dynamic> hw,
    String type,
  ) {
    final theme = Theme.of(context);
    final subject = hw['subject'] as String;
    final subjectColor = _getSubjectColor(subject, theme);
    final isCompleted = type == 'completed';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
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
                          hw['title'] as String,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          subject,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: subjectColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Description
              Text(
                'Description',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hw['description'] as String,
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 24),

              // Details
              _buildDetailRow(
                context,
                Icons.person_outline,
                'Teacher',
                hw['teacher'] as String,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                context,
                Icons.calendar_today,
                'Due Date',
                DateFormat('MMMM dd, yyyy - hh:mm a')
                    .format(hw['dueDate'] as DateTime),
              ),
              if (isCompleted) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  context,
                  Icons.check_circle,
                  'Completed On',
                  DateFormat('MMMM dd, yyyy')
                      .format(hw['completedDate'] as DateTime),
                ),
                if (hw['grade'] != null) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    Icons.grade,
                    'Grade',
                    hw['grade'] as String,
                  ),
                ],
              ],

              if (!isCompleted) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  context,
                  Icons.flag,
                  'Priority',
                  (hw['priority'] as String).toUpperCase(),
                ),
                if (hw['attachments'] != null && hw['attachments'] > 0) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    Icons.attach_file,
                    'Attachments',
                    '${hw['attachments']} file${hw['attachments'] > 1 ? 's' : ''}',
                  ),
                ],
              ],

              const SizedBox(height: 24),

              // Action buttons
              if (!isCompleted)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Mark as complete
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Mark Complete'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Start homework
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Start Work'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
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
