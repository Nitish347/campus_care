import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/utils/app_notifier.dart';

class MedicalRecordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final studentNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final prescriptionController = TextEditingController();
  final notesController = TextEditingController();
  String? selectedStudent;
  String? selectedType;
  DateTime? recordDate;

  @override
  void onClose() {
    studentNameController.dispose();
    descriptionController.dispose();
    prescriptionController.dispose();
    notesController.dispose();
    super.onClose();
  }

  Future<void> saveRecord() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedStudent == null || selectedType == null || recordDate == null) {
      AppNotifier.error('Error', 'Please fill all required fields');
      return;
    }

    Get.back();
    AppNotifier.afterNavigation('Success', 'Medical record added successfully');
  }
}

