import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/controllers/attendance_controller.dart';
import 'package:campus_care/widgets/inputs/class_section_dropdown.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/buttons/primary_button.dart';

class AdminAttendanceScreen extends StatelessWidget {
  const AdminAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AttendanceController controller = Get.put(AttendanceController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadStudentsAndAttendance(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Selection Controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.3),
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Class and Section Selection
                ClassSectionDropDown(
                  onChangedClass: (value) {
                    controller.selectClass(value);
                  },
                  onChangedSection: (value) {
                    controller.selectSection(value);
                  },
                  padding: 0,
                ),
                const SizedBox(height: 16),
                // Date Picker
                Obx(() => InkWell(
                      onTap: () => _selectDate(context, controller),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Attendance Date',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('EEEE, MMMM dd, yyyy')
                                        .format(controller.selectedDate),
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 16),
                // Load Button
                Obx(() => PrimaryButton(
                      onPressed: controller.selectedClass != null &&
                              controller.selectedSection != null
                          ? controller.loadStudentsAndAttendance
                          : null,
                      child: controller.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Load Students'),
                    )),
              ],
            ),
          ),

          // Student List
          Expanded(
            child: Obx(() {
              if (controller.students.isEmpty && !controller.isLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No students loaded',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select class, section, and date\nthen click "Load Students"',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  // Summary Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primaryContainer,
                          theme.colorScheme.secondaryContainer,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('EEEE, MMMM dd, yyyy')
                              .format(controller.selectedDate),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryItem(
                              theme,
                              Icons.people_outline,
                              '${controller.totalStudents}',
                              'Total',
                              theme.colorScheme.primary,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: theme.colorScheme.outline.withOpacity(0.3),
                            ),
                            _buildSummaryItem(
                              theme,
                              Icons.check_circle_outline,
                              '${controller.presentCount}',
                              'Present',
                              Colors.green,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: theme.colorScheme.outline.withOpacity(0.3),
                            ),
                            _buildSummaryItem(
                              theme,
                              Icons.cancel_outlined,
                              '${controller.absentCount}',
                              'Absent',
                              Colors.red,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: theme.colorScheme.outline.withOpacity(0.3),
                            ),
                            _buildSummaryItem(
                              theme,
                              Icons.percent,
                              '${controller.attendancePercentage}%',
                              'Rate',
                              controller.attendancePercentage >= 75
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Bulk Actions
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: controller.markAllPresent,
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Mark All Present'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: controller.markAllAbsent,
                            icon: const Icon(Icons.cancel),
                            label: const Text('Mark All Absent'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Student List
                  Expanded(
                    child: ResponsivePadding(
                      child: ListView.builder(
                        itemCount: controller.students.length,
                        itemBuilder: (context, index) {
                          final student = controller.students[index];
                          final status = controller.attendanceMap[student.id] ??
                              AttendanceStatus.present;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: theme.colorScheme.outlineVariant,
                                  width: 1,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor:
                                      _getStatusColor(status).withOpacity(0.1),
                                  child: Text(
                                    student.rollNumber.isNotEmpty
                                        ? student.rollNumber
                                        : student.fullName.substring(0, 1),
                                    style: TextStyle(
                                      color: _getStatusColor(status),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  student.fullName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  'Roll: ${student.rollNumber} | Enrollment: ${student.enrollmentNumber}',
                                ),
                                trailing: SizedBox(
                                  width: 180,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                        child: DropdownButtonFormField<
                                            AttendanceStatus>(
                                          value: status,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          items: AttendanceStatus.values
                                              .map((s) => DropdownMenuItem(
                                                    value: s,
                                                    child: Text(
                                                      _getStatusLabel(s),
                                                      style: TextStyle(
                                                        color:
                                                            _getStatusColor(s),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ))
                                              .toList(),
                                          onChanged: (newStatus) {
                                            if (newStatus != null) {
                                              controller
                                                  .toggleStudentAttendance(
                                                student.id,
                                                newStatus,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Save Button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: controller.students.isNotEmpty
                            ? controller.saveAttendance
                            : null,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Attendance'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    ThemeData theme,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.excused:
        return Colors.blue;
    }
  }

  String _getStatusLabel(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.excused:
        return 'Excused';
    }
  }

  Future<void> _selectDate(
      BuildContext context, AttendanceController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      controller.selectDate(picked);
    }
  }
}
