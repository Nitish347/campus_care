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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            selectedSubject = widget.initialValue;
          });
        }
      });
    }
    // Reset selection if class changes
    if (widget.classId != oldWidget.classId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            selectedSubject = null;
          });
          widget.onChanged(null);
        }
      });
    }
  }

  List<Subject> _getFilteredSubjects() {
    final List<Subject> all =
        widget.classId != null && widget.classId!.isNotEmpty
            ? _subjectController.getSubjectsByClass(widget.classId!)
            : _subjectController.subjects;

    // Deduplicate by subject name to avoid DropdownButton assertion crash
    final seen = <String>{};
    return all.where((s) => seen.add(s.name)).toList();
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
                // Use subject NAME as value (exam stores subject name, not ID)
                return DropdownMenuItem(
                  value: subject.name,
                  child: Text('${subject.name} (${subject.code})'),
                );
              }).toList(),
      );
    });
  }
}
