import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/models/exam_result_model.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';

class StudentResultsScreen extends StatefulWidget {
  const StudentResultsScreen({super.key});

  @override
  State<StudentResultsScreen> createState() => _StudentResultsScreenState();
}

class _StudentResultsScreenState extends State<StudentResultsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Mathematics',
    'Science',
    'English',
    'History'
  ];

  // Static results data
  final List<ExamResult> _results = [
    ExamResult(
      id: '1',
      studentId: 'student1',
      examId: 'exam1',
      subject: 'Mathematics',
      marks: 85,
      totalMarks: 100,
      grade: 'A',
      remarks: 'Excellent performance in algebra and geometry sections.',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    ExamResult(
      id: '2',
      studentId: 'student1',
      examId: 'exam2',
      subject: 'Science',
      marks: 92,
      totalMarks: 100,
      grade: 'A+',
      remarks: 'Outstanding work on the practical experiments.',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    ExamResult(
      id: '3',
      studentId: 'student1',
      examId: 'exam3',
      subject: 'English',
      marks: 78,
      totalMarks: 100,
      grade: 'B+',
      remarks: 'Good essay writing skills. Work on grammar.',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    ExamResult(
      id: '4',
      studentId: 'student1',
      examId: 'exam4',
      subject: 'History',
      marks: 88,
      totalMarks: 100,
      grade: 'A',
      remarks: 'Comprehensive understanding of historical events.',
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      updatedAt: DateTime.now().subtract(const Duration(days: 25)),
    ),
    ExamResult(
      id: '5',
      studentId: 'student1',
      examId: 'exam5',
      subject: 'Computer Science',
      marks: 95,
      totalMarks: 100,
      grade: 'A+',
      remarks: 'Exceptional programming skills and problem-solving ability.',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];

  List<ExamResult> get _filteredResults {
    if (_selectedFilter == 'All') {
      return _results;
    }
    return _results
        .where((result) => result.subject == _selectedFilter)
        .toList();
  }

  double get _averagePercentage {
    if (_results.isEmpty) return 0;
    final total =
        _results.fold<double>(0, (sum, result) => sum + result.percentage);
    return total / _results.length;
  }

  String get _bestSubject {
    if (_results.isEmpty) return 'N/A';
    final sorted = [..._results]
      ..sort((a, b) => b.percentage.compareTo(a.percentage));
    return sorted.first.subject;
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

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return Colors.green;
      case 'B+':
      case 'B':
        return Colors.blue;
      case 'C+':
      case 'C':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Results'),
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
                  Icons.assessment_outlined,
                  '${_results.length}',
                  'Total Exams',
                  theme.colorScheme.primary,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
                _buildSummaryItem(
                  context,
                  Icons.trending_up,
                  '${_averagePercentage.toStringAsFixed(1)}%',
                  'Average',
                  Colors.green,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
                _buildSummaryItem(
                  context,
                  Icons.star_outline,
                  _bestSubject,
                  'Best Subject',
                  Colors.orange,
                ),
              ],
            ),
          ),

          // Results List
          Expanded(
            child: _filteredResults.isEmpty
                ? EmptyState(
                    icon: Icons.assessment_outlined,
                    title: 'No results',
                    message: _selectedFilter == 'All'
                        ? 'No exam results available'
                        : 'No results found for $_selectedFilter',
                  )
                : ResponsivePadding(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: _filteredResults.length,
                      itemBuilder: (context, index) {
                        final result = _filteredResults[index];
                        return _buildResultCard(context, result);
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
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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

  Widget _buildResultCard(BuildContext context, ExamResult result) {
    final theme = Theme.of(context);
    final subjectColor = _getSubjectColor(result.subject);
    final gradeColor = _getGradeColor(result.calculatedGrade);
    final percentage = result.percentage;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
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
          onTap: () => _showResultDetails(context, result),
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: subjectColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getSubjectIcon(result.subject),
                        color: subjectColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Subject Name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result.subject,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMM dd, yyyy').format(result.createdAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Grade Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: gradeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: gradeColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        result.calculatedGrade,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: gradeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Marks Display
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Marks Obtained',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${result.marks.toInt()}',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: subjectColor,
                                ),
                              ),
                              Text(
                                ' / ${result.totalMarks.toInt()}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            'Percentage',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(gradeColor),
                    minHeight: 8,
                  ),
                ),

                if (result.remarks != null && result.remarks!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            result.remarks!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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

  void _showResultDetails(BuildContext context, ExamResult result) {
    final theme = Theme.of(context);
    final subjectColor = _getSubjectColor(result.subject);
    final gradeColor = _getGradeColor(result.calculatedGrade);

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
                    _getSubjectIcon(result.subject),
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
                        result.subject,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Exam Result',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: gradeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: gradeColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    result.calculatedGrade,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: gradeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Score Display
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    subjectColor.withOpacity(0.1),
                    subjectColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '${result.marks.toInt()}',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: subjectColor,
                        ),
                      ),
                      Text(
                        'Marks Obtained',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 60,
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                  Column(
                    children: [
                      Text(
                        '${result.totalMarks.toInt()}',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'Total Marks',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 60,
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                  Column(
                    children: [
                      Text(
                        '${result.percentage.toStringAsFixed(1)}%',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: gradeColor,
                        ),
                      ),
                      Text(
                        'Percentage',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Details
            _buildDetailRow(
              context,
              Icons.calendar_today,
              'Exam Date',
              DateFormat('MMMM dd, yyyy').format(result.createdAt),
            ),

            if (result.remarks != null && result.remarks!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Teacher\'s Remarks',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  result.remarks!,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],

            const SizedBox(height: 24),
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
