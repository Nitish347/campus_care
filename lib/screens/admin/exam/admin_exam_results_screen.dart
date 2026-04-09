import 'package:campus_care/controllers/class_controller.dart';
import 'package:campus_care/controllers/exam_controller.dart';
import 'package:campus_care/controllers/exam_result_controller.dart';
import 'package:campus_care/models/class.dart';
import 'package:campus_care/models/exam_model.dart';
import 'package:campus_care/models/student/student.dart';
import 'package:campus_care/services/student_service.dart';
import 'package:campus_care/widgets/admin/admin_page_header.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/common/section_header.dart';
import 'package:campus_care/widgets/common/summary_card.dart';
import 'package:campus_care/widgets/inputs/custom_dropdown.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AdminExamResultsScreen extends StatefulWidget {
  const AdminExamResultsScreen({super.key});

  @override
  State<AdminExamResultsScreen> createState() => _AdminExamResultsScreenState();
}

class _AdminExamResultsScreenState extends State<AdminExamResultsScreen> {
  late final ExamController _examController;
  late final ExamResultController _resultController;
  late final ClassController _classController;

  String? _selectedClassId;
  String? _selectedSection;
  String? _selectedExamId;

  final List<Student> _students = [];
  final Map<String, TextEditingController> _marksControllers = {};
  final Map<String, TextEditingController> _remarksControllers = {};
  final Map<String, bool> _absentByStudentId = {};

  bool _isLoadingStudents = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _examController = Get.isRegistered<ExamController>()
        ? Get.find<ExamController>()
        : Get.put(ExamController());
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
        .where((exam) => exam.classId == _selectedClassId && exam.section == _selectedSection)
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

  TextEditingController _marksControllerFor(String studentId) {
    return _marksControllers.putIfAbsent(studentId, () => TextEditingController());
  }

  TextEditingController _remarksControllerFor(String studentId) {
    return _remarksControllers.putIfAbsent(studentId, () => TextEditingController());
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

  Future<void> _onClassChanged(String? classId) async {
    if (_selectedClassId == classId) return;

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
    if (_selectedSection == section) return;

    setState(() {
      _selectedSection = section;
      _selectedExamId = null;
      _students.clear();
      _clearEntryControllers();
    });

    await _loadStudentsAndResults();
  }

  Future<void> _onExamChanged(String? examId) async {
    if (_selectedExamId == examId) return;

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
        if (aRoll != null && bRoll != null) {
          return aRoll.compareTo(bRoll);
        }
        return a.rollNumber.compareTo(b.rollNumber);
      });

      _students
        ..clear()
        ..addAll(fetchedStudents);

      if (_selectedExamId != null) {
        await _resultController.fetchResults(examId: _selectedExamId);
        _prefillFromExistingResults();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingStudents = false;
        });
      }
    }
  }

  void _prefillFromExistingResults() {
    final examId = _selectedExamId;
    if (examId == null) return;

    for (final student in _students) {
      final existing = _resultController.getStudentResult(examId, student.id);
      final marksController = _marksControllerFor(student.id);
      final remarksController = _remarksControllerFor(student.id);

      if (existing == null) {
        marksController.clear();
        remarksController.clear();
        _absentByStudentId[student.id] = false;
        continue;
      }

      _absentByStudentId[student.id] = !existing.isPresent;
      if (existing.isPresent) {
        final marks = existing.marks;
        marksController.text = marks == marks.toInt() ? '${marks.toInt()}' : marks.toStringAsFixed(1);
      } else {
        marksController.clear();
      }
      remarksController.text = existing.remarks ?? '';
    }
  }

  List<Map<String, dynamic>> _buildEntriesForSave() {
    final exam = _selectedExam;
    if (exam == null) {
      throw Exception('Please select an exam first');
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
            'Marks for ${student.fullName} must be between 0 and ${exam.totalMarks.toInt()}');
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
      Get.snackbar('Exam Required', 'Select class, section and exam first');
      return;
    }

    List<Map<String, dynamic>> entries;
    try {
      entries = _buildEntriesForSave();
    } catch (error) {
      Get.snackbar(
        'Validation Error',
        error.toString().replaceFirst('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (entries.isEmpty) {
      Get.snackbar('No Data', 'Enter at least one mark or mark absent');
      return;
    }

    setState(() {
      _isSaving = true;
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
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (_) {
      // Controller shows API errors.
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            AdminPageHeader(
              title: const Text('Exam Results & Marks'),
              subtitle: 'Enter and update subject-wise student marks',
              icon: Icons.fact_check_rounded,
              showBreadcrumb: true,
              breadcrumbLabel: 'Exam Results',
              showBackButton: true,
              actions: [
                HeaderActionButton(
                  icon: Icons.refresh_rounded,
                  label: 'Refresh',
                  onPressed: () async {
                    await _examController.fetchExams();
                    await _loadStudentsAndResults();
                  },
                ),
              ],
            ),
            ResponsivePadding(
              mobilePadding: const EdgeInsets.all(14),
              tabletPadding: const EdgeInsets.all(20),
              desktopPadding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: 'Filters',
                    subtitle: 'Select class, section and exam to load students',
                  ),
                  const SizedBox(height: 12),
                  _buildFilterCard(theme),
                  const SizedBox(height: 14),
                  if (_selectedExam != null) _buildExamInfoCard(theme),
                  if (_selectedExam != null) const SizedBox(height: 14),
                  _buildBody(theme),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterCard(ThemeData theme) {
    final classDropdown = CustomDropdown<String>(
      labelText: 'Class *',
      value: _selectedClassId,
      prefixIcon: const Icon(Icons.class_rounded),
      items: _classController.classes
          .map(
            (classItem) => DropdownMenuItem<String>(
              value: classItem.id,
              child: Text(classItem.name),
            ),
          )
          .toList(),
      onChanged: _onClassChanged,
    );

    final sectionDropdown = CustomDropdown<String>(
      labelText: 'Section *',
      value: _sections.contains(_selectedSection) ? _selectedSection : null,
      prefixIcon: const Icon(Icons.view_week_rounded),
      enabled: _selectedClassId != null,
      items: _sections
          .map(
            (section) => DropdownMenuItem<String>(
              value: section,
              child: Text(section),
            ),
          )
          .toList(),
      onChanged: _selectedClassId == null ? null : _onSectionChanged,
    );

    final examDropdown = CustomDropdown<String>(
      labelText: 'Exam *',
      value: _selectedExamId,
      prefixIcon: const Icon(Icons.event_note_rounded),
      enabled: _selectedClassId != null && _selectedSection != null,
      items: _filteredExams
          .map(
            (exam) => DropdownMenuItem<String>(
              value: exam.id,
              child: Text(
                '${exam.name} • ${exam.subject} • ${DateFormat('dd MMM yyyy').format(exam.examDate)}',
              ),
            ),
          )
          .toList(),
      onChanged: (_selectedClassId == null || _selectedSection == null) ? null : _onExamChanged,
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 1000;
            final isTablet = constraints.maxWidth >= 700 && constraints.maxWidth < 1000;

            if (isWide) {
              return Row(
                children: [
                  Expanded(child: classDropdown),
                  const SizedBox(width: 12),
                  Expanded(child: sectionDropdown),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: examDropdown),
                ],
              );
            }

            if (isTablet) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: classDropdown),
                      const SizedBox(width: 12),
                      Expanded(child: sectionDropdown),
                    ],
                  ),
                  const SizedBox(height: 12),
                  examDropdown,
                ],
              );
            }

            return Column(
              children: [
                classDropdown,
                const SizedBox(height: 10),
                sectionDropdown,
                const SizedBox(height: 10),
                examDropdown,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildExamInfoCard(ThemeData theme) {
    final exam = _selectedExam!;
    final enteredCount = _getEnteredCount();
    final pendingCount = (_students.length - enteredCount).clamp(0, _students.length);

    return SummaryCard(
      padding: 0,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.menu_book_rounded, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.subject,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '${exam.name} • ${DateFormat('dd MMM yyyy, hh:mm a').format(exam.examDate)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _statPill(theme, Icons.people_alt_rounded, 'Students: ${_students.length}'),
                    _statPill(theme, Icons.check_circle_rounded, 'Entered: $enteredCount'),
                    _statPill(theme, Icons.pending_actions_rounded, 'Pending: $pendingCount'),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${exam.totalMarks.toInt()} marks',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_selectedClassId == null || _selectedSection == null || _selectedExamId == null) {
      return const SizedBox(
        height: 260,
        child: EmptyState(
          icon: Icons.filter_alt_off_rounded,
          title: 'Select Filters',
          message: 'Choose class, section and exam to enter marks',
        ),
      );
    }

    if (_isLoadingStudents || _resultController.isLoading.value) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 36),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_students.isEmpty) {
      return const SizedBox(
        height: 260,
        child: EmptyState(
          icon: Icons.people_outline,
          title: 'No students found',
          message: 'No students available in selected class and section',
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1000;

        return Column(
          children: [
            if (isWide) ...[
              _buildDesktopTableHeader(theme),
              const SizedBox(height: 8),
            ],
            ..._students.asMap().entries.map((entry) {
              final index = entry.key;
              final student = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: index == _students.length - 1 ? 0 : 10),
                child: _buildStudentCard(theme, student, isWide: isWide),
              );
            }),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _saveAllMarks,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(_isSaving ? 'Saving marks...' : 'Save Marks'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  int _getEnteredCount() {
    return _students.where((student) {
      final absent = _absentByStudentId[student.id] ?? false;
      final hasMarks = _marksControllerFor(student.id).text.trim().isNotEmpty;
      return absent || hasMarks;
    }).length;
  }

  Widget _buildStudentCard(ThemeData theme, Student student, {required bool isWide}) {
    final marksController = _marksControllerFor(student.id);
    final remarksController = _remarksControllerFor(student.id);
    final isAbsent = _absentByStudentId[student.id] ?? false;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: isWide
            ? Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Text(
                            student.fullName.isNotEmpty ? student.fullName[0].toUpperCase() : 'S',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.fullName,
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Roll No: ${student.rollNumber}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 130,
                    child: TextFormField(
                      controller: marksController,
                      enabled: !isAbsent,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Marks',
                        suffixText: '/ ${_selectedExam?.totalMarks.toInt() ?? ''}',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: remarksController,
                      decoration: InputDecoration(
                        labelText: 'Remarks',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 120,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ChoiceChip(
                        label: const Text('Absent'),
                        selected: isAbsent,
                        onSelected: (selected) {
                          setState(() {
                            _absentByStudentId[student.id] = selected;
                            if (selected) {
                              marksController.clear();
                            }
                          });
                        },
                        avatar: Icon(
                          Icons.person_off_rounded,
                          size: 16,
                          color: isAbsent ? Colors.white : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          student.fullName.isNotEmpty ? student.fullName[0].toUpperCase() : 'S',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.fullName,
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Roll No: ${student.rollNumber}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ChoiceChip(
                        label: const Text('Absent'),
                        selected: isAbsent,
                        onSelected: (selected) {
                          setState(() {
                            _absentByStudentId[student.id] = selected;
                            if (selected) {
                              marksController.clear();
                            }
                          });
                        },
                        avatar: Icon(
                          Icons.person_off_rounded,
                          size: 16,
                          color: isAbsent ? Colors.white : theme.colorScheme.primary,
                        ),
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
                            suffixText: '/ ${_selectedExam?.totalMarks.toInt() ?? ''}',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: remarksController,
                          decoration: InputDecoration(
                            labelText: 'Remarks (optional)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDesktopTableHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Name',
              style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          const SizedBox(width: 130, child: Text('Marks')),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Text(
              'Remarks',
              style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          const SizedBox(
            width: 120,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('Absent'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statPill(ThemeData theme, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
