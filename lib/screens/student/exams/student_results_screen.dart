import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/models/exam_result_model.dart';
import 'package:campus_care/services/api/exam_result_api_service.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/common/summary_card.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/student/student_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StudentResultsScreen extends StatefulWidget {
  const StudentResultsScreen({super.key});

  @override
  State<StudentResultsScreen> createState() => _StudentResultsScreenState();
}

class _StudentResultsScreenState extends State<StudentResultsScreen> {
  final ExamResultApiService _examResultApi = ExamResultApiService();
  final AuthController _authController = Get.find<AuthController>();

  bool _isLoading = true;
  List<ExamResult> _results = [];
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    final student = _authController.currentStudent;
    if (student == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      setState(() => _isLoading = true);
      final data = await _examResultApi.getExamResults(studentId: student.id);
      final results = data
          .whereType<Map>()
          .map((e) => ExamResult.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      results.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      if (!mounted) return;
      setState(() => _results = results);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<String> get _filters {
    final subjects = _results.map((e) => e.subject).where((s) => s.isNotEmpty).toSet().toList()
      ..sort();
    return ['All', ...subjects];
  }

  List<ExamResult> get _filteredResults {
    if (_selectedFilter == 'All') return _results;
    return _results.where((r) => r.subject == _selectedFilter).toList();
  }

  double get _averagePercentage {
    if (_results.isEmpty) return 0;
    final sum = _results.fold<double>(0, (acc, r) => acc + r.percentage);
    return sum / _results.length;
  }

  String get _bestSubject {
    if (_results.isEmpty) return 'N/A';
    final sorted = [..._results]..sort((a, b) => b.percentage.compareTo(a.percentage));
    return sorted.first.subject;
  }

  Color _gradeColor(String grade) {
    if (grade == 'A+' || grade == 'A') return Colors.green;
    if (grade == 'B+' || grade == 'B') return Colors.blue;
    if (grade == 'C+' || grade == 'C') return Colors.orange;
    return Colors.red;
  }

  IconData _subjectIcon(String subject) {
    final s = subject.toLowerCase();
    if (s.contains('math')) return Icons.calculate_outlined;
    if (s.contains('science')) return Icons.science_outlined;
    if (s.contains('english')) return Icons.menu_book_outlined;
    if (s.contains('history')) return Icons.history_edu_outlined;
    if (s.contains('computer')) return Icons.computer_outlined;
    return Icons.book_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: StudentAppBar(
        title: 'Exam Results',
        extraActions: [
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
              child: const Icon(Icons.filter_list_outlined, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _loadResults,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.refresh, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SummaryCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _summaryItem(
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
                      _summaryItem(
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
                      _summaryItem(
                        context,
                        Icons.star_outline,
                        _bestSubject,
                        'Best Subject',
                        Colors.orange,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _filteredResults.isEmpty
                      ? const EmptyState(
                          icon: Icons.assessment_outlined,
                          title: 'No results',
                          message: 'No exam results available',
                        )
                      : ResponsivePadding(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            itemCount: _filteredResults.length,
                            itemBuilder: (context, index) {
                              final result = _filteredResults[index];
                              final grade = result.calculatedGrade;
                              final gradeColor = _gradeColor(grade);
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: gradeColor.withOpacity(0.1),
                                    child: Icon(_subjectIcon(result.subject), color: gradeColor),
                                  ),
                                  title: Text(result.subject),
                                  subtitle: Text(
                                    '${result.marks.toStringAsFixed(0)} / ${result.totalMarks.toStringAsFixed(0)}'
                                    '   ${DateFormat('MMM dd, yyyy').format(result.updatedAt)}',
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        grade,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          color: gradeColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${result.percentage.toStringAsFixed(1)}%',
                                        style: theme.textTheme.labelSmall,
                                      ),
                                    ],
                                  ),
                                  onTap: () => _showResultDetails(context, result),
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

  Widget _summaryItem(
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
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
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
                setState(() => _selectedFilter = value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showResultDetails(BuildContext context, ExamResult result) {
    final theme = Theme.of(context);
    final grade = result.calculatedGrade;
    final gradeColor = _gradeColor(grade);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.subject,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text('Marks: ${result.marks.toStringAsFixed(0)} / ${result.totalMarks.toStringAsFixed(0)}'),
            const SizedBox(height: 8),
            Text('Grade: $grade', style: TextStyle(color: gradeColor)),
            const SizedBox(height: 8),
            Text('Percentage: ${result.percentage.toStringAsFixed(1)}%'),
            const SizedBox(height: 8),
            Text('Updated: ${DateFormat('MMMM dd, yyyy').format(result.updatedAt)}'),
            if ((result.remarks ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(result.remarks!),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
