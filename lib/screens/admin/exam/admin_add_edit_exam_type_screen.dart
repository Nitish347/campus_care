import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/models/exam_type_model.dart';
import 'package:campus_care/controllers/exam_type_controller.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';

class AdminAddEditExamTypeScreen extends StatefulWidget {
  final ExamTypeModel? examType;

  const AdminAddEditExamTypeScreen({super.key, this.examType});

  @override
  State<AdminAddEditExamTypeScreen> createState() =>
      _AdminAddEditExamTypeScreenState();
}

class _AdminAddEditExamTypeScreenState
    extends State<AdminAddEditExamTypeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  bool _isActive = true;

  bool get _isEditing => widget.examType != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.examType!.name;
      _descriptionController.text = widget.examType!.description ?? '';
      _startDate = widget.examType!.startDate;
      _endDate = widget.examType!.endDate;
      _isActive = widget.examType!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );

    if (date != null) {
      setState(() {
        _startDate = date;
        // Ensure end date is after start date
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 7));
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate.isBefore(_startDate)
          ? _startDate.add(const Duration(days: 1))
          : _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );

    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  Future<void> _saveExamType() async {
    if (_formKey.currentState!.validate()) {
      if (_endDate.isBefore(_startDate)) {
        Get.snackbar(
          'Error',
          'End date must be after start date',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final controller = Get.find<ExamTypeController>();

      final examType = ExamTypeModel(
        id: _isEditing
            ? widget.examType!.id
            : DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        startDate: _startDate,
        endDate: _endDate,
        isActive: _isActive,
        createdAt: _isEditing ? widget.examType!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      try {
        if (_isEditing) {
          await controller.updateExamType(examType);
          Get.back();
        } else {
          await controller.addExamType(examType);
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
        title: Text(_isEditing ? 'Edit Exam Schedule' : 'Add Exam Schedule'),
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
                  Icons.event_note,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  _isEditing
                      ? 'Update Exam Schedule Details'
                      : 'Create New Exam Schedule',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'An exam schedule groups multiple subject exams together',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Exam Schedule Name
            CustomTextField(
              labelText: 'Exam Schedule Name *',
              hintText: 'e.g., Semester 1 Final Exam',
              controller: _nameController,
              prefixIcon: const Icon(Icons.title),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter exam schedule name';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Description
            CustomTextField(
              labelText: 'Description (Optional)',
              hintText: 'Enter exam schedule description',
              controller: _descriptionController,
              maxLines: 3,
              prefixIcon: const Icon(Icons.description),
            ),

            const SizedBox(height: 24),

            // Date Range Section
            Text(
              'Exam Period',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Start Date
            CustomTextField(
              labelText: 'Start Date *',
              hintText: 'Select start date',
              controller: TextEditingController(
                text: DateFormat('EEEE, MMMM dd, yyyy').format(_startDate),
              ),
              readOnly: true,
              prefixIcon: const Icon(Icons.event),
              onTap: _selectStartDate,
            ),

            const SizedBox(height: 16),

            // End Date
            CustomTextField(
              labelText: 'End Date *',
              hintText: 'Select end date',
              controller: TextEditingController(
                text: DateFormat('EEEE, MMMM dd, yyyy').format(_endDate),
              ),
              readOnly: true,
              prefixIcon: const Icon(Icons.event_available),
              onTap: _selectEndDate,
            ),

            const SizedBox(height: 24),

            // Active Status
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
              child: SwitchListTile(
                title: const Text('Active Status'),
                subtitle: Text(
                  _isActive
                      ? 'This exam schedule is active and visible'
                      : 'This exam schedule is inactive and hidden',
                  style: theme.textTheme.bodySmall,
                ),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
                secondary: Icon(
                  _isActive ? Icons.check_circle : Icons.cancel,
                  color: _isActive ? Colors.green : Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _saveExamType,
                icon: Icon(_isEditing ? Icons.update : Icons.add),
                label: Text(_isEditing ? 'Update Schedule' : 'Create Schedule'),
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
