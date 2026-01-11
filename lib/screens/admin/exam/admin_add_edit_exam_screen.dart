import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/models/exam_model.dart';
import 'package:campus_care/controllers/exam_controller.dart';
import 'package:campus_care/controllers/exam_type_controller.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:campus_care/widgets/inputs/custom_dropdown.dart';

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

  final List<String> _subjects = [
    'Mathematics',
    'Science',
    'English',
    'History',
    'Computer Science',
    'Physics',
    'Chemistry',
    'Biology',
  ];

  bool get _isEditing => widget.exam != null;
  bool _hasInitialized = false;

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

      try {
        await controller.updateExam(exam);
        Get.back();
      } catch (e) {
        // Error already shown by controller
      }
    }
  }

  Future<void> _saveBulkExams() async {
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

      Get.back();

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
    }
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
      appBar: AppBar(
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
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Class: ${widget.classId} - Section ${widget.section}',
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
                  child: CustomDropdown<String>(
                    labelText: 'Subject *',
                    value: _selectedSubject,
                    prefixIcon: const Icon(Icons.book),
                    items: _subjects
                        .map((subject) => DropdownMenuItem(
                              value: subject,
                              child: Text(subject),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSubject = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select subject';
                      }
                      return null;
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
                onPressed: _saveExam,
                icon: const Icon(Icons.update),
                label: const Text('Update Exam'),
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
      appBar: AppBar(
        title: Text(
            isEditMode ? 'Edit Exam Timetable' : 'Add Exams - Timetable Style'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addEmptyEntry,
            tooltip: 'Add Row',
          ),
        ],
      ),
      body: Column(
        children: [
          // Context Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.class_, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Class ${widget.classId} - Section ${widget.section}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Obx(() {
                  final examType = Get.find<ExamTypeController>()
                      .examTypeList
                      .firstWhereOrNull((e) => e.id == widget.examTypeId);
                  return Row(
                    children: [
                      Icon(Icons.event_note,
                          size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Exam: ${examType?.name ?? "Loading..."}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),

          // Table Header with horizontal scroll
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 40), // For delete button space
                  SizedBox(
                    width: 180,
                    child: Text(
                      'Subject *',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 140,
                    child: Text(
                      'Date *',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: Text(
                      'Time *',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: Text(
                      'Marks *',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: Text(
                      'Duration (min)',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Exam Entries List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _examEntries.length,
              itemBuilder: (context, index) {
                return _buildExamEntryRow(theme, index);
              },
            ),
          ),

          // Save Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _saveBulkExams,
                    icon: Icon(isEditMode ? Icons.update : Icons.save),
                    label: Text(
                        isEditMode ? 'Update Timetable' : 'Save All Exams'),
                  ),
                ),
              ],
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
        final isWide = constraints.maxWidth > 700;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: isWide
                ? _buildWideLayout(entry, index, theme)
                : _buildNarrowLayout(entry, index, theme),
          ),
        );
      },
    );
  }

  Widget _buildWideLayout(ExamEntry entry, int index, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Delete Button
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: _examEntries.length > 1 ? () => _removeEntry(index) : null,
          color: Colors.red,
          tooltip: 'Remove',
        ),
        const SizedBox(width: 8),

        // Subject
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            value: entry.subject,
            decoration: const InputDecoration(
              isDense: true,
              labelText: 'Subject',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(),
            ),
            hint: const Text('Select'),
            items: _subjects
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (value) {
              setState(() {
                entry.subject = value;
              });
            },
          ),
        ),
        const SizedBox(width: 8),

        // Date
        Expanded(
          flex: 2,
          child: _buildDateField(entry),
        ),
        const SizedBox(width: 8),

        // Time
        Expanded(
          child: _buildTimeField(entry),
        ),
        const SizedBox(width: 8),

        // Marks
        Expanded(
          child: _buildMarksField(entry),
        ),
        const SizedBox(width: 8),

        // Duration
        Expanded(
          child: _buildDurationField(entry),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(ExamEntry entry, int index, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header with delete button
        Row(
          children: [
            Icon(Icons.assignment, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Exam ${index + 1}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed:
                  _examEntries.length > 1 ? () => _removeEntry(index) : null,
              color: Colors.red,
              tooltip: 'Remove',
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Subject dropdown
        DropdownButtonFormField<String>(
          value: entry.subject,
          decoration: const InputDecoration(
            isDense: true,
            labelText: 'Subject',
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(),
          ),
          hint: const Text('Select subject'),
          items: _subjects
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (value) {
            setState(() {
              entry.subject = value;
            });
          },
        ),
        const SizedBox(height: 8),

        // Date and Time row
        Row(
          children: [
            Expanded(child: _buildDateField(entry)),
            const SizedBox(width: 8),
            Expanded(child: _buildTimeField(entry)),
          ],
        ),
        const SizedBox(height: 8),

        // Marks and Duration row
        Row(
          children: [
            Expanded(child: _buildMarksField(entry)),
            const SizedBox(width: 8),
            Expanded(child: _buildDurationField(entry)),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField(ExamEntry entry) {
    return TextField(
      controller: entry.dateController,
      readOnly: true,
      decoration: const InputDecoration(
        isDense: true,
        labelText: 'Date',
        hintText: 'Select date',
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_today, size: 18),
      ),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(const Duration(days: 7)),
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
    return TextField(
      controller: entry.timeController,
      readOnly: true,
      decoration: const InputDecoration(
        isDense: true,
        labelText: 'Time',
        hintText: 'Select time',
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.access_time, size: 18),
      ),
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: const TimeOfDay(hour: 9, minute: 0),
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
    return TextField(
      controller: entry.marksController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        isDense: true,
        labelText: 'Marks',
        hintText: '100',
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.grade, size: 18),
      ),
    );
  }

  Widget _buildDurationField(ExamEntry entry) {
    return TextField(
      controller: entry.durationController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        isDense: true,
        labelText: 'Duration (min)',
        hintText: '120',
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.timer, size: 18),
      ),
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
