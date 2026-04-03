import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/models/exam_model.dart';
import 'package:campus_care/controllers/exam_controller.dart';
import 'package:campus_care/controllers/exam_type_controller.dart';
import 'package:campus_care/controllers/class_controller.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:campus_care/widgets/inputs/custom_dropdown.dart';
import 'package:campus_care/widgets/inputs/subject_dropdown.dart';

import 'package:campus_care/widgets/admin/admin_page_header.dart';

class AdminAddEditExamScreen extends StatefulWidget {
  final ExamModel? exam;
  final String examTypeId;
  final String classId;
  final String section;
  final List<ExamModel>? existingExams;

  const AdminAddEditExamScreen({
    super.key,
    this.exam,
    required this.examTypeId,
    required this.classId,
    required this.section,
    this.existingExams,
  });

  @override
  State<AdminAddEditExamScreen> createState() => _AdminAddEditExamScreenState();
}

class _AdminAddEditExamScreenState extends State<AdminAddEditExamScreen> {
  final _formKey = GlobalKey<FormState>();

  // For single exam edit mode
  final _totalMarksController = TextEditingController();
  final _durationController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _syllabusController = TextEditingController();

  String? _selectedSubject;
  String _selectedType = 'quiz';
  DateTime _examDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _examTime = const TimeOfDay(hour: 9, minute: 0);

  // For bulk add mode
  final List<ExamEntry> _examEntries = [];

  bool get _isEditing => widget.exam != null;
  bool _hasInitialized = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      // Edit mode - single exam
      _selectedSubject = widget.exam!.subject;
      _selectedType = widget.exam!.type;
      _examDate = widget.exam!.examDate;
      _examTime = TimeOfDay.fromDateTime(widget.exam!.examDate);
      _totalMarksController.text = widget.exam!.totalMarks.toInt().toString();
      _durationController.text = widget.exam!.durationMinutes?.toString() ?? '';
      _instructionsController.text = widget.exam!.instructions ?? '';
      _syllabusController.text = widget.exam!.syllabus ?? '';
    } else if (widget.existingExams != null &&
        widget.existingExams!.isNotEmpty) {
      // Bulk edit mode - load existing exams (will be formatted in didChangeDependencies)
      // Just create entries with basic data
      for (var exam in widget.existingExams!) {
        final entry = ExamEntry();
        entry.examId = exam.id;
        entry.subject = exam.subject;
        entry.selectedDate = exam.examDate;
        entry.selectedTime = TimeOfDay.fromDateTime(exam.examDate);
        entry.dateController.text =
            DateFormat('MMM dd, yyyy').format(exam.examDate);
        // Don't format time here - will be done in didChangeDependencies
        entry.marksController.text = exam.totalMarks.toInt().toString();
        entry.durationController.text = exam.durationMinutes?.toString() ?? '';
        _examEntries.add(entry);
      }
      // Add 2 empty entries for adding more exams
      _addEmptyEntry();
      _addEmptyEntry();
    } else {
      // Add mode - start with 3 empty entries
      _addEmptyEntry();
      _addEmptyEntry();
      _addEmptyEntry();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Format time controllers that need context
    if (!_hasInitialized && widget.existingExams != null) {
      for (var entry in _examEntries) {
        if (entry.selectedTime != null && entry.timeController.text.isEmpty) {
          entry.timeController.text = entry.selectedTime!.format(context);
        }
      }
      _hasInitialized = true;
    }
  }

  @override
  void dispose() {
    _totalMarksController.dispose();
    _durationController.dispose();
    _instructionsController.dispose();
    _syllabusController.dispose();
    for (var entry in _examEntries) {
      entry.dispose();
    }
    super.dispose();
  }

  void _addEmptyEntry() {
    setState(() {
      _examEntries.add(ExamEntry());
    });
  }

  void _removeEntry(int index) {
    setState(() {
      _examEntries[index].dispose();
      _examEntries.removeAt(index);
    });
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _examDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _examDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _examTime,
    );

    if (time != null) {
      setState(() {
        _examTime = time;
      });
    }
  }

  Future<void> _saveExam() async {
    if (_isSaving) return;
    if (_formKey.currentState!.validate()) {
      if (_selectedSubject == null) {
        Get.snackbar(
          'Error',
          'Please select a subject',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final controller = Get.find<ExamController>();

      // Combine date and time
      final examDateTime = DateTime(
        _examDate.year,
        _examDate.month,
        _examDate.day,
        _examTime.hour,
        _examTime.minute,
      );

      final exam = ExamModel(
        id: widget.exam!.id,
        examTypeId: widget.examTypeId,
        name: '$_selectedSubject ${_selectedType.toUpperCase()}',
        type: _selectedType,
        subject: _selectedSubject!,
        classId: widget.classId,
        section: widget.section,
        teacherId: 'admin',
        totalMarks: double.parse(_totalMarksController.text),
        durationMinutes: _durationController.text.isNotEmpty
            ? int.parse(_durationController.text)
            : null,
        examDate: examDateTime,
        instructions: _instructionsController.text.isNotEmpty
            ? _instructionsController.text
            : null,
        syllabus: _syllabusController.text.isNotEmpty
            ? _syllabusController.text
            : null,
        createdAt: widget.exam!.createdAt,
        updatedAt: DateTime.now(),
      );

      setState(() => _isSaving = true);
      try {
        await controller.updateExam(exam);
        if (mounted) {
          Get.back();
        }
      } catch (e) {
        // Error already shown by controller
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  Future<void> _saveBulkExams() async {
    if (_isSaving) return;
    // Filter out empty entries and validate
    final validEntries = <ExamEntry>[];
    final errors = <String>[];

    for (var i = 0; i < _examEntries.length; i++) {
      final entry = _examEntries[i];

      // Skip completely empty entries
      if (entry.subject == null &&
          entry.dateController.text.isEmpty &&
          entry.timeController.text.isEmpty &&
          entry.marksController.text.isEmpty) {
        continue;
      }

      // Validate partially filled entries
      if (entry.subject == null) {
        errors.add('Exam ${i + 1}: Subject is required');
      }
      if (entry.selectedDate == null) {
        errors.add('Exam ${i + 1}: Date is required');
      }
      if (entry.selectedTime == null) {
        errors.add('Exam ${i + 1}: Time is required');
      }
      if (entry.marksController.text.isEmpty) {
        errors.add('Exam ${i + 1}: Marks is required');
      }

      // If all required fields are filled, add to valid entries
      if (entry.subject != null &&
          entry.selectedDate != null &&
          entry.selectedTime != null &&
          entry.marksController.text.isNotEmpty) {
        validEntries.add(entry);
      }
    }

    if (errors.isNotEmpty) {
      Get.snackbar(
        'Validation Error',
        errors.join('\n'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    if (validEntries.isEmpty) {
      Get.snackbar(
        'Error',
        'Please add at least one exam with all required fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final controller = Get.find<ExamController>();
    int addCount = 0;
    int updateCount = 0;

    setState(() => _isSaving = true);
    try {
      for (var entry in validEntries) {
        // Ensure examDate is properly constructed
        final examDateTime = DateTime(
          entry.selectedDate!.year,
          entry.selectedDate!.month,
          entry.selectedDate!.day,
          entry.selectedTime!.hour,
          entry.selectedTime!.minute,
        );

        final exam = ExamModel(
          id: entry.examId ?? DateTime.now().millisecondsSinceEpoch.toString(),
          examTypeId: widget.examTypeId,
          name: '${entry.subject} Exam',
          type: 'final', // Default type for scheduled exams
          subject: entry.subject!,
          classId: widget.classId,
          section: widget.section,
          teacherId: 'admin',
          totalMarks: double.parse(entry.marksController.text),
          durationMinutes: entry.durationController.text.isNotEmpty
              ? int.parse(entry.durationController.text)
              : null,
          examDate: examDateTime,
          instructions: null,
          syllabus: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Check if this is an update or new addition
        if (entry.examId != null) {
          await controller.updateExam(exam);
          updateCount++;
        } else {
          await controller.addExam(exam);
          addCount++;
        }

        // Small delay to avoid overwhelming the API
        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (mounted) {
        Get.back();
      }

      // Show appropriate success message
      String message;
      if (addCount > 0 && updateCount > 0) {
        message =
            '$updateCount exam${updateCount > 1 ? 's' : ''} updated, $addCount new exam${addCount > 1 ? 's' : ''} added';
      } else if (updateCount > 0) {
        message =
            '$updateCount exam${updateCount > 1 ? 's' : ''} updated successfully';
      } else {
        message = '$addCount exam${addCount > 1 ? 's' : ''} added successfully';
      }

      Get.snackbar(
        'Success',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      if (addCount + updateCount > 0) {
        Get.snackbar(
          'Partial Success',
          '${addCount + updateCount} out of ${validEntries.length} changes were saved',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to save exams: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _getClassDisplayName() {
    final classCtrl = Get.find<ClassController>();
    final cls = classCtrl.classes.firstWhereOrNull(
      (c) => c.id == widget.classId,
    );
    final className = cls?.name.trim();
    if (className == null || className.isEmpty) {
      return widget.classId;
    }
    return className;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isEditing) {
      return _buildEditMode(theme);
    } else {
      return _buildBulkAddMode(theme);
    }
  }

  Widget _buildEditMode(ThemeData theme) {
    return Scaffold(
      appBar: AdminPageHeader(
        subtitle: 'Configure examination details',
        icon: Icons.assignment,
        showBreadcrumb: true,
        breadcrumbLabel: 'Exams',
        showBackButton: true,
        title: const Text('Edit Exam'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Context Card
            Card(
              elevation: 0,
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${_getClassDisplayName()} - Section ${widget.section}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Subject and Type
            Row(
              children: [
                Expanded(
                  child: SubjectDropdown(
                    initialValue: _selectedSubject,
                    labelText: 'Subject *',
                    classId: widget.classId,
                    onChanged: (value) {
                      setState(() {
                        _selectedSubject = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomDropdown<String>(
                    labelText: 'Type *',
                    value: _selectedType,
                    prefixIcon: const Icon(Icons.category),
                    items: const [
                      DropdownMenuItem(value: 'quiz', child: Text('QUIZ')),
                      DropdownMenuItem(
                          value: 'mid-term', child: Text('MID-TERM')),
                      DropdownMenuItem(value: 'final', child: Text('FINAL')),
                      DropdownMenuItem(
                          value: 'assignment', child: Text('ASSIGNMENT')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value ?? 'quiz';
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Date and Time
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    labelText: 'Exam Date *',
                    hintText: 'Select date',
                    controller: TextEditingController(
                      text: DateFormat('MMM dd, yyyy').format(_examDate),
                    ),
                    readOnly: true,
                    prefixIcon: const Icon(Icons.calendar_today),
                    onTap: _selectDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    labelText: 'Start Time *',
                    hintText: 'Select time',
                    controller: TextEditingController(
                      text: _examTime.format(context),
                    ),
                    readOnly: true,
                    prefixIcon: const Icon(Icons.access_time),
                    onTap: _selectTime,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Marks and Duration
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    labelText: 'Total Marks *',
                    hintText: 'Enter marks',
                    controller: _totalMarksController,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.grade),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    labelText: 'Duration (min)',
                    hintText: 'Minutes',
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.timer),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _saveExam,
                icon: _isSaving
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.update),
                label: Text(_isSaving ? 'Updating...' : 'Update Exam'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulkAddMode(ThemeData theme) {
    final isEditMode =
        widget.existingExams != null && widget.existingExams!.isNotEmpty;

    return Scaffold(
      appBar: AdminPageHeader(
        subtitle: isEditMode
            ? 'Review and update each scheduled exam'
            : 'Create a complete exam schedule for this class',
        icon: Icons.event_note_rounded,
        showBreadcrumb: true,
        breadcrumbLabel: 'Exams',
        showBackButton: true,
        title:
            Text(isEditMode ? 'Edit Exam Timetable' : 'Create Exam Timetable'),
        actions: [
          HeaderActionButton(
            icon: Icons.add_rounded,
            label: 'Add Row',
            onPressed: () {
              if (!_isSaving) {
                _addEmptyEntry();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.school_rounded,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Class',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getClassDisplayName(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Section ${widget.section}',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    final examType = Get.find<ExamTypeController>()
                        .examTypeList
                        .firstWhereOrNull((e) => e.id == widget.examTypeId);
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.event_note_rounded,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Exam: ${examType?.name ?? "Loading..."}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Add subject, date, time and marks for each exam row.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${_examEntries.length} rows',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              itemCount: _examEntries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _buildExamEntryRow(theme, index);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.22),
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSaving ? null : () => Get.back(),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _isSaving ? null : _saveBulkExams,
                      icon: _isSaving
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.onPrimary,
                              ),
                            )
                          : Icon(isEditMode
                              ? Icons.update_rounded
                              : Icons.save_rounded),
                      label: Text(
                        _isSaving
                            ? (isEditMode ? 'Updating...' : 'Saving...')
                            : (isEditMode
                                ? 'Update Timetable'
                                : 'Save All Exams'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamEntryRow(ThemeData theme, int index) {
    final entry = _examEntries[index];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 880;

        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Exam ${index + 1}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (entry.examId != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiaryContainer
                              .withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Existing',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onTertiaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      onPressed: _examEntries.length > 1 && !_isSaving
                          ? () => _removeEntry(index)
                          : null,
                      color: theme.colorScheme.error,
                      tooltip: 'Remove row',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                isWide
                    ? _buildWideLayout(entry, theme)
                    : _buildNarrowLayout(entry, theme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWideLayout(ExamEntry entry, ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: SubjectDropdown(
                initialValue: entry.subject,
                labelText: 'Subject *',
                classId: widget.classId,
                onChanged: (value) {
                  setState(() {
                    entry.subject = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: _buildDateField(entry),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: _buildTimeField(entry),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildMarksField(entry)),
            const SizedBox(width: 10),
            Expanded(child: _buildDurationField(entry)),
          ],
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(ExamEntry entry, ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldStack = constraints.maxWidth < 440;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SubjectDropdown(
              initialValue: entry.subject,
              labelText: 'Subject *',
              classId: widget.classId,
              onChanged: (value) {
                setState(() {
                  entry.subject = value;
                });
              },
            ),
            const SizedBox(height: 10),
            if (shouldStack) ...[
              _buildDateField(entry),
              const SizedBox(height: 10),
              _buildTimeField(entry),
              const SizedBox(height: 10),
              _buildMarksField(entry),
              const SizedBox(height: 10),
              _buildDurationField(entry),
            ] else ...[
              Row(
                children: [
                  Expanded(child: _buildDateField(entry)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTimeField(entry)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildMarksField(entry)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildDurationField(entry)),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDateField(ExamEntry entry) {
    return CustomTextField(
      controller: entry.dateController,
      readOnly: true,
      labelText: 'Date *',
      hintText: 'Select date',
      prefixIcon: const Icon(Icons.calendar_month_rounded),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate:
              entry.selectedDate ?? DateTime.now().add(const Duration(days: 7)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          setState(() {
            entry.selectedDate = date;
            entry.dateController.text = DateFormat('MMM dd, yyyy').format(date);
          });
        }
      },
    );
  }

  Widget _buildTimeField(ExamEntry entry) {
    return CustomTextField(
      controller: entry.timeController,
      readOnly: true,
      labelText: 'Time *',
      hintText: 'Select time',
      prefixIcon: const Icon(Icons.access_time_rounded),
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime:
              entry.selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
        );
        if (time != null) {
          setState(() {
            entry.selectedTime = time;
            entry.timeController.text = time.format(context);
          });
        }
      },
    );
  }

  Widget _buildMarksField(ExamEntry entry) {
    return CustomTextField(
      controller: entry.marksController,
      keyboardType: TextInputType.number,
      labelText: 'Marks *',
      hintText: '100',
      prefixIcon: const Icon(Icons.grade_rounded),
    );
  }

  Widget _buildDurationField(ExamEntry entry) {
    return CustomTextField(
      controller: entry.durationController,
      keyboardType: TextInputType.number,
      labelText: 'Duration (min)',
      hintText: '120',
      prefixIcon: const Icon(Icons.timer_outlined),
    );
  }
}

class ExamEntry {
  String? examId; // For tracking existing exams during edit
  String? subject;
  String type = 'quiz';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController marksController = TextEditingController();
  final TextEditingController durationController = TextEditingController();

  DateTime? get selectedDateTime {
    if (selectedDate == null || selectedTime == null) return null;
    return DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );
  }

  void dispose() {
    dateController.dispose();
    timeController.dispose();
    marksController.dispose();
    durationController.dispose();
  }
}
