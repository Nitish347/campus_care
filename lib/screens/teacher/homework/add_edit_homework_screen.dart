import 'package:campus_care/widgets/buttons/primary_button.dart';
import 'package:campus_care/widgets/common/summary_card.dart';
import 'package:campus_care/widgets/inputs/class_section_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/models/homework_model.dart';
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

  String? _selectedSubject;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));

  final List<String> _subjects = [
    'Mathematics',
    'Science',
    'English',
    'History',
    'Computer Science',
  ];

  bool get _isEditing => widget.homework != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.homework!.title;
      _descriptionController.text = widget.homework!.description;
      _selectedSubject = widget.homework!.subject;
      _dueDate = widget.homework!.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
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
        });
      }
    }
  }

  void _saveHomework() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save homework to backend/storage
      Get.back();
      Get.snackbar(
        'Success',
        _isEditing
            ? 'Homework updated successfully'
            : 'Homework added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
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
            SizedBox(
              height: 10,
            ),
            ClassSectionDropDown(
              padding: 0,
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
            CustomTextField(
              labelText: 'Total Marks *',
              hintText: 'Enter total marks',
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.grade),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter total marks';
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
