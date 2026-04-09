import 'package:campus_care/controllers/class_controller.dart';
import 'package:campus_care/controllers/teacher_timetable_controller.dart';
import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'custom_dropdown.dart';

/// Unified ClassSectionDropDown with role-based filtering
/// - Teachers see only their assigned classes/sections (from timetable)
/// - Admins/Super Admins see all classes/sections
class ClassSectionDropDown extends StatefulWidget {
  final double? padding;
  final Function(String classId) onChangedClass;
  final Function(String section) onChangedSection;

  /// If true, automatically detects user role and filters accordingly
  /// Default: true
  final bool autoDetectRole;

  /// If true, forces filtering by teacher assignments regardless of role
  /// Default: false (only used if autoDetectRole is false)
  final bool filterByTeacherAssignments;
  final double? fieldHeight;

  const ClassSectionDropDown({
    super.key,
    this.padding,
    required this.onChangedClass,
    required this.onChangedSection,
    this.autoDetectRole = true,
    this.filterByTeacherAssignments = false,
    this.fieldHeight,
  });

  @override
  State<ClassSectionDropDown> createState() => _ClassSectionDropDownState();
}

class _ClassSectionDropDownState extends State<ClassSectionDropDown> {
  final ClassController _classController = Get.find<ClassController>();

  String? selectedClass;
  String? selectedSection;

  /// Determines if filtering should be applied based on teacher assignments
  bool get _shouldFilter {
    if (widget.autoDetectRole) {
      try {
        final authController = Get.find<AuthController>();
        final role = authController.currentRole;
        return role == AppConstants.roleTeacher;
      } catch (e) {
        debugPrint('AuthController not found, defaulting to no filter: $e');
        return false;
      }
    }
    return widget.filterByTeacherAssignments;
  }

  /// Get teacher timetable controller if available
  TeacherTimetableController? get _timetableController {
    try {
      return Get.find<TeacherTimetableController>();
    } catch (e) {
      debugPrint('TeacherTimetableController not found: $e');
      return null;
    }
  }

  /// Get available classes based on role
  List<Map<String, String>> _getAvailableClasses() {
    if (_shouldFilter && _timetableController != null) {
      // Teacher mode: get classes from timetable
      return _timetableController!.getUniqueClasses();
    } else {
      // Admin mode: get all classes
      return _classController.classes.map((classData) {
        return {
          'classId': classData.id,
          'className': classData.name,
        };
      }).toList();
    }
  }

  /// Get available sections for a class based on role
  List<String> _getAvailableSections(String classId) {
    if (_shouldFilter && _timetableController != null) {
      // Teacher mode: get sections from timetable
      final assignedClasses = _timetableController!.getUniqueClasses();
      return assignedClasses
          .where((c) => c['classId'] == classId)
          .map((c) => c['section']!)
          .toSet()
          .toList();
    } else {
      // Admin mode: get all sections from ClassController
      try {
        final classData = _classController.classes.firstWhere(
          (c) => c.id == classId,
        );
        return classData.sections;
      } catch (e) {
        debugPrint('Class not found: $classId');
        return [];
      }
    }
  }

  /// Get class name by ID
  String _getClassName(String classId) {
    try {
      final classData = _classController.classes.firstWhere(
        (c) => c.id == classId,
      );
      return classData.name;
    } catch (e) {
      return 'Class $classId';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final availableClasses = _getAvailableClasses();

      return Padding(
        padding: EdgeInsets.all(widget.padding ?? 16),
        child: Row(
          children: [
            // Class Dropdown
            Expanded(
              child: CustomDropdown<String>(
                hintText: "Select Class",
                labelText: "Class",
                fieldHeight: widget.fieldHeight,
                value: selectedClass,
                onChanged: (val) {
                  if (val == null) return;
                  setState(() {
                    selectedClass = val;
                    selectedSection = null; // Reset section when class changes
                  });
                  widget.onChangedClass(val);
                },
                items: availableClasses.map((classData) {
                  final classId = classData['classId']!;
                  final className =
                      classData['className'] ?? _getClassName(classId);
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
                fieldHeight: widget.fieldHeight,
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
                    : _getAvailableSections(selectedClass!).map((section) {
                        return DropdownMenuItem(
                          value: section,
                          child: Text(
                              _shouldFilter ? 'Section $section' : section),
                        );
                      }).toList(),
              ),
            ),
          ],
        ),
      );
    });
  }
}
