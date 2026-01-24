import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/widgets/common/info_card.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/controllers/attendance_controller.dart';
import 'package:campus_care/controllers/class_controller.dart';
import 'package:campus_care/widgets/inputs/class_section_dropdown.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final AttendanceController _controller = Get.put(AttendanceController());
  final ClassController _classController = Get.put(ClassController());

  @override
  void initState() {
    super.initState();
    _classController.fetchClasses();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _controller.selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _controller.selectDate(picked);
      // Reload students and attendance
      if (_controller.selectedClass != null &&
          _controller.selectedSection != null) {
        await _controller.loadStudentsAndAttendance();
      }
    }
  }

  Future<void> _saveAttendance() async {
    if (_controller.selectedClass == null ||
        _controller.selectedSection == null) {
      Get.snackbar('Error', 'Please select class and section');
      return;
    }

    if (_controller.students.isEmpty) {
      Get.snackbar('Error', 'No students found');
      return;
    }

    await _controller.saveAttendance();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        actions: [
          Obx(() => _controller.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveAttendance,
                  tooltip: 'Save Attendance',
                )),
        ],
      ),
      body: Column(
        children: [
          // Filters
          ResponsivePadding(
            child: InfoCard(
              child: Column(
                children: [
                  ClassSectionDropDown(
                    onChangedClass: (classId) {
                      _controller.selectClass(classId);
                    },
                    onChangedSection: (section) {
                      _controller.selectSection(section);
                      // Load students when both class and section are selected
                      if (_controller.selectedClass != null &&
                          section != null) {
                        _controller.loadStudentsAndAttendance();
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Obx(() => GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: theme.colorScheme.outline),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  color: theme.colorScheme.primary),
                              const SizedBox(width: 12),
                              Text(
                                DateFormat('EEEE, MMMM dd, yyyy')
                                    .format(_controller.selectedDate),
                                style: theme.textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),

          // Statistics
          Obx(() => ResponsivePadding(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatChip(
                      context,
                      'Present',
                      _controller.presentCount,
                      Colors.green,
                    ),
                    _buildStatChip(
                      context,
                      'Absent',
                      _controller.absentCount,
                      Colors.red,
                    ),
                    _buildStatChip(
                      context,
                      'Total',
                      _controller.totalStudents,
                      theme.colorScheme.primary,
                    ),
                  ],
                ),
              )),

          // Student List
          Expanded(
            child: Obx(() {
              if (_controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_controller.students.isEmpty) {
                return const EmptyState(
                  icon: Icons.people_outline,
                  title: 'No students found',
                  message: 'Please select a class and section',
                );
              }

              return ResponsivePadding(
                child: ListView.builder(
                  itemCount: _controller.students.length,
                  itemBuilder: (context, index) {
                    final student = _controller.students[index];
                    final status = _controller.attendanceMap[student.id] ??
                        AttendanceStatus.present;

                    return InfoCard(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Text(
                            student.fullName.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(student.fullName),
                        subtitle: Text(
                            'Roll No: ${student.rollNumber.isNotEmpty ? student.rollNumber : student.id.substring(0, 8)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildAttendanceChip(
                              context,
                              'P',
                              status == AttendanceStatus.present,
                              Colors.green,
                              () => _controller.toggleStudentAttendance(
                                  student.id, AttendanceStatus.present),
                            ),
                            const SizedBox(width: 8),
                            _buildAttendanceChip(
                              context,
                              'A',
                              status == AttendanceStatus.absent,
                              Colors.red,
                              () => _controller.toggleStudentAttendance(
                                  student.id, AttendanceStatus.absent),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
      BuildContext context, String label, int count, Color color) {
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

  Widget _buildAttendanceChip(
    BuildContext context,
    String label,
    bool isSelected,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
