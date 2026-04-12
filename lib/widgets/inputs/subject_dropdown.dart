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
  final bool returnSubjectId;

  const SubjectDropdown({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.labelText,
    this.hintText,
    this.classId,
    this.required = false,
    this.enabled = true,
    this.returnSubjectId = false,
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

    // Deduplicate by normalized subject name to avoid DropdownButton assertion crash
    final seen = <String>{};
    return all.where((s) => seen.add(s.name.trim().toLowerCase())).toList();
  }

  String? _resolveSafeSelectedValue(List<Subject> subjects) {
    final raw = selectedSubject?.trim();
    if (raw == null || raw.isEmpty) return null;

    // Return as ID mode
    if (widget.returnSubjectId) {
      final byId = subjects.where((s) => s.id == raw).toList();
      if (byId.length == 1) {
        return byId.first.id;
      }

      // Backward compatibility: existing selected value may be subject name
      final byName = subjects.where((s) => s.name == raw).toList();
      if (byName.length == 1) {
        return byName.first.id;
      }

      return null;
    }

    // Default mode: existing selected value is subject name
    final byName = subjects.where((s) => s.name == raw).toList();
    if (byName.length == 1) {
      return byName.first.name;
    }

    // Backward compatibility: existing selected value may be subject ID
    final byId = subjects.where((s) => s.id == raw).toList();
    if (byId.length == 1) {
      return byId.first.name;
    }

    // Invalid/stale selected value
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final filteredSubjects = _getFilteredSubjects();
      final safeValue = _resolveSafeSelectedValue(filteredSubjects);

      if (safeValue != selectedSubject) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              selectedSubject = safeValue;
            });
          }
        });
      }

      return CustomDropdown<String>(
        labelText: widget.labelText ?? 'Subject',
        hintText: widget.hintText ?? 'Select Subject',
        value: safeValue,
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
                // Keep name-mode for exam/homework; ID-mode for timetable flows.
                return DropdownMenuItem(
                  value: widget.returnSubjectId ? subject.id : subject.name,
                  child: Text('${subject.name} (${subject.code})'),
                );
              }).toList(),
      );
    });
  }
}
