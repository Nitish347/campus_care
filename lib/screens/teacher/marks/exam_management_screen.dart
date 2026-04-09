import 'package:campus_care/controllers/class_controller.dart';
import 'package:campus_care/controllers/exam_controller.dart';
import 'package:campus_care/controllers/exam_result_controller.dart';
import 'package:campus_care/models/class.dart';
import 'package:campus_care/models/exam_model.dart';
import 'package:campus_care/models/student/student.dart';
import 'package:campus_care/services/student_service.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/common/summary_card.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ExamManagementScreen extends StatefulWidget {
  const ExamManagementScreen({super.key});

  @override
  State<ExamManagementScreen> createState() => _ExamManagementScreenState();
}

class _ExamManagementScreenState extends State<ExamManagementScreen>
    with SingleTickerProviderStateMixin {
  final ExamController _examController = Get.put(ExamController());
  late final ExamResultController _resultController;
  late final ClassController _classController;

  late TabController _tabController;

  String? _selectedClassId;
  String? _selectedSection;
  String? _selectedExamId;

  final List<Student> _students = [];
  final Map<String, TextEditingController> _marksControllers = {};
  final Map<String, TextEditingController> _remarksControllers = {};
  final Map<String, bool> _absentByStudentId = {};

  bool _isLoadingStudents = false;
  bool _isSavingMarks = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _resultController = Get.isRegistered<ExamResultController>()
        ? Get.find<ExamResultController>()
        : Get.put(ExamResultController());
    _classController = Get.isRegistered<ClassController>()
        ? Get.find<ClassController>()
        : Get.put(ClassController());

    _classController.fetchClasses();
    _examController.fetchExams();
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final controller in _marksControllers.values) {
      controller.dispose();
    }
    for (final controller in _remarksControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  SchoolClass? get _selectedClass {
    if (_selectedClassId == null) return null;
    for (final classItem in _classController.classes) {
      if (classItem.id == _selectedClassId) return classItem;
    }
    return null;
  }

  List<String> get _sections => _selectedClass?.sections ?? const [];

  List<ExamModel> get _filteredExams {
    if (_selectedClassId == null || _selectedSection == null) {
      return const [];
    }

    return _examController.examList
        .where((exam) =>
            exam.classId == _selectedClassId && exam.section == _selectedSection)
        .toList()
      ..sort((a, b) => b.examDate.compareTo(a.examDate));
  }

  ExamModel? get _selectedExam {
    if (_selectedExamId == null) return null;
    for (final exam in _examController.examList) {
      if (exam.id == _selectedExamId) return exam;
    }
    return null;
  }

  bool get _canRenderMarksForm =>
      _selectedClassId != null && _selectedSection != null && _selectedExamId != null;

  String _classLabel(String classId) {
    for (final classItem in _classController.classes) {
      if (classItem.id == classId) {
        return classItem.name;
      }
    }
    return classId;
  }

  Future<void> _onClassChanged(String? classId) async {
    if (classId == _selectedClassId) return;

    setState(() {
      _selectedClassId = classId;
      _selectedExamId = null;
      _students.clear();
      _clearEntryControllers();

      SchoolClass? classModel;
      for (final classItem in _classController.classes) {
        if (classItem.id == classId) {
          classModel = classItem;
          break;
        }
      }

      _selectedSection =
          classModel != null && classModel.sections.isNotEmpty ? classModel.sections.first : null;
    });

    await _loadStudentsAndResults();
  }

  Future<void> _onSectionChanged(String? section) async {
    if (section == _selectedSection) return;

    setState(() {
      _selectedSection = section;
      _selectedExamId = null;
      _students.clear();
      _clearEntryControllers();
    });

    await _loadStudentsAndResults();
  }

  Future<void> _onExamChanged(String? examId) async {
    if (examId == _selectedExamId) return;

    setState(() {
      _selectedExamId = examId;
      _clearEntryControllers();
    });

    await _loadStudentsAndResults();
  }

  Future<void> _loadStudentsAndResults() async {
    if (_selectedClassId == null || _selectedSection == null) {
      return;
    }

    setState(() {
      _isLoadingStudents = true;
    });

    try {
      final fetchedStudents =
          await StudentService.getStudentsByClass(_selectedClassId!, _selectedSection!);

      fetchedStudents.sort((a, b) {
        final aRoll = int.tryParse(a.rollNumber);
        final bRoll = int.tryParse(b.rollNumber);
        if (aRoll != null && bRoll != null) return aRoll.compareTo(bRoll);
        return a.rollNumber.compareTo(b.rollNumber);
      });

      _students
        ..clear()
        ..addAll(fetchedStudents);

      if (_selectedExamId != null) {
        await _resultController.fetchResults(examId: _selectedExamId);
        _prefillFromExistingResults();
      } else {
        _clearEntryControllers();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingStudents = false;
        });
      }
    }
  }

  void _clearEntryControllers() {
    for (final controller in _marksControllers.values) {
      controller.dispose();
    }
    for (final controller in _remarksControllers.values) {
      controller.dispose();
    }
    _marksControllers.clear();
    _remarksControllers.clear();
    _absentByStudentId.clear();
  }

  TextEditingController _marksControllerFor(String studentId) {
    return _marksControllers.putIfAbsent(studentId, () => TextEditingController());
  }

  TextEditingController _remarksControllerFor(String studentId) {
    return _remarksControllers.putIfAbsent(studentId, () => TextEditingController());
  }

  void _prefillFromExistingResults() {
    final examId = _selectedExamId;
    if (examId == null) return;

    for (final student in _students) {
      final result = _resultController.getStudentResult(examId, student.id);
      final marksController = _marksControllerFor(student.id);
      final remarksController = _remarksControllerFor(student.id);

      if (result == null) {
        marksController.clear();
        remarksController.clear();
        _absentByStudentId[student.id] = false;
        continue;
      }

      _absentByStudentId[student.id] = !result.isPresent;
      if (!result.isPresent) {
        marksController.clear();
      } else {
        final marks = result.marks;
        marksController.text =
            marks == marks.toInt() ? '${marks.toInt()}' : marks.toStringAsFixed(1);
      }
      remarksController.text = result.remarks ?? '';
    }
  }

  List<Map<String, dynamic>> _buildEntriesForSave() {
    final exam = _selectedExam;
    if (exam == null) {
      throw Exception('Please select an exam');
    }

    final entries = <Map<String, dynamic>>[];

    for (final student in _students) {
      final isAbsent = _absentByStudentId[student.id] ?? false;
      final marksText = _marksControllerFor(student.id).text.trim();
      final remarksText = _remarksControllerFor(student.id).text.trim();

      if (isAbsent) {
        entries.add({
          'exam_id': exam.id,
          'student_id': student.id,
          'subject': exam.subject,
          'marks': 0,
          'total_marks': exam.totalMarks,
          'is_absent': 1,
          if (remarksText.isNotEmpty) 'remarks': remarksText,
        });
        continue;
      }

      if (marksText.isEmpty) {
        continue;
      }

      final marks = double.tryParse(marksText);
      if (marks == null) {
        throw Exception('Invalid marks for ${student.fullName}');
      }

      if (marks < 0 || marks > exam.totalMarks) {
        throw Exception(
            'Marks for ${student.fullName} must be between 0 and ${exam.totalMarks.toStringAsFixed(0)}');
      }

      entries.add({
        'exam_id': exam.id,
        'student_id': student.id,
        'subject': exam.subject,
        'marks': marks,
        'total_marks': exam.totalMarks,
        'is_absent': 0,
        if (remarksText.isNotEmpty) 'remarks': remarksText,
      });
    }

    return entries;
  }

  Future<void> _saveAllMarks() async {
    final exam = _selectedExam;
    if (exam == null) {
      Get.snackbar(
        'Exam required',
        'Please select class, section and exam first',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    List<Map<String, dynamic>> entries;
    try {
      entries = _buildEntriesForSave();
    } catch (error) {
      Get.snackbar(
        'Validation error',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (entries.isEmpty) {
      Get.snackbar(
        'No entries',
        'Enter at least one mark or mark a student absent',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      _isSavingMarks = true;
    });

    try {
      await _resultController.bulkSaveMarks(
        entries: entries,
        examId: exam.id,
        showSuccess: false,
      );

      await _resultController.fetchResults(examId: exam.id);
      _prefillFromExistingResults();

      Get.snackbar(
        'Saved',
        'Marks saved for ${entries.length} students',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (_) {
      // Error snackbar is shown by controller.
    } finally {
      if (mounted) {
        setState(() {
          _isSavingMarks = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_month), text: 'Exam Timetable'),
            Tab(icon: Icon(Icons.edit_note), text: 'Marks Entry'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExamTimetableTab(),
          _buildMarksEntryTab(),
        ],
      ),
    );
  }

  Widget _buildExamTimetableTab() {
    return Obx(() {
      if (_examController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final exams = _examController.examList;
      if (exams.isEmpty) {
        return const EmptyState(
          icon: Icons.assignment_outlined,
          title: 'No exams',
          message: 'No exams scheduled yet',
        );
      }

      final upcoming = exams.where((exam) => exam.isUpcoming).length;
      final completed = exams.length - upcoming;

      return Column(
        children: [
          SummaryCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _summaryItem('Total', '${exams.length}', Icons.assignment_outlined),
                _summaryItem('Upcoming', '$upcoming', Icons.upcoming),
                _summaryItem('Completed', '$completed', Icons.check_circle_outline),
              ],
            ),
          ),
          Expanded(
            child: ResponsivePadding(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: exams.length,
                itemBuilder: (context, index) {
                  final exam = exams[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(exam.subject.isNotEmpty ? exam.subject[0].toUpperCase() : 'E'),
                      ),
                      title: Text('${exam.name} • ${exam.subject}'),
                      subtitle: Text(
                        '${_classLabel(exam.classId)} - ${exam.section}\n${DateFormat('dd MMM yyyy, hh:mm a').format(exam.examDate)}',
                      ),
                      isThreeLine: true,
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${exam.totalMarks.toStringAsFixed(0)} marks'),
                          const SizedBox(height: 4),
                          Text(
                            exam.isUpcoming ? 'Upcoming' : 'Completed',
                            style: TextStyle(
                              color: exam.isUpcoming ? Colors.blue : Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _summaryItem(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }

  Widget _buildMarksEntryTab() {
    final theme = Theme.of(context);

    return Obx(() {
      final classItems = _classController.classes;
      final exams = _filteredExams;
      final selectedExam = _selectedExam;

      final enteredCount = _students.where((student) {
        final isAbsent = _absentByStudentId[student.id] ?? false;
        final hasMarks = _marksControllerFor(student.id).text.trim().isNotEmpty;
        return isAbsent || hasMarks;
      }).length;

      return ResponsivePadding(
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedClassId,
                            decoration: const InputDecoration(
                              labelText: 'Class',
                              border: OutlineInputBorder(),
                            ),
                            items: classItems
                                .map(
                                  (classItem) => DropdownMenuItem<String>(
                                    value: classItem.id,
                                    child: Text(classItem.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) => _onClassChanged(value),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _sections.contains(_selectedSection)
                                ? _selectedSection
                                : null,
                            decoration: const InputDecoration(
                              labelText: 'Section',
                              border: OutlineInputBorder(),
                            ),
                            items: _sections
                                .map(
                                  (section) => DropdownMenuItem<String>(
                                    value: section,
                                    child: Text(section),
                                  ),
                                )
                                .toList(),
                            onChanged: _selectedClassId == null
                                ? null
                                : (value) => _onSectionChanged(value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedExamId,
                      decoration: const InputDecoration(
                        labelText: 'Exam',
                        border: OutlineInputBorder(),
                      ),
                      items: exams
                          .map(
                            (exam) => DropdownMenuItem<String>(
                              value: exam.id,
                              child: Text(
                                '${exam.name} • ${exam.subject} • ${DateFormat('dd MMM yyyy').format(exam.examDate)}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (_selectedClassId == null || _selectedSection == null)
                          ? null
                          : (value) => _onExamChanged(value),
                    ),
                    if (selectedExam != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Subject: ${selectedExam.subject} • Total Marks: ${selectedExam.totalMarks.toStringAsFixed(0)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (_isLoadingStudents || _resultController.isLoading.value)
              const LinearProgressIndicator(),
            const SizedBox(height: 10),
            if (!_canRenderMarksForm)
              const Expanded(
                child: EmptyState(
                  icon: Icons.assignment,
                  title: 'Select Filters',
                  message: 'Choose class, section, and exam to enter marks',
                ),
              )
            else if (_students.isEmpty)
              const Expanded(
                child: EmptyState(
                  icon: Icons.people_outline,
                  title: 'No students',
                  message: 'No students found in selected class and section',
                ),
              )
            else ...[
              SummaryCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _summaryItem('Students', '${_students.length}', Icons.people),
                    _summaryItem('Entered', '$enteredCount', Icons.check_circle_outline),
                    _summaryItem(
                      'Pending',
                      '${_students.length - enteredCount}',
                      Icons.pending_actions,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  itemCount: _students.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final student = _students[index];
                    final marksController = _marksControllerFor(student.id);
                    final remarksController = _remarksControllerFor(student.id);
                    final isAbsent = _absentByStudentId[student.id] ?? false;

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  child: Text(
                                    student.fullName.isNotEmpty
                                        ? student.fullName[0].toUpperCase()
                                        : 'S',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student.fullName,
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text('Roll No: ${student.rollNumber}'),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('Absent'),
                                    Checkbox(
                                      value: isAbsent,
                                      onChanged: (value) {
                                        setState(() {
                                          _absentByStudentId[student.id] = value ?? false;
                                          if (value == true) {
                                            marksController.clear();
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: marksController,
                                    enabled: !isAbsent,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: InputDecoration(
                                      labelText: 'Marks',
                                      hintText: 'Enter marks',
                                      suffixText: '/ ${selectedExam?.totalMarks.toStringAsFixed(0) ?? ''}',
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: remarksController,
                                    maxLines: 1,
                                    decoration: const InputDecoration(
                                      labelText: 'Remarks (optional)',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSavingMarks ? null : _saveAllMarks,
                  icon: _isSavingMarks
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSavingMarks ? 'Saving...' : 'Save Marks'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}
