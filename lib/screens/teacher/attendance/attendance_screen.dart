import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/widgets/inputs/custom_dropdown.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:campus_care/widgets/common/info_card.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String? selectedClass = 'class_001';
  String? selectedSection = 'A';
  DateTime selectedDate = DateTime.now();
  final Map<String, String> _attendanceStatus = {};

  // Static UI data
  static final _students = List.generate(25, (index) {
    return {
      'id': 'student_${index + 1}',
      'name': 'Student ${index + 1}',
      'studentId': 'STU2024${(index + 1).toString().padLeft(3, '0')}',
    };
  });

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _takeAttendance() async {
    if (selectedClass == null || selectedSection == null) {
      Get.snackbar('Error', 'Please select class and section');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Attendance'),
        content: Text('Mark attendance for ${_students.length} students?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.snackbar('Success', 'Attendance saved successfully');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _takeAttendance,
            tooltip: 'Save Attendance',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          ResponsivePadding(
            child: InfoCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomDropdown<String>(
                          value: selectedClass,
                          labelText: 'Class',
                          items: ['class_001', 'class_002', 'class_003']
                              .map((cls) => DropdownMenuItem(
                                    value: cls,
                                    child: Text(cls.replaceAll('_', ' ').toUpperCase()),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedClass = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomDropdown<String>(
                          value: selectedSection,
                          labelText: 'Section',
                          items: ['A', 'B', 'C']
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    readOnly: true,
                    labelText: 'Date',
                    hintText: DateFormat('EEEE, MMMM dd, yyyy').format(selectedDate),
                    prefixIcon: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context),
                  ),
                ],
              ),
            ),
          ),

          // Statistics
          ResponsivePadding(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatChip(
                  context,
                  'Present',
                  _attendanceStatus.values.where((s) => s == 'present').length,
                  Colors.green,
                ),
                _buildStatChip(
                  context,
                  'Absent',
                  _attendanceStatus.values.where((s) => s == 'absent').length,
                  Colors.red,
                ),
                _buildStatChip(
                  context,
                  'Total',
                  _students.length,
                  theme.colorScheme.primary,
                ),
              ],
            ),
          ),

          // Student List
          Expanded(
            child: _students.isEmpty
                ? EmptyState(
                    icon: Icons.people_outline,
                    title: 'No students found',
                    message: 'Please select a class and section',
                  )
                : ResponsivePadding(
                    child: ListView.builder(
                      itemCount: _students.length,
                      itemBuilder: (context, index) {
                        final student = _students[index];
                        final status = _attendanceStatus[student['id']] ?? 'present';

                        return InfoCard(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.primaryContainer,
                              child: Text(
                                (student['name'] as String).substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(student['name'] as String),
                            subtitle: Text('ID: ${student['studentId']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ChoiceChip(
                                  label: const Text('P'),
                                  selected: status == 'present',
                                  onSelected: (selected) {
                                    setState(() {
                                      _attendanceStatus[student['id'] as String] = 'present';
                                    });
                                  },
                                  selectedColor: Colors.green,
                                  labelStyle: TextStyle(
                                    color: status == 'present' ? Colors.white : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ChoiceChip(
                                  label: const Text('A'),
                                  selected: status == 'absent',
                                  onSelected: (selected) {
                                    setState(() {
                                      _attendanceStatus[student['id'] as String] = 'absent';
                                    });
                                  },
                                  selectedColor: Colors.red,
                                  labelStyle: TextStyle(
                                    color: status == 'absent' ? Colors.white : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, String label, int count, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
