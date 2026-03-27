import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/controllers/class_controller.dart';
import 'package:campus_care/models/class.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:campus_care/widgets/buttons/primary_button.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/common/section_header.dart';

import 'package:campus_care/widgets/admin/admin_page_header.dart';
class AddClassScreen extends StatefulWidget {
  final SchoolClass? schoolClass;

  const AddClassScreen({super.key, this.schoolClass});

  @override
  State<AddClassScreen> createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  bool get isEditMode => widget.schoolClass != null;

  late final TextEditingController classNameController;
  late final TextEditingController gradeController;
  late final TextEditingController sectionController;
  late final TextEditingController teacherController;
  late final RxList<String> selectedSubjects;

  @override
  void initState() {
    super.initState();
    classNameController = TextEditingController(
      text: isEditMode ? widget.schoolClass!.name : '',
    );
    gradeController = TextEditingController(
      text: isEditMode ? widget.schoolClass!.grade : '',
    );
    sectionController = TextEditingController(
      text: isEditMode ? widget.schoolClass!.sections.join(', ') : '',
    );
    teacherController = TextEditingController(
      text: isEditMode ? (widget.schoolClass!.teacherId ?? '') : '',
    );
    selectedSubjects = (isEditMode
            ? (widget.schoolClass!.subjects?.cast<String>() ?? <String>[])
            : <String>[])
        .obs;
  }

  @override
  void dispose() {
    classNameController.dispose();
    gradeController.dispose();
    sectionController.dispose();
    teacherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ClassController classController = Get.find<ClassController>();

    return Scaffold(
      appBar: AdminPageHeader(
        subtitle: 'Manage class details',
        icon: Icons.class_,
        showBreadcrumb: true,
        breadcrumbLabel: 'Classes',
        showBackButton: true,
        title: Text(isEditMode ? 'Edit Class' : 'Add New Class'),
      ),
      body: SingleChildScrollView(
        child: ResponsivePadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(title: 'Class Information'),
              const SizedBox(height: 16),
              CustomTextField(
                controller: classNameController,
                labelText: 'Class Name *',
                hintText: 'e.g., Class 1',
                prefixIcon: const Icon(Icons.class_),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: gradeController,
                labelText: 'Grade *',
                hintText: 'e.g., 1',
                prefixIcon: const Icon(Icons.grade),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: sectionController,
                labelText: 'Initial Sections (comma separated)',
                hintText: 'e.g., A, B, C',
                prefixIcon: const Icon(Icons.list),
              ),
              const SizedBox(height: 16),
              // Backend Model doesn't explicitly have Room Number but we can keep it if we update model later.
              // For now, I will omit or map it to something else if needed, but since model doesn't have it, I'll remove it to avoid confusion or keep it as UI only for now.
              // Let's stick to what the model supports: name, grade, sections.

              CustomTextField(
                controller: teacherController,
                labelText: 'Class Teacher ID (Optional)',
                hintText: 'Enter teacher ID',
                prefixIcon: const Icon(Icons.person),
              ),
              const SizedBox(height: 16),
              SectionHeader(title: 'Subjects'),
              const SizedBox(height: 12),
              Obx(() => Wrap(
                    spacing: 8,
                    children: [
                      'Mathematics',
                      'Science',
                      'English',
                      'History',
                      'Geography',
                      'Hindi',
                      'Computer'
                    ]
                        .map((subject) => FilterChip(
                              label: Text(subject),
                              selected: selectedSubjects.contains(subject),
                              onSelected: (selected) {
                                if (selected) {
                                  selectedSubjects.add(subject);
                                } else {
                                  selectedSubjects.remove(subject);
                                }
                              },
                            ))
                        .toList(),
                  )),
              const SizedBox(height: 24),
              Obx(() => PrimaryButton(
                    onPressed: classController.isLoading.value
                        ? null
                        : () {
                            if (classNameController.text.isEmpty ||
                                gradeController.text.isEmpty) {
                              Get.snackbar(
                                  'Error', 'Please fill Class Name and Grade');
                              return;
                            }

                            final sections = sectionController.text
                                .split(',')
                                .map((e) => e.trim())
                                .where((e) => e.isNotEmpty)
                                .toList();

                            final classData = {
                              'name': classNameController.text.trim(),
                              'grade': gradeController.text.trim(),
                              'sections': sections,
                              'subjects': selectedSubjects.toList(),
                            };
                            if (teacherController.text.isNotEmpty) {
                              classData['teacherId'] =
                                  teacherController.text.trim();
                            }

                            if (isEditMode) {
                              classController.updateClass(
                                widget.schoolClass!.id,
                                classData,
                              );
                            } else {
                              classController.addClass(classData);
                            }
                          },
                    child: classController.isLoading.value
                        ? const CircularProgressIndicator()
                        : Text(isEditMode ? 'Update Class' : 'Add Class'),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
