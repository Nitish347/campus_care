import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:campus_care/widgets/inputs/custom_dropdown.dart';
import 'package:campus_care/widgets/buttons/primary_button.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/common/section_header.dart';

class AddClassScreen extends StatelessWidget {
  const AddClassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final classNameController = TextEditingController();
    final roomController = TextEditingController();
    final teacherController = TextEditingController();
    String? selectedSection;
    final selectedSubjects = <String>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Class'),
      ),
      body: SingleChildScrollView(
        child: ResponsivePadding(
          child: StatefulBuilder(
            builder: (context, setState) => Column(
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
                CustomDropdown<String>(
                  value: selectedSection,
                  labelText: 'Section *',
                  items: ['A', 'B', 'C', 'D']
                      .map((sec) => DropdownMenuItem(
                            value: sec,
                            child: Text(sec),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSection = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: roomController,
                  labelText: 'Room Number',
                  hintText: 'Enter room number',
                  prefixIcon: const Icon(Icons.meeting_room),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: teacherController,
                  labelText: 'Class Teacher',
                  hintText: 'Enter teacher name',
                  prefixIcon: const Icon(Icons.person),
                ),
                const SizedBox(height: 16),
                SectionHeader(title: 'Subjects'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: ['Mathematics', 'Science', 'English', 'History', 'Geography']
                      .map((subject) => FilterChip(
                            label: Text(subject),
                            selected: selectedSubjects.contains(subject),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedSubjects.add(subject);
                                } else {
                                  selectedSubjects.remove(subject);
                                }
                              });
                            },
                          ))
                      .toList(),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  onPressed: () {
                    if (classNameController.text.isEmpty || selectedSection == null) {
                      Get.snackbar('Error', 'Please fill all required fields');
                      return;
                    }
                    Get.snackbar('Success', 'Class added successfully');
                    Get.offNamed(AppRoutes.classManagement);
                  },
                  child: const Text('Add Class'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

