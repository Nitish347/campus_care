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

class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({super.key});

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedSubject;
  String? _selectedClass;
  String? _selectedSection;
  DateTime? _dueDate;

  // Static UI data
  static final _subjects = ['Mathematics', 'Science', 'English', 'History', 'Geography', 'Art'];
  static final _homework = [
    {
      'id': 'hw_001',
      'title': 'Math Assignment - Algebra',
      'description': 'Complete exercises 1-20 from chapter 5',
      'subject': 'Mathematics',
      'classId': 'class_001',
      'section': 'A',
      'dueDate': DateTime.now().add(const Duration(days: 3)),
      'status': 'active',
    },
    {
      'id': 'hw_002',
      'title': 'Science Project - Photosynthesis',
      'description': 'Create a presentation on photosynthesis process',
      'subject': 'Science',
      'classId': 'class_001',
      'section': 'A',
      'dueDate': DateTime.now().add(const Duration(days: 7)),
      'status': 'active',
    },
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _assignHomework() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubject == null || _selectedClass == null || _selectedSection == null || _dueDate == null) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    Get.snackbar('Success', 'Homework assigned successfully');
    
    // Reset form
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedSubject = null;
      _selectedClass = null;
      _selectedSection = null;
      _dueDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Homework Management'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Assign Homework'),
              Tab(text: 'View Homework'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Assign Homework Tab
            SingleChildScrollView(
              child: ResponsivePadding(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SectionHeader(title: 'Assign New Homework'),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _titleController,
                        labelText: 'Homework Title',
                        hintText: 'Enter homework title',
                        prefixIcon: const Icon(Icons.assignment),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter homework title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _descriptionController,
                        labelText: 'Description',
                        hintText: 'Enter description',
                        maxLines: 4,
                        prefixIcon: const Icon(Icons.description),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
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
                        labelText: 'Due Date',
                        hintText: _dueDate == null
                            ? 'Select Due Date'
                            : DateFormat('MMM dd, yyyy').format(_dueDate!),
                        prefixIcon: const Icon(Icons.calendar_today),
                        onTap: () => _selectDueDate(context),
                        validator: (value) {
                          if (_dueDate == null) {
                            return 'Please select due date';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        onPressed: _assignHomework,
                        child: const Text('Assign Homework'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // View Homework Tab
            _homework.isEmpty
                ? EmptyState(
                    icon: Icons.assignment_outlined,
                    title: 'No homework assigned',
                    message: 'Start by assigning homework to your classes',
                  )
                : ResponsivePadding(
                    child: ListView.builder(
                      itemCount: _homework.length,
                      itemBuilder: (context, index) {
                        final hw = _homework[index];
                        final dueDate = hw['dueDate'] as DateTime;
                        final isOverdue = dueDate.isBefore(DateTime.now()) && hw['status'] == 'active';

                        return InfoCard(
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isOverdue
                                    ? Colors.red.withValues(alpha: 0.1)
                                    : theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.assignment,
                                color: isOverdue
                                    ? Colors.red
                                    : theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            title: Text(
                              hw['title'] as String,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(hw['description'] as String),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    Chip(
                                      label: Text(
                                        hw['subject'] as String,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    Chip(
                                      label: Text(
                                        '${hw['classId'] as String} - ${hw['section'] as String}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Due: ${DateFormat('MMM dd, yyyy').format(dueDate)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isOverdue ? Colors.red : null,
                                  ),
                                ),
                              ],
                            ),
                            trailing: isOverdue
                                ? Chip(
                                    label: const Text(
                                      'Overdue',
                                      style: TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                    backgroundColor: Colors.red,
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
