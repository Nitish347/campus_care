import 'package:campus_care/widgets/inputs/class_section_dropdown.dart';
import 'package:campus_care/widgets/inputs/subject_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/models/homework_model.dart';
import 'package:campus_care/controllers/homework_controller.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:campus_care/widgets/inputs/custom_dropdown.dart';

class AdminAddEditHomeworkScreen extends StatefulWidget {
  final HomeWorkModel? homework;

  const AdminAddEditHomeworkScreen({super.key, this.homework});

  @override
  State<AdminAddEditHomeworkScreen> createState() =>
      _AdminAddEditHomeworkScreenState();
}

class _AdminAddEditHomeworkScreenState
    extends State<AdminAddEditHomeworkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _totalMarksController = TextEditingController();
  final _dueDateDisplayController = TextEditingController();

  String? _selectedClass;
  String? _selectedSection;
  String? _selectedSubject;
  String _selectedPriority = 'medium';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));

  final List<String> _priorities = ['low', 'medium', 'high'];

  bool get _isEditing => widget.homework != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.homework!.title;
      _descriptionController.text = widget.homework!.description;
      _selectedSubject = widget.homework!.subject;
      _selectedClass = widget.homework!.classId;
      _selectedSection = widget.homework!.section;
      _selectedPriority = widget.homework!.priority;
      _dueDate = widget.homework!.dueDate;
      _totalMarksController.text =
          widget.homework!.totalMarks?.toString() ?? '';
    }
    // Always initialize the display controller to current _dueDate
    _dueDateDisplayController.text =
        DateFormat('EEEE, MMMM dd, yyyy - hh:mm a').format(_dueDate);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _totalMarksController.dispose();
    _dueDateDisplayController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dueDate),
      );

      if (time != null) {
        setState(() {
          _dueDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          // Update the display controller — do NOT create a new one
          _dueDateDisplayController.text =
              DateFormat('EEEE, MMMM dd, yyyy - hh:mm a').format(_dueDate);
        });
      }
    }
  }

  Future<void> _saveHomework() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedClass == null || _selectedSection == null) {
        Get.snackbar(
          'Error',
          'Please select class and section',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final controller = Get.find<HomeworkController>();

      final homework = HomeWorkModel(
        id: _isEditing
            ? widget.homework!.id
            : DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        subject: _selectedSubject!,
        teacherId: 'admin', // Will be set by backend
        classId: _selectedClass!,
        section: _selectedSection!,
        assignedStudents: [], // Will be populated by backend
        dueDate: _dueDate,
        createdAt: _isEditing ? widget.homework!.createdAt : DateTime.now(),
        priority: _selectedPriority,
        totalMarks: double.tryParse(_totalMarksController.text),
      );

      try {
        if (_isEditing) {
          await controller.updateHomework(homework);
          Get.back();
        } else {
          await controller.addHomework(homework);
          Get.back();
        }
      } catch (e) {
        // Error already shown by controller
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Homework' : 'Add Homework'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Column(
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  _isEditing
                      ? 'Update Homework Details'
                      : 'Create New Homework',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Class and Section Selection
            ClassSectionDropDown(
              padding: 0,
              onChangedClass: (classId) {
                setState(() {
                  _selectedClass = classId;
                });
              },
              onChangedSection: (section) {
                setState(() {
                  _selectedSection = section;
                });
              },
            ),

            const SizedBox(height: 16),

            // Title
            CustomTextField(
              labelText: 'Title *',
              hintText: 'Enter homework title',
              controller: _titleController,
              prefixIcon: const Icon(Icons.title),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Description
            CustomTextField(
              labelText: 'Description *',
              hintText: 'Enter homework description',
              controller: _descriptionController,
              maxLines: 4,
              prefixIcon: const Icon(Icons.description),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Subject
            SubjectDropdown(
              initialValue: _selectedSubject,
              labelText: 'Subject *',
              classId: _selectedClass,
              enabled: _selectedClass != null,
              onChanged: (value) {
                setState(() {
                  _selectedSubject = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // Priority
            CustomDropdown<String>(
              labelText: 'Priority *',
              value: _selectedPriority,
              prefixIcon: const Icon(Icons.flag),
              items: _priorities
                  .map((priority) => DropdownMenuItem(
                        value: priority,
                        child: Text(priority.toUpperCase()),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value ?? 'medium';
                });
              },
            ),

            const SizedBox(height: 16),

            // Due Date
            CustomTextField(
              labelText: 'Due Date *',
              hintText: 'Select due date and time',
              controller: _dueDateDisplayController,
              readOnly: true,
              prefixIcon: const Icon(Icons.calendar_today),
              onTap: _selectDueDate,
            ),

            const SizedBox(height: 16),

            // Total Marks
            CustomTextField(
              labelText: 'Total Marks *',
              hintText: 'Enter total marks',
              controller: _totalMarksController,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.grade),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter total marks';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _saveHomework,
                icon: Icon(_isEditing ? Icons.update : Icons.add),
                label: Text(_isEditing ? 'Update Homework' : 'Add Homework'),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
