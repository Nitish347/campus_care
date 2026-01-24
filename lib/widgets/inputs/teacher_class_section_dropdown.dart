import 'package:campus_care/controllers/teacher_timetable_controller.dart';
import 'package:campus_care/controllers/class_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'custom_dropdown.dart';

/// Filtered ClassSectionDropDown for teachers
/// Only shows classes and sections where the teacher is assigned
class TeacherClassSectionDropDown extends StatefulWidget {
  final double? padding;
  final Function(String classId) onChangedClass;
  final Function(String section) onChangedSection;

  const TeacherClassSectionDropDown({
    super.key,
    this.padding,
    required this.onChangedClass,
    required this.onChangedSection,
  });

  @override
  State<TeacherClassSectionDropDown> createState() =>
      _TeacherClassSectionDropDownState();
}

class _TeacherClassSectionDropDownState
    extends State<TeacherClassSectionDropDown> {
  final TeacherTimetableController _timetableController =
      Get.find<TeacherTimetableController>();
  final ClassController _classController = Get.find<ClassController>();

  String? selectedClass;
  String? selectedSection;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Get unique classes from teacher's timetable
      final assignedClasses = _timetableController.getUniqueClasses();

      // Get unique class IDs
      final uniqueClassIds =
          assignedClasses.map((c) => c['classId']!).toSet().toList();

      return Padding(
        padding: EdgeInsets.all(widget.padding ?? 16),
        child: Row(
          children: [
            // Class Dropdown
            Expanded(
              child: CustomDropdown<String>(
                hintText: "Select Class",
                labelText: "Class",
                value: selectedClass,
                onChanged: (val) {
                  if (val == null) return;
                  setState(() {
                    selectedClass = val;
                    selectedSection = null; // Reset section when class changes
                  });
                  widget.onChangedClass(val);
                },
                items: uniqueClassIds.map((classId) {
                  // Get the class name from ClassController
                  final className = _getClassName(classId);
                  return DropdownMenuItem(
                    value: classId,
                    child: Text(className),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(width: 10),

            // Section Dropdown
            Expanded(
              child: CustomDropdown<String>(
                hintText: "Select Section",
                labelText: "Section",
                value: selectedSection,
                onChanged: (val) {
                  if (val == null) return;
                  setState(() {
                    selectedSection = val;
                  });
                  widget.onChangedSection(val);
                },
                items: selectedClass == null
                    ? []
                    : _getSectionsForClass(assignedClasses, selectedClass!)
                        .map((section) {
                        return DropdownMenuItem(
                          value: section,
                          child: Text('Section $section'),
                        );
                      }).toList(),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Get class name from ClassController by ID
  String _getClassName(String classId) {
    try {
      final classData = _classController.classes.firstWhere(
        (c) => c.id == classId,
      );
      return classData.name;
    } catch (e) {
      // If not found in ClassController, return "Class {ID}"
      return 'Class $classId';
    }
  }

  /// Get unique sections for a specific class
  List<String> _getSectionsForClass(
    List<Map<String, String>> assignedClasses,
    String classId,
  ) {
    return assignedClasses
        .where((c) => c['classId'] == classId)
        .map((c) => c['section']!)
        .toSet()
        .toList();
  }
}
