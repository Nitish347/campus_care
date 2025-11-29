import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/widgets/inputs/custom_dropdown.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:campus_care/widgets/common/info_card.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';

class MarksEntryScreen extends StatefulWidget {
  const MarksEntryScreen({super.key});

  @override
  State<MarksEntryScreen> createState() => _MarksEntryScreenState();
}

class _MarksEntryScreenState extends State<MarksEntryScreen> {
  String? _selectedClass = 'class_001';
  String? _selectedSection = 'A';
  String? _selectedSubject;
  String? _selectedExamType;
  final Map<String, TextEditingController> _marksControllers = {};

  // Static UI data
  static final _students = List.generate(25, (index) {
    return {
      'id': 'student_${index + 1}',
      'name': 'Student ${index + 1}',
      'studentId': 'STU2024${(index + 1).toString().padLeft(3, '0')}',
    };
  });

  static final _subjects = ['Mathematics', 'Science', 'English', 'History', 'Geography'];

  @override
  void dispose() {
    for (var controller in _marksControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveMarks() async {
    if (_selectedClass == null || _selectedSection == null || _selectedSubject == null || _selectedExamType == null) {
      Get.snackbar('Error', 'Please select all fields');
      return;
    }

    Get.snackbar('Success', 'Marks saved successfully');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Marks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveMarks,
            tooltip: 'Save Marks',
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
                          value: _selectedClass,
                          labelText: 'Class',
                          items: ['class_001', 'class_002', 'class_003']
                              .map((cls) => DropdownMenuItem(
                                    value: cls,
                                    child: Text(cls.replaceAll('_', ' ').toUpperCase()),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedClass = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomDropdown<String>(
                          value: _selectedSection,
                          labelText: 'Section',
                          items: ['A', 'B', 'C']
                              .map((sec) => DropdownMenuItem(
                                    value: sec,
                                    child: Text(sec),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSection = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomDropdown<String>(
                          value: _selectedSubject,
                          labelText: 'Subject',
                          items: _subjects.map((sub) => DropdownMenuItem(
                            value: sub,
                            child: Text(sub),
                          )).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSubject = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomDropdown<String>(
                          value: _selectedExamType,
                          labelText: 'Exam Type',
                          items: ['Mid-Term', 'Final', 'Quiz', 'Assignment']
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedExamType = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Student List with Marks Input
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
                        if (!_marksControllers.containsKey(student['id'])) {
                          _marksControllers[student['id'] as String] = TextEditingController();
                        }

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
                            trailing: SizedBox(
                              width: 120,
                              child: CustomTextField(
                                controller: _marksControllers[student['id'] as String],
                                labelText: 'Marks',
                                hintText: '0-100',
                                keyboardType: TextInputType.number,
                              ),
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
}
