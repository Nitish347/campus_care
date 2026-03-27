import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/controllers/medical_record_controller.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:campus_care/widgets/inputs/custom_dropdown.dart';
import 'package:campus_care/widgets/buttons/primary_button.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/common/section_header.dart';

import 'package:campus_care/widgets/admin/admin_page_header.dart';
class AddMedicalRecordScreen extends StatelessWidget {
  const AddMedicalRecordScreen({super.key});

  // Static UI data
  static final _students = List.generate(20, (index) {
    return {
      'id': 'student_${index + 1}',
      'name': 'Student ${index + 1}',
      'studentId': 'STU2024${(index + 1).toString().padLeft(3, '0')}',
    };
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MedicalRecordController());

    return Scaffold(
      appBar: AdminPageHeader(
        subtitle: 'Update student health records',
        icon: Icons.medical_services,
        showBreadcrumb: true,
        breadcrumbLabel: 'Medical',
        showBackButton: true,
        title: const Text('Add Medical Record'),
      ),
      body: SingleChildScrollView(
        child: ResponsivePadding(
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(title: 'Medical Record Information'),
                const SizedBox(height: 16),
                CustomDropdown<String>(
                  value: controller.selectedStudent,
                  labelText: 'Student *',
                  prefixIcon: const Icon(Icons.person),
                  items: _students.map((student) => DropdownMenuItem(
                    value: student['id'],
                    child: Text('${student['name']} (${student['studentId']})'),
                  )).toList(),
                  onChanged: (value) {
                    controller.selectedStudent = value;
                    controller.update();
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select student';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomDropdown<String>(
                  value: controller.selectedType,
                  labelText: 'Record Type *',
                  prefixIcon: const Icon(Icons.medical_services),
                  items: ['Checkup', 'Treatment', 'Emergency']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    controller.selectedType = value;
                    controller.update();
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select record type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.descriptionController,
                  labelText: 'Description *',
                  hintText: 'Enter description',
                  prefixIcon: const Icon(Icons.description),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.prescriptionController,
                  labelText: 'Prescription',
                  hintText: 'Enter prescription details',
                  maxLines: 3,
                  prefixIcon: const Icon(Icons.medication),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.notesController,
                  labelText: 'Notes',
                  hintText: 'Additional notes',
                  maxLines: 3,
                  prefixIcon: const Icon(Icons.note),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  readOnly: true,
                  labelText: 'Record Date *',
                  hintText: controller.recordDate == null
                      ? 'Select Date'
                      : DateFormat('MMM dd, yyyy').format(controller.recordDate!),
                  prefixIcon: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      controller.recordDate = picked;
                      controller.update();
                    }
                  },
                  validator: (value) {
                    if (controller.recordDate == null) {
                      return 'Please select date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  onPressed: controller.saveRecord,
                  child: const Text('Save Medical Record'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

