import 'package:campus_care/widgets/common/summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/models/exam_model.dart';
import 'package:campus_care/controllers/exam_controller.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';

class ExamManagementScreen extends StatefulWidget {
  const ExamManagementScreen({super.key});

  @override
  State<ExamManagementScreen> createState() => _ExamManagementScreenState();
}

class _ExamManagementScreenState extends State<ExamManagementScreen> with SingleTickerProviderStateMixin {
  final ExamController _controller = Get.put(ExamController());
  late TabController _tabController;

  // For marks entry
  String? _selectedClass;
  String? _selectedSection;
  String? _selectedSubject;
  String? _selectedExamType;

  final List<String> _classes = ['Class 8', 'Class 9', 'Class 10'];
  final List<String> _sections = ['A', 'B', 'C'];
  final List<String> _subjects = ['Mathematics', 'Science', 'English'];
  final List<String> _examTypes = ['Mid-term', 'Final', 'Unit Test'];

  // Expandable sections state
  final Map<String, bool> _expandedSections = {
    'Mid-term': true,
    'Final': false,
    'Unit Test': false,
  };

  // Sample students data
  final List<Map<String, dynamic>> _students = [
    {'rollNo': '001', 'name': 'Emma Wilson', 'marks': null},
    {'rollNo': '002', 'name': 'Liam Johnson', 'marks': null},
    {'rollNo': '003', 'name': 'Olivia Brown', 'marks': null},
    {'rollNo': '004', 'name': 'Noah Davis', 'marks': null},
    {'rollNo': '005', 'name': 'Ava Martinez', 'marks': null},
    {'rollNo': '006', 'name': 'Ethan Anderson', 'marks': null},
    {'rollNo': '007', 'name': 'Sophia Taylor', 'marks': null},
    {'rollNo': '008', 'name': 'Mason Thomas', 'marks': null},
    {'rollNo': '009', 'name': 'Isabella Garcia', 'marks': null},
    {'rollNo': '010', 'name': 'William Rodriguez', 'marks': null},
  ];

  final _marksControllers = <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Initialize controllers for each student
    for (int i = 0; i < _students.length; i++) {
      _marksControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var controller in _marksControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Color _getExamTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'final':
        return Colors.red;
      case 'mid-term':
        return Colors.orange;
      case 'unit test':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getExamTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'final':
        return Icons.school;
      case 'mid-term':
        return Icons.edit_note;
      case 'unit test':
        return Icons.quiz;
      default:
        return Icons.description;
    }
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
        return Colors.blue;
      case 'science':
        return Colors.green;
      case 'english':
        return Colors.purple;
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
      default:
        return Icons.book_outlined;
    }
  }

  void _setFullMarksForAll(int totalMarks) {
    setState(() {
      for (int i = 0; i < _students.length; i++) {
        _students[i]['marks'] = totalMarks;
        _marksControllers[i].text = totalMarks.toString();
      }
    });
    Get.snackbar(
      'Success',
      'Full marks ($totalMarks) set for all students',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _markAllAbsent() {
    setState(() {
      for (int i = 0; i < _students.length; i++) {
        _students[i]['marks'] = 0;
        _marksControllers[i].text = '0';
      }
    });
    Get.snackbar(
      'Marked Absent',
      'All students marked absent (0 marks)',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  void _clearAllMarks() {
    setState(() {
      for (int i = 0; i < _students.length; i++) {
        _students[i]['marks'] = null;
        _marksControllers[i].clear();
      }
    });
    Get.snackbar(
      'Cleared',
      'All marks cleared',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _saveMarks() {
    final enteredMarks = _students.where((s) => s['marks'] != null).length;

    if (enteredMarks == 0) {
      Get.snackbar(
        'Error',
        'Please enter marks for at least one student',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Get.snackbar(
      'Success',
      'Marks saved for $enteredMarks students',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.calendar_month),
              text: 'Exam Timetable',
            ),
            Tab(
              icon: Icon(Icons.edit_note),
              text: 'Marks Entry',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExamTimetableTab(theme),
          _buildMarksEntryTab(theme),
        ],
      ),
    );
  }

  Widget _buildExamTimetableTab(ThemeData theme) {
    return Column(
      children: [
        // Summary Header
        SummaryCard(
          child: Obx(() {
            final exams = _controller.examList;
            final upcoming = exams.where((e) => e.isUpcoming).length;
            final completed = exams.where((e) => e.isCompleted).length;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  theme,
                  Icons.assignment_outlined,
                  '${exams.length}',
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
                  Icons.upcoming,
                  '$upcoming',
                  'Upcoming',
                  Colors.blue,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
                _buildSummaryItem(
                  theme,
                  Icons.check_circle_outline,
                  '$completed',
                  'Completed',
                  Colors.green,
                ),
              ],
            );
          }),
        ),

        // Expandable Exam Sections
        Expanded(
          child: Obx(() {
            final exams = _controller.examList;

            if (exams.isEmpty) {
              return const EmptyState(
                icon: Icons.assignment_outlined,
                title: 'No exams',
                message: 'No exams scheduled yet',
              );
            }

            // Group exams by type
            final Map<String, List<ExamModel>> examsByType = {};
            for (var exam in exams) {
              if (!examsByType.containsKey(exam.type)) {
                examsByType[exam.type] = [];
              }
              examsByType[exam.type]!.add(exam);
            }

            return ResponsivePadding(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: examsByType.entries.map((entry) {
                  final examType = entry.key;
                  final typeExams = entry.value;
                  final isExpanded = _expandedSections[examType] ?? false;
                  final typeColor = _getExamTypeColor(examType);

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
                    child: Column(
                      children: [
                        // Header
                        InkWell(
                          onTap: () {
                            setState(() {
                              _expandedSections[examType] = !isExpanded;
                            });
                          },
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: typeColor.withOpacity(0.1),
                              borderRadius: isExpanded
                                  ? const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    )
                                  : BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: typeColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    _getExamTypeIcon(examType),
                                    color: typeColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        examType,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: typeColor,
                                        ),
                                      ),
                                      Text(
                                        '${typeExams.length} exam${typeExams.length > 1 ? 's' : ''}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  isExpanded ? Icons.expand_less : Icons.expand_more,
                                  color: typeColor,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Expanded Content - DataTable
                        if (isExpanded)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(
                                theme.colorScheme.surfaceContainerHighest,
                              ),
                              headingTextStyle: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              dataRowMinHeight: 60,
                              dataRowMaxHeight: 80,
                              columnSpacing: 24,
                              horizontalMargin: 16,
                              columns: const [
                                DataColumn(label: Text('Subject')),
                                DataColumn(label: Text('Date')),
                                DataColumn(label: Text('Time')),
                                DataColumn(label: Text('Class')),
                                DataColumn(label: Text('Marks')),
                                DataColumn(label: Text('Status')),
                              ],
                              rows: typeExams.map((exam) {
                                final subjectColor = _getSubjectColor(exam.subject);
                                final isUpcoming = exam.isUpcoming;

                                return DataRow(
                                  onSelectChanged: (_) => _showExamDetails(exam),
                                  cells: [
                                    // Subject
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: subjectColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
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
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Date
                                    DataCell(
                                      Text(
                                        DateFormat('MMM dd, yyyy').format(exam.examDate),
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
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            DateFormat('hh:mm a').format(exam.examDate),
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Class
                                    DataCell(
                                      Text(
                                        'Class ${exam.classId} - ${exam.section}',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ),
                                    // Marks
                                    DataCell(
                                      Text(
                                        '${exam.totalMarks.toInt()}',
                                        style: theme.textTheme.bodyMedium?.copyWith(
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
                                          color:
                                              isUpcoming ? Colors.blue.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isUpcoming ? Icons.upcoming : Icons.check_circle,
                                              size: 14,
                                              color: isUpcoming ? Colors.blue : Colors.green,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              isUpcoming ? 'Upcoming' : 'Completed',
                                              style: theme.textTheme.labelSmall?.copyWith(
                                                color: isUpcoming ? Colors.blue : Colors.green,
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
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMarksEntryTab(ThemeData theme) {
    final totalMarks = 100;

    return ResponsivePadding(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selection Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                // side: BorderSide(
                //   color: theme.colorScheme.outlineVariant,
                //   width: 1,
                // ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.filter_list,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Select Class & Subject',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedClass,
                            decoration: InputDecoration(
                              labelText: 'Class',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.class_),
                            ),
                            items: _classes.map((cls) {
                              return DropdownMenuItem(
                                value: cls,
                                child: Text(cls),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedClass = value);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedSection,
                            decoration: InputDecoration(
                              labelText: 'Section',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.group),
                            ),
                            items: _sections.map((sec) {
                              return DropdownMenuItem(
                                value: sec,
                                child: Text(sec),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedSection = value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedSubject,
                            decoration: InputDecoration(
                              labelText: 'Subject',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.book),
                            ),
                            items: _subjects.map((sub) {
                              return DropdownMenuItem(
                                value: sub,
                                child: Text(sub),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedSubject = value);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedExamType,
                            decoration: InputDecoration(
                              labelText: 'Exam Type',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.assignment),
                            ),
                            items: _examTypes.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedExamType = value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Student Marks List
            if (_selectedClass != null &&
                _selectedSection != null &&
                _selectedSubject != null &&
                _selectedExamType != null) ...[
              // Summary Stats
              SummaryCard(
                padding: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      theme,
                      'Total Students',
                      '${_students.length}',
                      Icons.people,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: theme.colorScheme.outline.withOpacity(0.3),
                    ),
                    _buildStatItem(
                      theme,
                      'Marks Entered',
                      '${_students.where((s) => s['marks'] != null).length}',
                      Icons.check_circle,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: theme.colorScheme.outline.withOpacity(0.3),
                    ),
                    _buildStatItem(
                      theme,
                      'Pending',
                      '${_students.where((s) => s['marks'] == null).length}',
                      Icons.pending,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Bulk Actions Card
              // Card(
              //   elevation: 0,
              //   color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(12),
              //     side: BorderSide(
              //       color: theme.colorScheme.primary.withOpacity(0.3),
              //       width: 1,
              //     ),
              //   ),
              //   child: Padding(
              //     padding: const EdgeInsets.all(16),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Row(
              //           children: [
              //             Icon(
              //               Icons.flash_on,
              //               color: theme.colorScheme.primary,
              //               size: 20,
              //             ),
              //             const SizedBox(width: 8),
              //             Text(
              //               'Quick Actions',
              //               style: theme.textTheme.titleSmall?.copyWith(
              //                 fontWeight: FontWeight.bold,
              //                 color: theme.colorScheme.primary,
              //               ),
              //             ),
              //           ],
              //         ),
              //         const SizedBox(height: 12),
              //         Wrap(
              //           spacing: 8,
              //           runSpacing: 8,
              //           children: [
              //             OutlinedButton.icon(
              //               onPressed: () => _setFullMarksForAll(totalMarks),
              //               icon: const Icon(Icons.star, size: 18),
              //               label: Text('Set Full Marks ($totalMarks) for All'),
              //               style: OutlinedButton.styleFrom(
              //                 foregroundColor: Colors.green,
              //                 side: const BorderSide(color: Colors.green),
              //               ),
              //             ),
              //             OutlinedButton.icon(
              //               onPressed: _markAllAbsent,
              //               icon: const Icon(Icons.person_off, size: 18),
              //               label: const Text('Mark All Absent (0)'),
              //               style: OutlinedButton.styleFrom(
              //                 foregroundColor: Colors.orange,
              //                 side: const BorderSide(color: Colors.orange),
              //               ),
              //             ),
              //             OutlinedButton.icon(
              //               onPressed: _clearAllMarks,
              //               icon: const Icon(Icons.clear_all, size: 18),
              //               label: const Text('Clear All'),
              //               style: OutlinedButton.styleFrom(
              //                 foregroundColor: Colors.red,
              //                 side: const BorderSide(color: Colors.red),
              //               ),
              //             ),
              //           ],
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

              const SizedBox(height: 16),

              // Students DataTable
              Card(
                elevation: 0,
                // shape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.circular(12),
                //   side: BorderSide(
                //     color: theme.colorScheme.outlineVariant,
                //     width: 1,
                //   ),
                // ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.people,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Student Marks',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Total: $totalMarks marks',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          theme.colorScheme.surfaceContainerHighest,
                        ),
                        headingTextStyle: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        dataRowMinHeight: 60,
                        dataRowMaxHeight: 70,
                        columnSpacing: 24,
                        horizontalMargin: 16,
                        columns: const [
                          DataColumn(label: Text('Roll No')),
                          DataColumn(label: Text('Student Name')),
                          DataColumn(label: Text('Marks Obtained')),
                          DataColumn(label: Text('Status')),
                        ],
                        rows: _students.asMap().entries.map((entry) {
                          final index = entry.key;
                          final student = entry.value;
                          final hasMarks = student['marks'] != null;
                          final marks = student['marks'];

                          return DataRow(
                            cells: [
                              // Roll Number
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        hasMarks ? Colors.green.withOpacity(0.1) : theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: hasMarks
                                          ? Colors.green.withOpacity(0.3)
                                          : theme.colorScheme.primary.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    student['rollNo'],
                                    style: TextStyle(
                                      color: hasMarks ? Colors.green : theme.colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              // Student Name
                              DataCell(
                                Text(
                                  student['name'],
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              // Marks Input
                              DataCell(
                                SizedBox(
                                  width: 120,
                                  child: TextFormField(
                                    controller: _marksControllers[index],
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(3),
                                    ],
                                    decoration: InputDecoration(
                                      hintText: 'Enter',
                                      suffixText: '/$totalMarks',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      errorText: marks != null && (marks < 0 || marks > totalMarks) ? 'Invalid' : null,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        if (value.isEmpty) {
                                          student['marks'] = null;
                                        } else {
                                          final parsedMarks = int.tryParse(value);
                                          if (parsedMarks != null && parsedMarks >= 0 && parsedMarks <= totalMarks) {
                                            student['marks'] = parsedMarks;
                                          }
                                        }
                                      });
                                    },
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
                                    color: hasMarks ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        hasMarks ? Icons.check_circle : Icons.pending,
                                        size: 14,
                                        color: hasMarks ? Colors.green : Colors.orange,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        hasMarks ? 'Entered' : 'Pending',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: hasMarks ? Colors.green : Colors.orange,
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
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saveMarks,
                  icon: const Icon(Icons.save),
                  label: const Text('Save All Marks'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ] else
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 64,
                        color: theme.colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Select class, section, subject, and exam type',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose all filters above to view and enter student marks',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
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

  Widget _buildStatItem(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.onPrimaryContainer,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  void _showExamDetails(ExamModel exam) {
    final theme = Theme.of(context);
    final stats = _controller.getExamStats(exam.id);

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
            Text(
              exam.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Subject', exam.subject),
            _buildDetailRow('Class', 'Class ${exam.classId} - ${exam.section}'),
            _buildDetailRow('Date', DateFormat('MMM dd, yyyy').format(exam.examDate)),
            _buildDetailRow('Total Marks', '${exam.totalMarks.toInt()}'),
            if (exam.durationMinutes != null) _buildDetailRow('Duration', '${exam.durationMinutes} minutes'),
            if (stats['present'] > 0) ...[
              const SizedBox(height: 16),
              Text(
                'Statistics',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildDetailRow('Average', stats['average'].toStringAsFixed(2)),
              _buildDetailRow('Highest', '${stats['highest']}'),
              _buildDetailRow('Lowest', '${stats['lowest']}'),
              _buildDetailRow('Present', '${stats['present']}/${stats['totalStudents']}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}
