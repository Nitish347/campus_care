import 'package:campus_care/controllers/subject_controller.dart';
import 'package:campus_care/models/subject.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'custom_dropdown.dart';

/// Reusable Subject Dropdown Widget
/// Similar to ClassSectionDropdown but for subjects
class SubjectDropdown extends StatefulWidget {
  final String? initialValue;
  final Function(String? subjectId) onChanged;
  final String? labelText;
  final String? hintText;
  final String? classId; // Filter subjects by class
  final bool required;
  final bool enabled;

  const SubjectDropdown({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.labelText,
    this.hintText,
    this.classId,
    this.required = false,
    this.enabled = true,
  });

  @override
  State<SubjectDropdown> createState() => _SubjectDropdownState();
}

class _SubjectDropdownState extends State<SubjectDropdown> {
  final SubjectController _subjectController = Get.put(SubjectController());
  String? selectedSubject;

  @override
  void initState() {
    super.initState();
    selectedSubject = widget.initialValue;
  }

  @override
  void didUpdateWidget(SubjectDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update selected subject if initial value changes
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        selectedSubject = widget.initialValue;
      });
    }
    // Reset if class changes
    if (widget.classId != oldWidget.classId) {
      setState(() {
        selectedSubject = null;
      });
      widget.onChanged(null);
    }
  }

  List<Subject> _getFilteredSubjects() {
    if (widget.classId != null && widget.classId!.isNotEmpty) {
      return _subjectController.getSubjectsByClass(widget.classId!);
    }
    return _subjectController.subjects;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final filteredSubjects = _getFilteredSubjects();

      return CustomDropdown<String>(
        labelText: widget.labelText ?? 'Subject',
        hintText: widget.hintText ?? 'Select Subject',
        value: selectedSubject,
        enabled: widget.enabled,
        onChanged: (val) {
          setState(() {
            selectedSubject = val;
          });
          widget.onChanged(val);
        },
        items: filteredSubjects.isEmpty
            ? [
                DropdownMenuItem(
                  value: null,
                  enabled: false,
                  child: Text(
                    widget.classId != null
                        ? 'No subjects for this class'
                        : 'No subjects available',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ]
            : filteredSubjects.map((subject) {
                return DropdownMenuItem(
                  value: subject.id,
                  child: Text('${subject.name} (${subject.code})'),
                );
              }).toList(),
      );
    });
  }
}
