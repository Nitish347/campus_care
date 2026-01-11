import 'package:campus_care/widgets/common/info_card.dart';
import 'package:campus_care/widgets/inputs/custom_dropdown.dart';
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
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;

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
          // Compact Selection Controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                // Class, Section, and Date in a more compact layout
                if (isWideScreen)
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ClassSectionDropDown(
                          onChangedClass: (value) =>
                              controller.selectClass(value),
                          onChangedSection: (value) =>
                              controller.selectSection(value),
                          padding: 0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Obx(() => InkWell(
                              onTap: () => _selectDate(context, controller),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: theme.colorScheme.outline),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        color: theme.colorScheme.primary,
                                        size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Date',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: theme
                                                  .colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                          Text(
                                            DateFormat('MMM dd, yyyy').format(
                                                controller.selectedDate),
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ),
                      const SizedBox(width: 12),
                      Obx(() => SizedBox(
                            width: 140,
                            child: PrimaryButton(
                              height: 48,
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
                                  : const Text('Load'),
                            ),
                          )),
                    ],
                  )
                else
                  Column(
                    children: [
                      ClassSectionDropDown(
                        onChangedClass: (value) =>
                            controller.selectClass(value),
                        onChangedSection: (value) =>
                            controller.selectSection(value),
                        padding: 0,
                      ),
                      const SizedBox(height: 12),
                      Obx(() => InkWell(
                            onTap: () => _selectDate(context, controller),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: theme.colorScheme.outline),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      color: theme.colorScheme.primary,
                                      size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Date',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        Text(
                                          DateFormat('MMM dd, yyyy')
                                              .format(controller.selectedDate),
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                      const SizedBox(height: 12),
                      Obx(() => PrimaryButton(
                            height: 44,
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
                  // Compact Summary Header with Bulk Actions
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Compact Summary Stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildCompactSummaryItem(
                              theme,
                              Icons.people_outline,
                              '${controller.totalStudents}',
                              'Total',
                              theme.colorScheme.primary,
                            ),
                            _buildCompactSummaryItem(
                              theme,
                              Icons.check_circle_outline,
                              '${controller.presentCount}',
                              'Present',
                              Colors.green,
                            ),
                            _buildCompactSummaryItem(
                              theme,
                              Icons.cancel_outlined,
                              '${controller.absentCount}',
                              'Absent',
                              Colors.red,
                            ),
                            _buildCompactSummaryItem(
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
                        const SizedBox(height: 12),
                        // Bulk Actions
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: controller.markAllPresent,
                                icon: const Icon(Icons.check_circle, size: 18),
                                label: const Text('All Present'),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: controller.markAllAbsent,
                                icon: const Icon(Icons.cancel, size: 18),
                                label: const Text('All Absent'),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Student List - Now with more space!
                  Expanded(
                    child: ResponsivePadding(
                      child: ListView.builder(
                        itemCount: controller.students.length,
                        padding: const EdgeInsets.only(bottom: 8),
                        itemBuilder: (context, index) {
                          final student = controller.students[index];
                          final status = controller.attendanceMap[student.id] ??
                              AttendanceStatus.absent;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Card(
                              elevation: 0,
                              margin: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: theme.colorScheme.outlineVariant,
                                  width: 1,
                                ),
                              ),
                              child: ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                leading: CircleAvatar(
                                  radius: 20,
                                  backgroundColor:
                                      _getStatusColor(status).withOpacity(0.1),
                                  child: Text(
                                    student.rollNumber.isNotEmpty
                                        ? student.rollNumber
                                        : student.fullName.substring(0, 1),
                                    style: TextStyle(
                                      color: _getStatusColor(status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  student.fullName,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  'Roll: ${student.rollNumber} | ${student.enrollmentNumber}',
                                  style: theme.textTheme.bodySmall,
                                ),
                                trailing: SizedBox(
                                  width: 130,
                                  child: CustomDropdown(
                                    onChanged: (newStatus) {
                                      if (newStatus != null) {
                                        controller.toggleStudentAttendance(
                                          student.id,
                                          newStatus,
                                        );
                                      }
                                    },
                                    value: status,
                                    items: AttendanceStatus.values
                                        .map((s) => DropdownMenuItem(
                                              value: s,
                                              child: Text(
                                                _getStatusLabel(s),
                                                style: TextStyle(
                                                  color: _getStatusColor(s),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Compact Save Button
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border: Border(
                        top: BorderSide(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: controller.students.isNotEmpty
                            ? controller.saveAttendance
                            : null,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Attendance'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildCompactSummaryItem(
    ThemeData theme,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
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
