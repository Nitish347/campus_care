import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/models/exam_type_model.dart';
import 'package:campus_care/controllers/exam_type_controller.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';

import 'package:campus_care/widgets/admin/admin_page_header.dart';
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
  final _weightageController = TextEditingController();

  bool _isActive = true;

  bool get _isEditing => widget.examType != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.examType!.name;
      _descriptionController.text = widget.examType!.description ?? '';
      _weightageController.text = widget.examType!.weightage?.toString() ?? '';
      _isActive = widget.examType!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _weightageController.dispose();
    super.dispose();
  }

  Future<void> _saveExamType() async {
    if (_formKey.currentState!.validate()) {
      final controller = Get.find<ExamTypeController>();

      final examType = ExamTypeModel(
        id: _isEditing
            ? widget.examType!.id
            : DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        weightage: _weightageController.text.trim().isNotEmpty
            ? int.tryParse(_weightageController.text.trim())
            : null,
        isActive: _isActive,
        createdAt: _isEditing ? widget.examType!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      try {
        if (_isEditing) {
          await controller.updateExamType(examType);
        } else {
          await controller.addExamType(examType);
        }
        Get.back();
      } catch (e) {
        // Error already shown by controller
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AdminPageHeader(
        subtitle: 'Manage exam types',
        icon: Icons.category,
        showBreadcrumb: true,
        breadcrumbLabel: 'Exam Types',
        showBackButton: true,
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

            // Name
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

            const SizedBox(height: 16),

            // Weightage
            CustomTextField(
              labelText: 'Weightage % (Optional)',
              hintText: 'e.g., 30',
              controller: _weightageController,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.percent),
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  final v = int.tryParse(value.trim());
                  if (v == null || v < 0 || v > 100) {
                    return 'Must be 0–100';
                  }
                }
                return null;
              },
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
