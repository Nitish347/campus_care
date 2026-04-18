import 'package:campus_care/widgets/inputs/class_section_dropdown.dart';
import 'package:campus_care/widgets/inputs/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/models/exam_model.dart';
import 'package:campus_care/controllers/exam_controller.dart';
import 'package:campus_care/controllers/exam_type_controller.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/screens/admin/exam/admin_add_edit_exam_screen.dart';

class AdminExamTimetableScreen extends StatefulWidget {
  const AdminExamTimetableScreen({super.key});

  @override
  State<AdminExamTimetableScreen> createState() =>
      _AdminExamTimetableScreenState();
}

class _AdminExamTimetableScreenState extends State<AdminExamTimetableScreen> {
  final ExamController _examController = Get.put(ExamController());
  final ExamTypeController _examTypeController = Get.put(ExamTypeController());

  String? _selectedExamTypeId;
  String? _selectedClass;
  String? _selectedSection;
  bool _isTableView = false; // Toggle between list and table view

  List<ExamModel> _getSelectedExams() {
    final exams = _examController.examList.toList();

    if (_selectedExamTypeId == null ||
        _selectedClass == null ||
        _selectedSection == null) {
      return const <ExamModel>[];
    }

    return exams
        .where((exam) =>
            exam.examTypeId == _selectedExamTypeId &&
            exam.classId == _selectedClass &&
            exam.section == _selectedSection)
        .toList();
  }

  void _openExamEditor({List<ExamModel>? existingExams}) {
    if (_selectedExamTypeId == null ||
        _selectedClass == null ||
        _selectedSection == null) {
      Get.snackbar(
        'Selection required',
        'Please select exam schedule, class and section first',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.to(
      () => AdminAddEditExamScreen(
        examTypeId: _selectedExamTypeId!,
        classId: _selectedClass!,
        section: _selectedSection!,
        existingExams: existingExams != null && existingExams.isNotEmpty
            ? existingExams
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool canAddExam = _selectedExamTypeId != null &&
        _selectedClass != null &&
        _selectedSection != null;

    return Container(
      color: Colors.transparent,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: canAddExam
                      ? () =>
                          _openExamEditor(existingExams: _getSelectedExams())
                      : null,
                  icon: const Icon(Icons.calendar_month_rounded, size: 18),
                  label: const Text('Create / Edit Timetable'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: canAddExam
                      ? () {
                          setState(() {
                            _isTableView = !_isTableView;
                          });
                        }
                      : null,
                  icon: Icon(
                    _isTableView
                        ? Icons.view_list_rounded
                        : Icons.table_chart_rounded,
                    size: 18,
                  ),
                  label: Text(_isTableView ? 'Card View' : 'Table View'),
                ),
                IconButton.filledTonal(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () {
                    _examTypeController.fetchExamTypes();
                    if (canAddExam) {
                      _examController.fetchExams();
                    }
                  },
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),

          // Filters
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Filters',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                // Exam Type Selection
                Obx(() {
                  final examTypeCount = _examTypeController.examTypeList.length;
                  final examTypes = examTypeCount > 0
                      ? _examTypeController.examTypeList
                          .where((e) => e.isActive)
                          .toList()
                      : _examTypeController.examTypeList.toList();

                  return CustomDropdown<String>(
                    labelText: 'Exam Schedule *',
                    value: _selectedExamTypeId,
                    prefixIcon: const Icon(Icons.event_note),
                    items: examTypes
                        .map((examType) => DropdownMenuItem(
                              value: examType.id,
                              child: Text(examType.name),
                            ))
                        .toList(),
                    onChanged: examTypeCount == 0
                        ? null
                        : (value) {
                            setState(() {
                              _selectedExamTypeId = value;
                            });
                            if (_selectedExamTypeId != null &&
                                _selectedClass != null &&
                                _selectedSection != null) {
                              _examController.fetchExams();
                            }
                          },
                  );
                }),

                const SizedBox(height: 12),

                // Class and Section Selection
                ClassSectionDropDown(
                  padding: 0,
                  fieldHeight: 50,
                  onChangedClass: (classId) {
                    setState(() {
                      _selectedClass = classId;
                    });
                    if (_selectedExamTypeId != null &&
                        _selectedClass != null &&
                        _selectedSection != null) {
                      _examController.fetchExams();
                      _examController.setClassFilter(classId);
                    }
                  },
                  onChangedSection: (section) {
                    setState(() {
                      _selectedSection = section;
                    });
                    if (_selectedExamTypeId != null &&
                        _selectedClass != null &&
                        _selectedSection != null) {
                      _examController.fetchExams();
                      _examController.setSectionFilter(section);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Content
          Expanded(
            child: !canAddExam
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Select exam schedule, class, and section',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'to view and manage exams',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                : _isTableView
                    ? _buildTableView(theme)
                    : _buildExamList(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildExamList(ThemeData theme) {
    return Obx(() {
      if (_examController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // Filter exams by selected exam type and sort by date then subject
      final filteredExams = _examController.examList
          .where((exam) => exam.examTypeId == _selectedExamTypeId)
          .toList()
        ..sort((a, b) {
          final dateCompare = a.examDate.compareTo(b.examDate);
          if (dateCompare != 0) return dateCompare;
          return a.subject.compareTo(b.subject);
        });

      if (filteredExams.isEmpty) {
        return EmptyState(
          icon: Icons.event_busy,
          title: 'No exams scheduled',
          message:
              'No exams added for Class $_selectedClass - Section $_selectedSection yet',
          action: ElevatedButton.icon(
            onPressed: () => Get.to(() => AdminAddEditExamScreen(
                  examTypeId: _selectedExamTypeId!,
                  classId: _selectedClass!,
                  section: _selectedSection!,
                )),
            icon: const Icon(Icons.add),
            label: const Text('Add First Exam'),
          ),
        );
      }

      final examsByDate = <String, List<ExamModel>>{};
      for (var exam in filteredExams) {
        final dateKey = DateFormat('yyyy-MM-dd').format(exam.examDate);
        if (!examsByDate.containsKey(dateKey)) {
          examsByDate[dateKey] = [];
        }
        examsByDate[dateKey]!.add(exam);
      }

      return ResponsivePadding(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // Exams grouped by date
            ...examsByDate.entries.map((entry) {
              final date = DateTime.parse(entry.key);
              final dayExams = entry.value;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.22),
                    width: 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // Date Header
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.35),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(14),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('EEEE, MMMM dd, yyyy').format(date),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${dayExams.length} exam${dayExams.length > 1 ? 's' : ''}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Exams List
                    ...dayExams.map((exam) => _buildExamTile(theme, exam)),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    });
  }

  Widget _buildExamTile(ThemeData theme, ExamModel exam) {
    final subjectColor = _getSubjectColor(exam.subject);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: subjectColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: subjectColor.withValues(alpha: 0.3)),
        ),
        child: Icon(
          _getSubjectIcon(exam.subject),
          color: subjectColor,
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              exam.subject,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: subjectColor,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getExamTypeColor(exam.type).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              exam.type.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: _getExamTypeColor(exam.type),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Row(
          children: [
            Icon(Icons.access_time,
                size: 14, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(DateFormat('hh:mm a').format(exam.examDate)),
            if (exam.durationMinutes != null) ...[
              const SizedBox(width: 12),
              Icon(Icons.timer,
                  size: 14, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text('${exam.durationMinutes} min'),
            ],
            const SizedBox(width: 10),
            Icon(Icons.grade,
                size: 14, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text('${exam.totalMarks.toInt()} marks'),
          ],
        ),
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            Get.to(() => AdminAddEditExamScreen(
                  exam: exam,
                  examTypeId: exam.examTypeId,
                  classId: exam.classId,
                  section: exam.section,
                ));
          } else if (value == 'delete') {
            _showDeleteConfirmation(exam);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 18),
                SizedBox(width: 8),
                Text('Edit'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 18, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
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
      case 'physics':
        return Colors.indigo;
      case 'chemistry':
        return Colors.teal;
      case 'biology':
        return Colors.lightGreen;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
        return Icons.calculate;
      case 'science':
        return Icons.science;
      case 'english':
        return Icons.menu_book;
      case 'history':
        return Icons.history_edu;
      case 'computer science':
        return Icons.computer;
      case 'physics':
        return Icons.psychology;
      case 'chemistry':
        return Icons.biotech;
      case 'biology':
        return Icons.eco;
      default:
        return Icons.book;
    }
  }

  Color _getExamTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'final':
        return Colors.red;
      case 'mid-term':
        return Colors.orange;
      case 'quiz':
        return Colors.purple;
      case 'assignment':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  void _showDeleteConfirmation(ExamModel exam) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exam'),
        content: Text(
            'Are you sure you want to delete the ${exam.subject} exam on ${DateFormat('MMM dd, yyyy').format(exam.examDate)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _examController.deleteExam(exam.id);
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

  Widget _buildTableView(ThemeData theme) {
    return Obx(() {
      if (_examController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // Filter exams by selected exam type and sort by date
      final filteredExams = _examController.examList
          .where((exam) => exam.examTypeId == _selectedExamTypeId)
          .toList()
        ..sort((a, b) => a.examDate.compareTo(b.examDate));

      if (filteredExams.isEmpty) {
        return EmptyState(
          icon: Icons.event_busy,
          title: 'No exams scheduled',
          message:
              'No exams added for Class $_selectedClass - Section $_selectedSection yet',
          action: ElevatedButton.icon(
            onPressed: () => Get.to(() => AdminAddEditExamScreen(
                  examTypeId: _selectedExamTypeId!,
                  classId: _selectedClass!,
                  section: _selectedSection!,
                )),
            icon: const Icon(Icons.add),
            label: const Text('Add First Exam'),
          ),
        );
      }

      // Group by date
      final examsByDate = <String, List<ExamModel>>{};
      for (var exam in filteredExams) {
        final dateKey = DateFormat('yyyy-MM-dd').format(exam.examDate);
        if (!examsByDate.containsKey(dateKey)) {
          examsByDate[dateKey] = [];
        }
        examsByDate[dateKey]!.add(exam);
      }

      return ResponsivePadding(
        child: Column(
          children: [
            // Table View
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.5),
                      ),
                      border: TableBorder(
                        horizontalInside: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                        verticalInside: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                      columns: [
                        DataColumn(
                          label: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'Date',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'Subject',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'Time',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'Total Marks',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'Duration',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'Type',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'Actions',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                      rows: filteredExams.map((exam) {
                        final subjectColor = _getSubjectColor(exam.subject);
                        final date = exam.examDate;

                        return DataRow(
                          cells: [
                            // Date
                            DataCell(
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      DateFormat('EEE').format(date),
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('MMM dd, yyyy').format(date),
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Subject
                            DataCell(
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Icon(
                                      _getSubjectIcon(exam.subject),
                                      color: subjectColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      exam.subject,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: subjectColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Time
                            DataCell(
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  DateFormat('hh:mm a').format(exam.examDate),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            // Total Marks
                            DataCell(
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Icon(Icons.grade,
                                        size: 16,
                                        color: theme.colorScheme.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${exam.totalMarks.toInt()}',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Duration
                            DataCell(
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: exam.durationMinutes != null
                                    ? Row(
                                        children: [
                                          Icon(Icons.timer,
                                              size: 16,
                                              color: theme.colorScheme.primary),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${exam.durationMinutes} min',
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                        ],
                                      )
                                    : Text(
                                        '-',
                                        style: TextStyle(
                                          color: theme
                                              .colorScheme.onSurfaceVariant
                                              .withValues(alpha: 0.3),
                                        ),
                                      ),
                              ),
                            ),
                            // Type
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getExamTypeColor(exam.type)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  exam.type.toUpperCase(),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: _getExamTypeColor(exam.type),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            // Actions
                            DataCell(
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    Get.to(() => AdminAddEditExamScreen(
                                          exam: exam,
                                          examTypeId: exam.examTypeId,
                                          classId: exam.classId,
                                          section: exam.section,
                                        ));
                                  } else if (value == 'delete') {
                                    _showDeleteConfirmation(exam);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 18),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete,
                                            size: 18, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
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
          ],
        ),
      );
    });
  }
}
