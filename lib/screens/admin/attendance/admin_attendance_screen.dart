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
import 'package:campus_care/widgets/inputs/custom_text_field.dart';

class AdminAttendanceScreen extends GetView<AttendanceController> {
  const AdminAttendanceScreen({super.key});
  static const double _kFilterFieldHeight = 52;
  static const double _kControlChipHeight = 40;

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
                        message:
                            'Select a class, section, and date to view or mark attendance.',
                        // action: PrimaryButton(
                        //   onPressed: () {
                        //     // Focus action if needed
                        //   },
                        //   child: const Text('Select Criteria'),
                        // ),
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

  Widget _buildUnifiedHeader(
      BuildContext context, ThemeData theme, bool isDesktop) {
    final isSmallMobile = MediaQuery.of(context).size.width < 390;

    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: isDesktop ? 14 : 10, vertical: isDesktop ? 12 : 8),
      padding: EdgeInsets.all(isDesktop ? 14 : (isSmallMobile ? 10 : 12)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 3,
                      child: ClassSectionDropDown(
                        onChangedClass: (val) => controller.selectClass(val),
                        onChangedSection: (val) =>
                            controller.selectSection(val),
                        padding: 0,
                        fieldHeight: _kFilterFieldHeight,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: _buildDatePicker(context, theme),
                    ),
                    const SizedBox(width: 10),
                    Obx(
                      () => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 132,
                            child: PrimaryButton(
                              height: _kFilterFieldHeight,
                              onPressed: (controller.selectedClass != null &&
                                      controller.selectedSection != null)
                                  ? controller.loadStudentsAndAttendance
                                  : null,
                              child: controller.isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Load Roster'),
                            ),
                          ),
                          if (controller.isEditMode) ...[
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 112,
                              child: PrimaryButton(
                                height: _kFilterFieldHeight,
                                onPressed: controller.students.isNotEmpty
                                    ? controller.saveAttendance
                                    : null,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.save_rounded,
                                        color: Colors.white, size: 17),
                                    SizedBox(width: 6),
                                    Text('Save',
                                        style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClassSectionDropDown(
                      onChangedClass: (val) => controller.selectClass(val),
                      onChangedSection: (val) => controller.selectSection(val),
                      padding: 0,
                      fieldHeight: _kFilterFieldHeight,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(child: _buildDatePicker(context, theme)),
                        const SizedBox(width: 8),
                        Obx(
                          () => Expanded(
                            flex: controller.isEditMode ? 2 : 1,
                            child: Row(
                              children: [
                                Expanded(
                                  child: PrimaryButton(
                                    height: _kFilterFieldHeight,
                                    onPressed: (controller.selectedClass !=
                                                null &&
                                            controller.selectedSection != null)
                                        ? controller.loadStudentsAndAttendance
                                        : null,
                                    child: controller.isLoading
                                        ? const SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text('Load', maxLines: 1),
                                  ),
                                ),
                                if (controller.isEditMode) ...[
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: PrimaryButton(
                                      height: _kFilterFieldHeight,
                                      onPressed: controller.students.isNotEmpty
                                          ? controller.saveAttendance
                                          : null,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(Icons.save_rounded,
                                              color: Colors.white, size: 16),
                                          SizedBox(width: 4),
                                          Flexible(
                                              child: Text('Save', maxLines: 1)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
          Obx(() {
            if (controller.students.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Divider(
                  color:
                      theme.colorScheme.outlineVariant.withValues(alpha: 0.28),
                  height: 1,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  fieldHeight: _kFilterFieldHeight,
                  hintText: 'Search by name or roll number...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  onChanged: controller.setSearchQuery,
                ),
                const SizedBox(height: 10),
                isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                _buildModeToggle(),
                                _buildViewTypeToggle(),
                                if (controller.isEditMode)
                                  _buildBulkActions(theme),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Wrap(
                            alignment: WrapAlignment.end,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildMiniStat(
                                theme,
                                Icons.people_alt,
                                'Total',
                                '${controller.totalStudents}',
                                Colors.blue,
                              ),
                              _buildMiniStat(
                                theme,
                                Icons.check_circle,
                                'Present',
                                '${controller.presentCount}',
                                Colors.green,
                              ),
                              _buildMiniStat(
                                theme,
                                Icons.cancel,
                                'Absent',
                                '${controller.absentCount}',
                                Colors.red,
                              ),
                            ],
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildModeToggle(compactLabels: true),
                              _buildViewTypeToggle(compactLabels: true),
                            ],
                          ),
                          const SizedBox(height: 10),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final itemWidth = (constraints.maxWidth - 16) / 3;
                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  SizedBox(
                                    width: itemWidth,
                                    child: _buildMiniStat(
                                      theme,
                                      Icons.people_alt,
                                      'Total',
                                      '${controller.totalStudents}',
                                      Colors.blue,
                                    ),
                                  ),
                                  SizedBox(
                                    width: itemWidth,
                                    child: _buildMiniStat(
                                      theme,
                                      Icons.check_circle,
                                      'Present',
                                      '${controller.presentCount}',
                                      Colors.green,
                                    ),
                                  ),
                                  SizedBox(
                                    width: itemWidth,
                                    child: _buildMiniStat(
                                      theme,
                                      Icons.cancel,
                                      'Absent',
                                      '${controller.absentCount}',
                                      Colors.red,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          if (controller.isEditMode) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildBulkActionButton(
                                    theme,
                                    'All Present',
                                    Icons.check_circle_outline,
                                    Colors.green,
                                    controller.markAllPresent,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildBulkActionButton(
                                    theme,
                                    'All Absent',
                                    Icons.cancel_outlined,
                                    Colors.red,
                                    controller.markAllAbsent,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildModeToggle({bool compactLabels = false}) {
    final theme = Get.theme;
    final isEditMode = controller.isEditMode;
    return _buildSwitchPill(
      theme: theme,
      compact: compactLabels,
      icon: isEditMode ? Icons.edit_rounded : Icons.visibility_rounded,
      label: compactLabels ? 'Edit' : 'Edit Mode',
      value: isEditMode,
      activeText: 'On',
      inactiveText: 'Off',
      onChanged: (_) => controller.toggleEditMode(),
      accent: theme.colorScheme.primary,
    );
  }

  Widget _buildViewTypeToggle({bool compactLabels = false}) {
    final theme = Get.theme;
    final isCardView = !controller.isTableView;
    return _buildSwitchPill(
      theme: theme,
      compact: compactLabels,
      icon: isCardView ? Icons.view_agenda_rounded : Icons.table_rows_rounded,
      label: compactLabels ? 'Cards' : 'Card View',
      value: isCardView,
      activeText: 'Card',
      inactiveText: 'Table',
      onChanged: (cardEnabled) {
        if (cardEnabled == controller.isTableView) {
          controller.toggleViewMode();
        }
      },
      accent: theme.colorScheme.tertiary,
    );
  }

  Widget _buildSwitchPill({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required bool value,
    required String activeText,
    required String inactiveText,
    required ValueChanged<bool> onChanged,
    required Color accent,
    bool compact = false,
  }) {
    final textColor = value ? accent : theme.colorScheme.onSurfaceVariant;
    return Container(
      height: _kControlChipHeight,
      padding: EdgeInsets.only(left: compact ? 8 : 10, right: compact ? 4 : 6),
      decoration: BoxDecoration(
        color:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: value
              ? accent.withValues(alpha: 0.45)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 15 : 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value ? activeText : inactiveText,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: textColor.withValues(alpha: 0.85),
            ),
          ),
          Transform.scale(
            scale: compact ? 0.75 : 0.82,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: accent,
              activeTrackColor: accent.withValues(alpha: 0.35),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
      ThemeData theme, IconData icon, String label, String value, Color color) {
    return Container(
      constraints: const BoxConstraints(minWidth: 92),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.18),
            color.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 12, color: color),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Removing _buildFilterCard as it's now part of _buildUnifiedHeader

  Widget _buildDatePicker(BuildContext context, ThemeData theme) {
    return Obx(
      () => InkWell(
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: _kFilterFieldHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_month_rounded,
                color: theme.colorScheme.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   'Attendance Date',
                    //   style: theme.textTheme.labelSmall?.copyWith(
                    //     color: theme.colorScheme.onSurfaceVariant,
                    //     fontWeight: FontWeight.w600,
                    //   ),
                    // ),
                    // const SizedBox(height: 1),
                    Text(
                      DateFormat('MMM dd, yyyy')
                          .format(controller.selectedDate),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_drop_down_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

// Removing _buildSummaryStats as its now in _buildUnifiedHeader

  Widget _buildBulkActions(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildBulkActionButton(
            theme,
            'Mark All Present',
            Icons.check_circle_outline,
            Colors.green,
            controller.markAllPresent),
        const SizedBox(width: 8),
        _buildBulkActionButton(theme, 'Mark All Absent', Icons.cancel_outlined,
            Colors.red, controller.markAllAbsent),
      ],
    );
  }

  Widget _buildBulkActionButton(ThemeData theme, String label, IconData icon,
      Color color, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        minimumSize: const Size(0, _kControlChipHeight),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildMobileList(BuildContext context, ThemeData theme) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      itemCount: controller.filteredStudents.length,
      itemBuilder: (context, index) {
        final student = controller.filteredStudents[index];
        final status = _binaryStatus(
          controller.attendanceMap[student.id] ?? AttendanceStatus.absent,
        );

        return Card(
          elevation: 3,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.55),
                ],
              ),
              borderRadius: BorderRadius.circular(12),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.025),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                Container(
                  width: 4,
                  color: _getStatusColor(status).withValues(alpha: 0.75),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: theme.colorScheme.primaryContainer
                                  .withValues(alpha: 0.6),
                              child: Text(
                                student.fullName.substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${student.rollNumber}',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: theme.colorScheme.primary,
                                      letterSpacing: 0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    student.fullName,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  // const SizedBox(height: 2),
                                  // Text(
                                  //   'ID: ${student.enrollmentNumber}',
                                  //   style: theme.textTheme.bodyMedium?.copyWith(
                                  //     color: theme.colorScheme.onSurfaceVariant,
                                  //     fontSize: 12.2,
                                  //   ),
                                  //   maxLines: 1,
                                  //   overflow: TextOverflow.ellipsis,
                                  // ),
                                ],
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints.tightFor(
                                height: 28,
                                width: 28,
                              ),
                              onPressed: () =>
                                  _showStudentDetails(context, student),
                              icon: const Icon(Icons.visibility_outlined),
                              color: theme.colorScheme.primary,
                              iconSize: 17,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (controller.isEditMode) ...[
                          SizedBox(
                            width: double.infinity,
                            child: _buildPresentAbsentButtons(
                              theme: theme,
                              selectedStatus: status,
                              compact: true,
                              expand: true,
                              onSelected: (newStatus) {
                                controller.toggleStudentAttendance(
                                  student.id,
                                  newStatus,
                                );
                              },
                            ),
                          ),
                        ] else ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color:
                                  _getStatusColor(status).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: _getStatusColor(status),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _getStatusLabel(status),
                                  style: TextStyle(
                                    color: _getStatusColor(status),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable(BuildContext context, ThemeData theme) {
    final viewportWidth = MediaQuery.of(context).size.width;
    final tableWidth = viewportWidth > 800 ? viewportWidth - 24 : 800.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          constraints: BoxConstraints(
            minWidth: tableWidth,
            maxWidth: tableWidth,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Table Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.08),
                        theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.04),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      _TableHeaderCell('Roll No', flex: 1),
                      _TableHeaderCell('Student Details', flex: 3),
                      _TableHeaderCell('Attendance Status', flex: 3),
                      _TableHeaderCell('Actions',
                          flex: 1, align: TextAlign.center),
                    ],
                  ),
                ),
                // Table Rows
                ...controller.filteredStudents.asMap().entries.map((entry) {
                  final index = entry.key;
                  final student = entry.value;
                  final isEven = index % 2 == 0;
                  final status = _binaryStatus(
                    controller.attendanceMap[student.id] ??
                        AttendanceStatus.absent,
                  );

                  return Container(
                    decoration: BoxDecoration(
                      color: isEven
                          ? Colors.transparent
                          : theme.colorScheme.surfaceContainerLowest
                              .withValues(alpha: 0.42),
                      border: Border(
                        top: BorderSide(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        // Roll Number
                        Expanded(
                          flex: 1,
                          child: Text(
                            student.rollNumber.isNotEmpty
                                ? student.rollNumber
                                : '-',
                            style: theme.textTheme.bodySmall?.copyWith(
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
                                radius: 15,
                                backgroundColor: theme
                                    .colorScheme.primaryContainer
                                    .withValues(alpha: 0.5),
                                child: Text(
                                  student.fullName
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student.fullName,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      student.enrollmentNumber,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                                SizedBox(
                                  width: 220,
                                  child: _buildPresentAbsentButtons(
                                    theme: theme,
                                    selectedStatus: status,
                                    compact: true,
                                    onSelected: (newStatus) {
                                      controller.toggleStudentAttendance(
                                        student.id,
                                        newStatus,
                                      );
                                    },
                                  ),
                                ),
                              ] else ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.circle,
                                          size: 8,
                                          color: _getStatusColor(status)),
                                      const SizedBox(width: 6),
                                      Text(
                                        _getStatusLabel(status),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
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
                                onPressed: () =>
                                    _showStudentDetails(context, student),
                                constraints: const BoxConstraints.tightFor(
                                    width: 30, height: 30),
                                icon: const Icon(Icons.visibility_outlined,
                                    size: 18),
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
  AttendanceStatus _binaryStatus(AttendanceStatus status) {
    return status == AttendanceStatus.present
        ? AttendanceStatus.present
        : AttendanceStatus.absent;
  }

  Widget _buildPresentAbsentButtons({
    required ThemeData theme,
    required AttendanceStatus selectedStatus,
    required ValueChanged<AttendanceStatus> onSelected,
    bool compact = false,
    bool expand = false,
  }) {
    final isPresent = selectedStatus == AttendanceStatus.present;
    final buttonHeight = compact ? 45.0 : 45.0;

    Widget buildButton({
      required String label,
      required Color color,
      required bool selected,
      required VoidCallback onTap,
    }) {
      final style = OutlinedButton.styleFrom(
        foregroundColor: selected ? color : theme.colorScheme.onSurfaceVariant,
        backgroundColor: selected
            ? color.withValues(alpha: 0.16)
            : theme.colorScheme.surface,
        side: BorderSide(
          color: selected
              ? color.withValues(alpha: 0.6)
              : theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: Size(0, buttonHeight),
        padding:
            EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: 7),
        visualDensity: const VisualDensity(horizontal: -1, vertical: -2),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );

      final child = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            selected ? Icons.check_circle : Icons.circle_outlined,
            size: compact ? 14 : 15,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 12 : 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );

      if (expand) {
        return Expanded(
          child: OutlinedButton(
            onPressed: onTap,
            style: style,
            child: child,
          ),
        );
      }

      return OutlinedButton(
        onPressed: onTap,
        style: style,
        child: child,
      );
    }

    return Row(
      children: [
        buildButton(
          label: 'Present',
          color: Colors.green,
          selected: isPresent,
          onTap: () => onSelected(AttendanceStatus.present),
        ),
        const SizedBox(width: 6),
        buildButton(
          label: 'Absent',
          color: Colors.red,
          selected: !isPresent,
          onTap: () => onSelected(AttendanceStatus.absent),
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
              DetailRow(
                  icon: Icons.person_rounded,
                  label: 'Full Name',
                  value: student.fullName),
              DetailRow(
                  icon: Icons.badge_rounded,
                  label: 'Student ID',
                  value: student.enrollmentNumber),
              DetailRow(
                  icon: Icons.email_rounded,
                  label: 'Email',
                  value: student.email),
              DetailRow(
                  icon: Icons.phone_rounded,
                  label: 'Phone',
                  value: student.phone ?? '--'),
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
          letterSpacing: 0.35,
          fontSize: 11.5,
        ),
      ),
    );
  }
}
