import 'package:campus_care/widgets/inputs/class_section_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/models/homework_model.dart';
import 'package:campus_care/controllers/homework_controller.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:campus_care/widgets/inputs/custom_dropdown.dart';

class AddEditHomeworkScreen extends StatefulWidget {
  final HomeWorkModel? homework;

  const AddEditHomeworkScreen({super.key, this.homework});

  @override
  State<AddEditHomeworkScreen> createState() => _AddEditHomeworkScreenState();
}

class _AddEditHomeworkScreenState extends State<AddEditHomeworkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _totalMarksController = TextEditingController();

  String? _selectedSubject;
  String _selectedClass = '';
  String _selectedSection = '';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  String _selectedPriority = 'medium';

  final List<String> _subjects = [
    'Mathematics',
    'Science',
    'English',
    'History',
    'Computer Science',
  ];

  final List<String> _priorities = ['low', 'medium', 'high'];

  bool get _isEditing => widget.homework != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.homework!.title;
      _descriptionController.text = widget.homework!.description;
      _selectedSubject = widget.homework!.subject;
      _dueDate = widget.homework!.dueDate;
      _selectedClass = widget.homework!.classId;
      _selectedSection = widget.homework!.section;
      _selectedPriority = widget.homework!.priority;
      if (widget.homework!.totalMarks != null) {
        _totalMarksController.text =
            widget.homework!.totalMarks!.toStringAsFixed(0);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _totalMarksController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
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
        });
      }
    }
  }

  Future<void> _saveHomework() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedClass.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please select a class',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_selectedSection.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please select a section',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final controller = Get.find<HomeworkController>();

    final homework = HomeWorkModel(
      id: _isEditing ? widget.homework!.id : '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      subject: _selectedSubject!,
      teacherId: _isEditing ? widget.homework!.teacherId : '',
      classId: _selectedClass,
      section: _selectedSection,
      assignedStudents: _isEditing ? widget.homework!.assignedStudents : [],
      dueDate: _dueDate,
      createdAt: _isEditing ? widget.homework!.createdAt : DateTime.now(),
      priority: _selectedPriority,
      totalMarks: _totalMarksController.text.isNotEmpty
          ? double.tryParse(_totalMarksController.text.trim())
          : null,
    );

    try {
      if (_isEditing) {
        await controller.updateHomework(homework);
      } else {
        await controller.addHomework(homework);
      }
      if (mounted) Get.back();
    } catch (_) {
      // Error snackbar is shown in the controller
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
            const SizedBox(height: 10),

            // Class/Section Dropdown
            ClassSectionDropDown(
              padding: 0,
              onChangedClass: (String classId) {
                setState(() {
                  _selectedClass = classId;
                });
              },
              onChangedSection: (String section) {
                setState(() {
                  _selectedSection = section;
                });
              },
            ),

            const SizedBox(height: 24),

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
            CustomDropdown<String>(
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
                  return 'Please select a subject';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Priority
            CustomDropdown<String>(
              labelText: 'Priority',
              value: _selectedPriority,
              prefixIcon: const Icon(Icons.flag),
              items: _priorities
                  .map((p) => DropdownMenuItem(
                        value: p,
                        child: Text(p[0].toUpperCase() + p.substring(1)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPriority = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Due Date
            CustomTextField(
              labelText: 'Due Date *',
              hintText: 'Select due date and time',
              controller: TextEditingController(
                text: DateFormat('EEEE, MMMM dd, yyyy - hh:mm a')
                    .format(_dueDate),
              ),
              readOnly: true,
              prefixIcon: const Icon(Icons.calendar_today),
              onTap: _selectDueDate,
            ),

            const SizedBox(height: 16),

            // Total Marks
            CustomTextField(
              labelText: 'Total Marks',
              hintText: 'Enter total marks (optional)',
              controller: _totalMarksController,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.grade),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a valid number greater than 0';
                  }
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            // Save Button
            Obx(() {
              final controller = Get.find<HomeworkController>();
              return SizedBox(
                height: 50,
                child: FilledButton.icon(
                  onPressed: controller.isLoading.value ? null : _saveHomework,
                  icon: controller.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(_isEditing ? Icons.update : Icons.add),
                  label: Text(_isEditing ? 'Update Homework' : 'Add Homework'),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
