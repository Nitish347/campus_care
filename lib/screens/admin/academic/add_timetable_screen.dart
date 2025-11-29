import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/controllers/timetable_controller.dart';
import 'package:campus_care/models/timetable_model.dart';
import 'package:campus_care/models/teacher/teacher.dart';
import 'package:campus_care/services/teacher_service.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:campus_care/widgets/inputs/custom_dropdown.dart';
import 'package:campus_care/widgets/buttons/primary_button.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/common/section_header.dart';

class AddTimetableScreen extends StatefulWidget {
  const AddTimetableScreen({super.key});

  @override
  State<AddTimetableScreen> createState() => _AddTimetableScreenState();
}

class _AddTimetableScreenState extends State<AddTimetableScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = Get.put(TimetableController());
  
  String? _selectedClass;
  String? _selectedSection;
  final Map<String, List<TimeTableItem>> _weeklySchedule = {};
  List<Teacher> _teachers = [];
  
  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];
  
  final List<String> _periodTypes = ['class', 'lab', 'break', 'lunch', 'sports'];
  final List<String> _subjects = [
    'Mathematics',
    'Science',
    'English',
    'History',
    'Geography',
    'Physics',
    'Chemistry',
    'Biology',
    'Computer Science',
    'Physical Education',
    'Art',
    'Music'
  ];

  @override
  void initState() {
    super.initState();
    for (var day in _days) {
      _weeklySchedule[day] = [];
    }
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    try {
      final teachers = await TeacherService.getAllTeachers();
      setState(() {
        _teachers = teachers;
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to load teachers');
    }
  }

  void _addPeriod(String day) {
    setState(() {
      _weeklySchedule[day]!.add(TimeTableItem(
        period: 'P${_weeklySchedule[day]!.length + 1}',
        subject: '',
        teacherId: '',
        room: '',
        startTime: '09:00',
        endTime: '10:00',
        type: 'class',
      ));
    });
  }

  void _removePeriod(String day, int index) {
    setState(() {
      _weeklySchedule[day]!.removeAt(index);
      // Renumber periods
      for (int i = 0; i < _weeklySchedule[day]!.length; i++) {
        _weeklySchedule[day]![i] = _weeklySchedule[day]![i].copyWith(
          period: 'P${i + 1}',
        );
      }
    });
  }

  void _updatePeriod(String day, int index, TimeTableItem updatedItem) {
    setState(() {
      _weeklySchedule[day]![index] = updatedItem;
    });
  }

  void _autoFillAllDays() {
    final mondayPeriods = _weeklySchedule['Monday'] ?? [];
    if (mondayPeriods.isEmpty) {
      Get.snackbar('Error', 'Please add periods for Monday first');
      return;
    }

    setState(() {
      for (var day in _days) {
        if (day != 'Monday') {
          _weeklySchedule[day] = mondayPeriods.map((period) {
            return TimeTableItem(
              period: period.period,
              subject: period.subject,
              teacherId: period.teacherId,
              room: period.room,
              startTime: period.startTime,
              endTime: period.endTime,
              type: period.type,
            );
          }).toList();
        }
      }
    });

    Get.snackbar('Success', 'Monday schedule copied to all days');
  }

  Future<void> _saveTimetable() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedClass == null || _selectedSection == null) {
      Get.snackbar('Error', 'Please select class and section');
      return;
    }

    // Check if at least one period is added
    bool hasPeriods = _weeklySchedule.values.any((periods) => periods.isNotEmpty);
    if (!hasPeriods) {
      Get.snackbar('Error', 'Please add at least one period');
      return;
    }

    // Validate all periods have required fields
    for (var day in _days) {
      for (var period in _weeklySchedule[day]!) {
        if (period.subject.isEmpty || period.teacherId.isEmpty) {
          Get.snackbar('Error', 'Please fill all required fields for $day');
          return;
        }
      }
    }

    final timetable = TimeTableModel(
      id: 'tt_${_selectedClass}_${_selectedSection}_${DateTime.now().millisecondsSinceEpoch}',
      classId: _selectedClass!,
      section: _selectedSection!,
      weeklySchedule: Map.from(_weeklySchedule),
    );

    await _controller.saveTimetable(timetable);
    Get.offNamed(AppRoutes.timetable);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Timetable'),
      ),
      body: SingleChildScrollView(
        child: ResponsivePadding(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(title: 'Class & Section'),
                const SizedBox(height: 16),
                Obx(() => CustomDropdown<String>(
                  value: _selectedClass,
                  labelText: 'Class *',
                  hintText: 'Select class',
                  prefixIcon: const Icon(Icons.class_),
                  items: _controller.availableClasses
                      .map((classId) => DropdownMenuItem(
                            value: classId,
                            child: Text(classId),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedClass = value;
                      _selectedSection = null;
                    });
                  },
                  validator: (value) {
                    if (value == null) return 'Please select class';
                    return null;
                  },
                )),
                const SizedBox(height: 16),
                Obx(() => CustomDropdown<String>(
                  value: _selectedSection,
                  labelText: 'Section *',
                  hintText: 'Select section',
                  prefixIcon: const Icon(Icons.group),
                  enabled: _selectedClass != null,
                  items: _controller.availableSections
                      .map((section) => DropdownMenuItem(
                            value: section,
                            child: Text('Section $section'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSection = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) return 'Please select section';
                    return null;
                  },
                )),
                const SizedBox(height: 32),
                SectionHeader(
                  title: 'Weekly Schedule',
                  action: _weeklySchedule['Monday']!.isNotEmpty
                      ? Expanded(
                        child: TextButton.icon(
                            onPressed: _autoFillAllDays,
                            icon: const Icon(Icons.copy_all),
                            label:  Text('Auto Fill'),
                          ),
                      )
                      : null,
                ),
                const SizedBox(height: 8),
                if (_weeklySchedule['Monday']!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Fill Monday schedule first, then use "Copy Monday to All Days" to auto-fill the rest.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                // Monday Schedule (Always visible)
                _buildDaySchedule(theme, 'Monday', isFirst: true),
                const SizedBox(height: 16),
                // Other Days (Collapsible)
                ..._days.where((day) => day != 'Monday').map((day) {
                  return _buildDaySchedule(theme, day, isFirst: false);
                }),
                const SizedBox(height: 24),
                PrimaryButton(
                  onPressed: _saveTimetable,
                  child: const Text('Save Timetable'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDaySchedule(ThemeData theme, String day, {required bool isFirst}) {
    final periods = _weeklySchedule[day] ?? [];
    
    if (isFirst) {
      // Monday - Always expanded
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    day,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${periods.length} periods',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (periods.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No periods added',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...periods.asMap().entries.map((entry) {
                  final index = entry.key;
                  final period = entry.value;
                  return _buildPeriodCard(theme, day, index, period);
                }),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _addPeriod(day),
                icon: const Icon(Icons.add),
                label: const Text('Add Period'),
              ),
            ],
          ),
        ),
      );
    } else {
      // Other days - Collapsible
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: ExpansionTile(
          title: Text(
            day,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text('${periods.length} periods'),
          leading: Icon(
            Icons.calendar_today,
            color: theme.colorScheme.primary,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (periods.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No periods added. Use "Copy Monday to All Days" to auto-fill.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ...periods.asMap().entries.map((entry) {
                      final index = entry.key;
                      final period = entry.value;
                      return _buildPeriodCard(theme, day, index, period);
                    }),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _addPeriod(day),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Period'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPeriodCard(
    ThemeData theme,
    String day,
    int index,
    TimeTableItem period,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    period.period,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removePeriod(day, index),
                  tooltip: 'Remove period',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomDropdown<String>(
                    value: period.subject.isEmpty ? null : period.subject,
                    labelText: 'Subject *',
                    items: _subjects
                        .map((subject) => DropdownMenuItem(
                              value: subject,
                              child: Text(subject),
                            ))
                        .toList(),
                    onChanged: (value) {
                      _updatePeriod(
                        day,
                        index,
                        period.copyWith(subject: value ?? ''),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomDropdown<String>(
                    value: period.teacherId.isEmpty ? null : period.teacherId,
                    labelText: 'Teacher *',
                    hintText: 'Select teacher',
                    prefixIcon: const Icon(Icons.person),
                    items: _teachers
                        .map((teacher) => DropdownMenuItem(
                              value: teacher.id,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    teacher.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    teacher.teacherId,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      _updatePeriod(
                        day,
                        index,
                        period.copyWith(teacherId: value ?? ''),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTimePicker(
                    theme,
                    labelText: 'Start Time *',
                    initialTime: _parseTime(period.startTime),
                    onTimeSelected: (time) {
                      final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                      _updatePeriod(
                        day,
                        index,
                        period.copyWith(startTime: timeString),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimePicker(
                    theme,
                    labelText: 'End Time *',
                    initialTime: _parseTime(period.endTime),
                    onTimeSelected: (time) {
                      final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                      _updatePeriod(
                        day,
                        index,
                        period.copyWith(endTime: timeString),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    theme,
                    labelText: 'Room',
                    hintText: 'Optional',
                    value: period.room ?? '',
                    prefixIcon: const Icon(Icons.room),
                    onChanged: (value) {
                      _updatePeriod(
                        day,
                        index,
                        period.copyWith(room: value),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomDropdown<String>(
                    value: period.type,
                    labelText: 'Type',
                    items: _periodTypes
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.toUpperCase()),
                            ))
                        .toList(),
                    onChanged: (value) {
                      _updatePeriod(
                        day,
                        index,
                        period.copyWith(type: value ?? 'class'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    ThemeData theme, {
    required String labelText,
    String? hintText,
    String value = '',
    Widget? prefixIcon,
    required void Function(String) onChanged,
  }) {
    final controller = TextEditingController(text: value);
    return CustomTextField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      onChanged: onChanged,
    );
  }

  TimeOfDay _parseTime(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      // If parsing fails, return default time
    }
    return const TimeOfDay(hour: 9, minute: 0);
  }

  Widget _buildTimePicker(
    ThemeData theme, {
    required String labelText,
    required TimeOfDay initialTime,
    required void Function(TimeOfDay) onTimeSelected,
  }) {
    final timeString = '${initialTime.hour.toString().padLeft(2, '0')}:${initialTime.minute.toString().padLeft(2, '0')}';
    final controller = TextEditingController(text: timeString);
    
    return CustomTextField(
      controller: controller,
      labelText: labelText,
      hintText: 'HH:MM',
      prefixIcon: const Icon(Icons.access_time),
      readOnly: true,
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: initialTime,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: theme.colorScheme.primary,
                  onPrimary: theme.colorScheme.onPrimary,
                  surface: theme.colorScheme.surface,
                  onSurface: theme.colorScheme.onSurface,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          final timeString = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
          controller.text = timeString;
          onTimeSelected(picked);
        }
      },
    );
  }
}
