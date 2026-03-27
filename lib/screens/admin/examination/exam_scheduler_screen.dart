import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:campus_care/widgets/inputs/custom_dropdown.dart';
import 'package:campus_care/widgets/buttons/primary_button.dart';
import 'package:campus_care/widgets/common/info_card.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/common/section_header.dart';

import 'package:campus_care/widgets/admin/admin_page_header.dart';
class ExamSchedulerScreen extends StatefulWidget {
  const ExamSchedulerScreen({super.key});

  @override
  State<ExamSchedulerScreen> createState() => _ExamSchedulerScreenState();
}

class _ExamSchedulerScreenState extends State<ExamSchedulerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roomController = TextEditingController();
  final _maxMarksController = TextEditingController();
  String? _selectedSubject;
  String? _selectedClass;
  String? _selectedSection;
  DateTime? _examDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // Static UI data
  static final _subjects = ['Mathematics', 'Science', 'English', 'History', 'Geography'];
  static final _exams = [
    {
      'id': 'exam_001',
      'name': 'Mid-Term Examination',
      'subject': 'Mathematics',
      'classId': 'class_001',
      'section': 'A',
      'date': DateTime.now().add(const Duration(days: 15)),
      'startTime': '09:00',
      'endTime': '11:00',
      'room': 'Hall A',
      'maxMarks': 100,
    },
    {
      'id': 'exam_002',
      'name': 'Mid-Term Examination',
      'subject': 'Science',
      'classId': 'class_001',
      'section': 'A',
      'date': DateTime.now().add(const Duration(days: 16)),
      'startTime': '09:00',
      'endTime': '11:00',
      'room': 'Hall A',
      'maxMarks': 100,
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _roomController.dispose();
    _maxMarksController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _examDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _examDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (_startTime ?? const TimeOfDay(hour: 9, minute: 0))
          : (_endTime ?? const TimeOfDay(hour: 11, minute: 0)),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _scheduleExam() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubject == null || _selectedClass == null || _selectedSection == null ||
        _examDate == null || _startTime == null || _endTime == null) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    Get.snackbar('Success', 'Exam scheduled successfully');
    
    _formKey.currentState!.reset();
    setState(() {
      _selectedSubject = null;
      _selectedClass = null;
      _selectedSection = null;
      _examDate = null;
      _startTime = null;
      _endTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AdminPageHeader(
        subtitle: 'Plan examination dates',
        icon: Icons.calendar_today,
        showBreadcrumb: true,
        breadcrumbLabel: 'Exams',
          showBackButton: true,
          title: const Text('Exam Scheduler'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Schedule Exam'),
              Tab(text: 'View Exams'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Schedule Exam Tab
            SingleChildScrollView(
              child: ResponsivePadding(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SectionHeader(title: 'Schedule New Exam'),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _nameController,
                        labelText: 'Exam Name',
                        hintText: 'Enter exam name',
                        prefixIcon: const Icon(Icons.quiz),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter exam name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomDropdown<String>(
                        value: _selectedSubject,
                        labelText: 'Subject',
                        prefixIcon: const Icon(Icons.subject),
                        items: _subjects.map((sub) => DropdownMenuItem(
                          value: sub,
                          child: Text(sub),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSubject = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select subject';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
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
                              validator: (value) {
                                if (value == null) {
                                  return 'Required';
                                }
                                return null;
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
                              validator: (value) {
                                if (value == null) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        readOnly: true,
                        labelText: 'Exam Date',
                        hintText: _examDate == null
                            ? 'Select Exam Date'
                            : DateFormat('MMM dd, yyyy').format(_examDate!),
                        prefixIcon: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context),
                        validator: (value) {
                          if (_examDate == null) {
                            return 'Please select exam date';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              readOnly: true,
                              labelText: 'Start Time',
                              hintText: _startTime == null
                                  ? 'Select Start Time'
                                  : _startTime!.format(context),
                              prefixIcon: const Icon(Icons.access_time),
                              onTap: () => _selectTime(context, true),
                              validator: (value) {
                                if (_startTime == null) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              readOnly: true,
                              labelText: 'End Time',
                              hintText: _endTime == null
                                  ? 'Select End Time'
                                  : _endTime!.format(context),
                              prefixIcon: const Icon(Icons.access_time),
                              onTap: () => _selectTime(context, false),
                              validator: (value) {
                                if (_endTime == null) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _roomController,
                        labelText: 'Room/Hall',
                        hintText: 'Enter room number',
                        prefixIcon: const Icon(Icons.meeting_room),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _maxMarksController,
                        labelText: 'Maximum Marks',
                        hintText: 'Enter max marks',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.grade),
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        onPressed: _scheduleExam,
                        child: const Text('Schedule Exam'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // View Exams Tab
            _exams.isEmpty
                ? EmptyState(
                    icon: Icons.quiz_outlined,
                    title: 'No exams scheduled',
                    message: 'Start by scheduling an exam',
                  )
                : ResponsivePadding(
                    child: ListView.builder(
                      itemCount: _exams.length,
                      itemBuilder: (context, index) {
                        final exam = _exams[index];
                        final examDate = exam['date'] as DateTime;
                        final isUpcoming = examDate.isAfter(DateTime.now());

                        return InfoCard(
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isUpcoming
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.quiz,
                                color: isUpcoming
                                    ? Colors.green
                                    : theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            title: Text(
                              exam['name'] as String,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('Subject: ${exam['subject']}'),
                                Text('${exam['classId']} - ${exam['section']}'),
                                Text('Date: ${DateFormat('MMM dd, yyyy').format(examDate)}'),
                                Text('Time: ${exam['startTime']} - ${exam['endTime']}'),
                                Text('Room: ${exam['room']} | Max Marks: ${exam['maxMarks']}'),
                              ],
                            ),
                            trailing: isUpcoming
                                ? Chip(
                                    label: const Text(
                                      'Upcoming',
                                      style: TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                    backgroundColor: Colors.green,
                                  )
                                : const Icon(Icons.chevron_right),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
