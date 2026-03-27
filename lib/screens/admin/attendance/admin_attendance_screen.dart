import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:campus_care/controllers/attendance_controller.dart';
import 'package:campus_care/models/student/student.dart';
import 'package:campus_care/widgets/admin/admin_page_header.dart';
import 'package:campus_care/widgets/admin/detail_dialog.dart';
import 'package:campus_care/widgets/buttons/primary_button.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/inputs/class_section_dropdown.dart';
import 'package:campus_care/widgets/inputs/custom_dropdown.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';

class AdminAttendanceScreen extends GetView<AttendanceController> {
  const AdminAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AttendanceController>()) {
      Get.put(AttendanceController());
    }

    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktopWidth = size.width > 800;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Column(
        children: [
          // Gradient Page Header
          const AdminPageHeader(
            title: 'Attendance Management',
            subtitle: 'Track and manage daily student attendance',
            icon: Icons.how_to_reg_rounded,
            showBreadcrumb: true,
            breadcrumbLabel: 'Attendance',
            showBackButton: true,
          ),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildUnifiedHeader(context, theme, isDesktopWidth),
                  Obx(() {
                    if (controller.isLoading) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (controller.students.isEmpty) {
                      return EmptyState(
                        icon: Icons.fact_check_outlined,
                        title: 'No Class Selected',
                        message: 'Select a class, section, and date to view or mark attendance.',
                        action: PrimaryButton(
                          onPressed: () {
                            // Focus action if needed
                          },
                          child: const Text('Select Criteria'),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        controller.isTableView
                            ? _buildDesktopTable(context, theme)
                            : _buildMobileList(context, theme),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnifiedHeader(BuildContext context, ThemeData theme, bool isDesktop) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isDesktop ? 16 : 8, vertical: isDesktop ? 16 : 8),
      padding: EdgeInsets.all(isDesktop ? 16 : 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Row: Filters
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 3,
                      child: ClassSectionDropDown(
                        onChangedClass: (val) => controller.selectClass(val),
                        onChangedSection: (val) => controller.selectSection(val),
                        padding: 0,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: _buildDatePicker(context, theme),
                    ),
                    const SizedBox(width: 16),
                    Obx(() => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 150,
                              child: PrimaryButton(
                                height: 52,
                                onPressed: (controller.selectedClass != null &&
                                        controller.selectedSection != null)
                                    ? controller.loadStudentsAndAttendance
                                    : null,
                                child: controller.isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : const Text('Load Roster'),
                              ),
                            ),
                            if (controller.isEditMode) ...[
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 150,
                                child: PrimaryButton(
                                  height: 52,
                                  onPressed: controller.students.isNotEmpty ? controller.saveAttendance : null,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.save_rounded, color: Colors.white, size: 20),
                                      SizedBox(width: 8),
                                      Text('Save', style: TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        )),
                  ],
                )
              : Column(
                  children: [
                    ClassSectionDropDown(
                      onChangedClass: (val) => controller.selectClass(val),
                      onChangedSection: (val) => controller.selectSection(val),
                      padding: 0,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          flex: 1,
                          child: _buildDatePicker(context, theme),
                        ),
                        const SizedBox(width: 8),
                        Obx(() => Expanded(
                              flex: controller.isEditMode ? 2 : 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: PrimaryButton(
                                      height: 52,
                                      onPressed: (controller.selectedClass != null &&
                                              controller.selectedSection != null)
                                          ? controller.loadStudentsAndAttendance
                                          : null,
                                      child: controller.isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2, color: Colors.white),
                                            )
                                          : const Text('Load', maxLines: 1),
                                    ),
                                  ),
                                  if (controller.isEditMode) ...[
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: PrimaryButton(
                                        height: 52,
                                        onPressed: controller.students.isNotEmpty ? controller.saveAttendance : null,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.save_rounded, color: Colors.white, size: 18),
                                            SizedBox(width: 4),
                                            Flexible(child: Text('Save', maxLines: 1)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
          
          // Conditionally show Stats and Toggles if Roster is loaded
          Obx(() {
            if (controller.students.isEmpty) return const SizedBox.shrink();

            return Column(
              children: [
                const SizedBox(height: 16),
                Divider(
                    color: theme.colorScheme.outlineVariant
                        .withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                CustomTextField(
                  hintText: 'Search by name or roll number...',
                  prefixIcon: const Icon(Icons.search),
                  onChanged: controller.setSearchQuery,
                ),
                const SizedBox(height: 16),
                // Stats & Toggles Row
                isDesktop
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left side: View/Edit & Table/Card
                          Row(
                            children: [
                              _buildModeToggle(),
                              const SizedBox(width: 12),
                              _buildViewTypeToggle(),
                            ],
                          ),
                          // Right side: Stats & Bulk Actions
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (controller.isEditMode) ...[
                                  _buildBulkActions(theme),
                                  const SizedBox(width: 16),
                                ],
                                _buildMiniStat(theme, Icons.people_alt, 'Total',
                                    '${controller.totalStudents}', Colors.blue),
                                const SizedBox(width: 12),
                                _buildMiniStat(theme, Icons.check_circle, 'Present',
                                    '${controller.presentCount}', Colors.green),
                                const SizedBox(width: 12),
                                _buildMiniStat(theme, Icons.cancel, 'Absent',
                                    '${controller.absentCount}', Colors.red),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(child: _buildModeToggle()),
                              const SizedBox(width: 8),
                              Expanded(child: _buildViewTypeToggle()),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: _buildMiniStat(theme, Icons.people_alt,
                                    'Total', '${controller.totalStudents}', Colors.blue),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: _buildMiniStat(theme, Icons.check_circle,
                                    'Present', '${controller.presentCount}', Colors.green),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: _buildMiniStat(theme, Icons.cancel, 'Absent',
                                    '${controller.absentCount}', Colors.red),
                              ),
                            ],
                          ),
                          if (controller.isEditMode) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                    child: _buildBulkActionButton(
                                        theme,
                                        'All Present',
                                        Icons.check_circle_outline,
                                        Colors.green,
                                        controller.markAllPresent)),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: _buildBulkActionButton(
                                        theme,
                                        'All Absent',
                                        Icons.cancel_outlined,
                                        Colors.red,
                                        controller.markAllAbsent)),
                              ],
                            )
                          ]
                        ],
                      ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment<bool>(
          value: false,
          icon: Icon(Icons.visibility, size: 18),
          label: Text('View Mode'),
        ),
        ButtonSegment<bool>(
          value: true,
          icon: Icon(Icons.edit, size: 18),
          label: Text('Edit Mode'),
        ),
      ],
      selected: {controller.isEditMode},
      onSelectionChanged: (Set<bool> newSelection) {
        if (newSelection.first != controller.isEditMode) {
          controller.toggleEditMode();
        }
      },
      style: SegmentedButton.styleFrom(
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildViewTypeToggle() {
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment<bool>(
          value: true,
          icon: Icon(Icons.table_chart, size: 18),
          label: Text('Table'),
        ),
        ButtonSegment<bool>(
          value: false,
          icon: Icon(Icons.view_agenda, size: 18),
          label: Text('Cards'),
        ),
      ],
      selected: {controller.isTableView},
      onSelectionChanged: (Set<bool> newSelection) {
        if (newSelection.first != controller.isTableView) {
          controller.toggleViewMode();
        }
      },
      style: SegmentedButton.styleFrom(
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildMiniStat(ThemeData theme, IconData icon, String label,
      String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            '$value $label',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

// Removing _buildFilterCard as it's now part of _buildUnifiedHeader

  Widget _buildDatePicker(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Attendance Date',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        Obx(() => InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: controller.selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: theme.colorScheme.copyWith(
                          primary: theme.colorScheme.primary,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  controller.selectDate(picked);
                }
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_rounded,
                        color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        DateFormat('MMM dd, yyyy').format(controller.selectedDate),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_drop_down,
                        color: theme.colorScheme.onSurfaceVariant),
                  ],
                ),
              ),
            )),
      ],
    );
  }

// Removing _buildSummaryStats as its now in _buildUnifiedHeader

  Widget _buildBulkActions(ThemeData theme) {
    return Row(
      children: [
        _buildBulkActionButton(theme, 'Mark All Present', Icons.check_circle_outline, Colors.green, controller.markAllPresent),
        const SizedBox(width: 8),
        _buildBulkActionButton(theme, 'Mark All Absent', Icons.cancel_outlined, Colors.red, controller.markAllAbsent),
      ],
    );
  }

  Widget _buildBulkActionButton(ThemeData theme, String label, IconData icon, Color color, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildMobileList(BuildContext context, ThemeData theme) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      itemCount: controller.filteredStudents.length,
      itemBuilder: (context, index) {
        final student = controller.filteredStudents[index];
        final status = controller.attendanceMap[student.id] ?? AttendanceStatus.absent;

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                      child: Text(
                        student.fullName.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.fullName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Roll: ${student.rollNumber} • ID: ${student.enrollmentNumber}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 10,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _showStudentDetails(context, student),
                      icon: const Icon(Icons.visibility_outlined),
                      color: theme.colorScheme.primary,
                      iconSize: 18,
                    ),
                  ],
               ),
               const SizedBox(height: 6),
               if (controller.isEditMode) ...[
                  SizedBox(
                    height: 38, // more compact height
                    width: double.infinity,
                    child: CustomDropdown(
                      onChanged: (newStatus) {
                        if (newStatus != null) {
                          controller.toggleStudentAttendance(student.id, newStatus);
                        }
                      },
                      value: status,
                      items: AttendanceStatus.values
                          .map((s) => DropdownMenuItem(
                                value: s,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _getStatusColor(s),
                                      ),
                                    ),
                                    Text(
                                      _getStatusLabel(s),
                                      style: TextStyle(
                                        color: _getStatusColor(s),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ] else ...[
                  // View mode chip
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.circle, size: 8, color: _getStatusColor(status)),
                        const SizedBox(width: 6),
                        Text(
                          _getStatusLabel(status),
                          style: TextStyle(
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          constraints: BoxConstraints(
             minWidth: MediaQuery.of(context).size.width > 800 ? MediaQuery.of(context).size.width - 32 : 800,
             maxWidth: MediaQuery.of(context).size.width > 800 ? MediaQuery.of(context).size.width - 32 : 800,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.08),
                        theme.colorScheme.primaryContainer.withValues(alpha: 0.04),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      _TableHeaderCell('Roll No', flex: 1),
                      _TableHeaderCell('Student Details', flex: 3),
                      _TableHeaderCell('Attendance Status', flex: 3),
                      _TableHeaderCell('Actions', flex: 1, align: TextAlign.center),
                    ],
                  ),
                ),
                // Table Rows
                ...controller.filteredStudents.asMap().entries.map((entry) {
                  final index = entry.key;
                  final student = entry.value;
                  final isEven = index % 2 == 0;
                  final status = controller.attendanceMap[student.id] ?? AttendanceStatus.absent;

                  return Container(
                    color: isEven ? Colors.transparent : theme.colorScheme.surfaceContainerLowest.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        // Roll Number
                        Expanded(
                          flex: 1,
                          child: Text(
                            student.rollNumber.isNotEmpty ? student.rollNumber : '-',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        // Student Profile
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                                child: Text(
                                  student.fullName.substring(0, 1).toUpperCase(),
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student.fullName,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      student.enrollmentNumber,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Attendance Action Segmented Control
                        Expanded(
                          flex: 3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              if (controller.isEditMode) ...[
                                SegmentedButton<AttendanceStatus>(
                                  segments: AttendanceStatus.values
                                      .map((s) => ButtonSegment<AttendanceStatus>(
                                            value: s,
                                            label: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 4),
                                              child: Text(
                                                _getStatusLabel(s),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: status == s ? FontWeight.bold : FontWeight.w500,
                                                  color: status == s ? _getStatusColor(s) : theme.colorScheme.onSurface,
                                                ),
                                              ),
                                            ),
                                            icon: status == s ? Icon(Icons.check, size: 16, color: _getStatusColor(s)) : null,
                                          ))
                                      .toList(),
                                  selected: {status},
                                  onSelectionChanged: (Set<AttendanceStatus> newSelection) {
                                    controller.toggleStudentAttendance(student.id, newSelection.first);
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                                      if (states.contains(WidgetState.selected)) {
                                        return _getStatusColor(status).withValues(alpha: 0.15);
                                      }
                                      return Colors.transparent;
                                    }),
                                  ),
                                  showSelectedIcon: false,
                                ),
                              ] else ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.circle, size: 12, color: _getStatusColor(status)),
                                      const SizedBox(width: 8),
                                      Text(
                                        _getStatusLabel(status),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: _getStatusColor(status),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Actions (View Profile)
                        Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () => _showStudentDetails(context, student),
                                icon: const Icon(Icons.visibility_outlined, size: 20),
                                color: theme.colorScheme.primary,
                                tooltip: 'View Student',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // BuildSaveFooter removed
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

  void _showStudentDetails(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (context) => DetailDialog(
        avatarInitial: student.fullName.substring(0, 1),
        title: student.fullName,
        subtitle: 'ID: ${student.enrollmentNumber}',
        accentColor: const Color(0xFF2563EB),
        sections: [
          DetailSection(
            title: 'Personal Information',
            rows: [
              DetailRow(icon: Icons.person_rounded, label: 'Full Name', value: student.fullName),
              DetailRow(icon: Icons.badge_rounded, label: 'Student ID', value: student.enrollmentNumber),
              DetailRow(icon: Icons.email_rounded, label: 'Email', value: student.email),
              DetailRow(icon: Icons.phone_rounded, label: 'Phone', value: student.phone ?? '—'),
            ],
          ),
        ],
        footerActions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  final TextAlign align;

  const _TableHeaderCell(
    this.label, {
    required this.flex,
    this.align = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      flex: flex,
      child: Text(
        label.toUpperCase(),
        textAlign: align,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
