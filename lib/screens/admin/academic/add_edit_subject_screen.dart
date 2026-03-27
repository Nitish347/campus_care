import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/controllers/class_controller.dart';
import 'package:campus_care/controllers/subject_controller.dart';
import 'package:campus_care/controllers/teacher_controller.dart';
import 'package:campus_care/models/subject.dart';
import 'package:campus_care/widgets/buttons/primary_button.dart';
import 'package:campus_care/widgets/inputs/custom_dropdown.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:campus_care/widgets/admin/admin_page_header.dart';
class AddEditSubjectScreen extends StatefulWidget {
  final Subject? subject;

  const AddEditSubjectScreen({super.key, this.subject});

  @override
  State<AddEditSubjectScreen> createState() => _AddEditSubjectScreenState();
}

class _AddEditSubjectScreenState extends State<AddEditSubjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final SubjectController _subjectController = Get.find<SubjectController>();
  final ClassController _classController = Get.put(ClassController());
  final TeacherController _teacherController = Get.put(TeacherController());
  final AuthController _authController = Get.find<AuthController>();

  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _descriptionController;

  String? selectedClassId;
  String? selectedTeacherId;

  bool get isEditMode => widget.subject != null;

  @override
  void initState() {
    super.initState();
    _classController.fetchClasses();
    _teacherController.loadTeachers();

    _nameController = TextEditingController(text: widget.subject?.name ?? '');
    _codeController = TextEditingController(text: widget.subject?.code ?? '');
    _descriptionController =
        TextEditingController(text: widget.subject?.description ?? '');

    selectedClassId = widget.subject?.classId;
    selectedTeacherId = widget.subject?.teacherId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveSubject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final subject = Subject(
      id: widget.subject?.id ?? '',
      name: _nameController.text.trim(),
      code: _codeController.text.trim(),
      description: _descriptionController.text.trim(),
      classId: selectedClassId,
      teacherId: selectedTeacherId,
      instituteId: _authController.currentAdmin?.id ?? '',
      createdAt: widget.subject?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (isEditMode) {
      await _subjectController.updateSubject(subject);
    } else {
      await _subjectController.addSubject(subject);
    }

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdminPageHeader(
        subtitle: 'Manage subject details',
        icon: Icons.book,
        showBreadcrumb: true,
        breadcrumbLabel: 'Subjects',
        showBackButton: true,
        title: Text(isEditMode ? 'Edit Subject' : 'Add Subject'),
      ),
      body: ResponsivePadding(
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 16),

              // Subject Name
              CustomTextField(
                controller: _nameController,
                labelText: 'Subject Name',
                hintText: 'e.g., Mathematics',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Subject name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Subject Code
              CustomTextField(
                controller: _codeController,
                labelText: 'Subject Code',
                hintText: 'e.g., MATH101',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Subject code is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Description',
                hintText: 'Brief description of the subject',
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Class Selection
              Obx(() {
                return CustomDropdown<String>(
                  labelText: 'Class (Optional)',
                  hintText: 'Select Class',
                  value: selectedClassId,
                  onChanged: (val) {
                    setState(() {
                      selectedClassId = val;
                    });
                  },
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('None'),
                    ),
                    ..._classController.classes.map((classData) {
                      return DropdownMenuItem(
                        value: classData.id,
                        child: Text(
                            '${classData.name} - Grade ${classData.grade}'),
                      );
                    }).toList(),
                  ],
                );
              }),
              const SizedBox(height: 16),

              // Teacher Assignment
              Obx(() {
                return CustomDropdown<String>(
                  labelText: 'Assign Teacher (Optional)',
                  hintText: 'Select Teacher',
                  value: selectedTeacherId,
                  onChanged: (val) {
                    setState(() {
                      selectedTeacherId = val;
                    });
                  },
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('None'),
                    ),
                    ..._teacherController.teachers.map((teacher) {
                      return DropdownMenuItem(
                        value: teacher.id,
                        child: Text(teacher.fullName),
                      );
                    }).toList(),
                  ],
                );
              }),
              const SizedBox(height: 32),

              // Save Button
              Obx(() {
                return PrimaryButton(
                  onPressed:
                      _subjectController.isLoading.value ? null : _saveSubject,
                  child: _subjectController.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(isEditMode ? 'Update Subject' : 'Add Subject'),
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
