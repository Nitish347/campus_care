import 'package:campus_care/widgets/inputs/custom_dropdown.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/controllers/lunch_controller.dart';
import 'package:campus_care/widgets/inputs/class_section_dropdown.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/buttons/primary_button.dart';
import 'package:campus_care/widgets/admin/admin_page_header.dart';

class AdminLunchManagementScreen extends StatelessWidget {
  const AdminLunchManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LunchController controller = Get.put(LunchController());
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      appBar: AdminPageHeader(
        subtitle: 'Manage cafeteria meal plans',
        icon: Icons.restaurant,
        showBreadcrumb: true,
        breadcrumbLabel: 'Lunch',
        showBackButton: true,
        title: const Text('Lunch Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadStudentsAndLunch(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
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
                  if (isDesktop)
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
                          child: Obx(() => _buildDatePicker(context, theme, controller)),
                        ),
                        const SizedBox(width: 12),
                        Obx(() => Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 140,
                                  child: PrimaryButton(
                                    height: 48,
                                    onPressed: controller.selectedClass != null &&
                                            controller.selectedSection != null
                                        ? controller.loadStudentsAndLunch
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
                                ),
                                if (controller.isEditMode && controller.students.isNotEmpty) ...[
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    width: 140,
                                    child: PrimaryButton(
                                      height: 48,
                                      onPressed: controller.saveLunch,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Icon(Icons.save_rounded, color: Colors.white, size: 20),
                                          SizedBox(width: 8),
                                          Text('Save'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
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
                        Obx(() => _buildDatePicker(context, theme, controller)),
                        const SizedBox(height: 12),
                        Obx(() => Row(
                              children: [
                                Expanded(
                                  child: PrimaryButton(
                                    height: 44,
                                    onPressed: controller.selectedClass != null &&
                                            controller.selectedSection != null
                                        ? controller.loadStudentsAndLunch
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
                                        : const Text('Load', maxLines: 1),
                                  ),
                                ),
                                if (controller.isEditMode && controller.students.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: PrimaryButton(
                                      height: 44,
                                      onPressed: controller.saveLunch,
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
                            )),
                      ],
                    ),
                  
                  // Toggles and Search when Students are Loaded
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
                        // Toggles and Stats Row
                        isDesktop
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      _buildModeToggle(controller),
                                      const SizedBox(width: 12),
                                      _buildViewTypeToggle(controller),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      if (controller.isEditMode) ...[
                                        _buildBulkActions(controller),
                                        const SizedBox(width: 16),
                                      ],
                                      _buildMiniStat(theme, Icons.people_outline, '${controller.totalStudents}', 'Total', theme.colorScheme.primary),
                                      const SizedBox(width: 12),
                                      _buildMiniStat(theme, Icons.restaurant, '${controller.fullMealCount}', 'Full', Colors.green),
                                      const SizedBox(width: 12),
                                      _buildMiniStat(theme, Icons.lunch_dining, '${controller.halfMealCount}', 'Half', Colors.orange),
                                      const SizedBox(width: 12),
                                      _buildMiniStat(theme, Icons.percent, '${controller.lunchPercentage}%', 'Rate', controller.lunchPercentage >= 75 ? Colors.green : Colors.orange),
                                    ],
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: _buildModeToggle(controller)),
                                      const SizedBox(width: 8),
                                      Expanded(child: _buildViewTypeToggle(controller)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(child: _buildMiniStat(theme, Icons.people_outline, '${controller.totalStudents}', 'Total', theme.colorScheme.primary)),
                                      const SizedBox(width: 4),
                                      Expanded(child: _buildMiniStat(theme, Icons.restaurant, '${controller.fullMealCount}', 'Full', Colors.green)),
                                      const SizedBox(width: 4),
                                      Expanded(child: _buildMiniStat(theme, Icons.lunch_dining, '${controller.halfMealCount}', 'Half', Colors.orange)),
                                      const SizedBox(width: 4),
                                      Expanded(child: _buildMiniStat(theme, Icons.percent, '${controller.lunchPercentage}%', 'Rate', controller.lunchPercentage >= 75 ? Colors.green : Colors.orange)),
                                    ],
                                  ),
                                  if (controller.isEditMode) ...[
                                    const SizedBox(height: 16),
                                    _buildBulkActions(controller),
                                  ]
                                ],
                              ),
                      ],
                    );
                  }),
                ],
              ),
            ),

            // Student List or Table View
            Obx(() {
              if (controller.students.isEmpty && !controller.isLoading) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 64),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
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
                  ),
                );
              }

              if (controller.students.isNotEmpty && controller.filteredStudents.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 64),
                    child: Text(
                      'No students matched your search.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }

              return controller.isTableView && isDesktop
                  ? _buildDesktopTable(context, theme, controller)
                  : _buildMobileCards(context, theme, controller);
            }),
          ],
        ),
      ),
    );
  }

  // Extracted Date Picker
  Widget _buildDatePicker(BuildContext context, ThemeData theme, LunchController controller) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: controller.selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          controller.selectDate(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy').format(controller.selectedDate),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileCards(BuildContext context, ThemeData theme, LunchController controller) {
    return ResponsivePadding(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.filteredStudents.length,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemBuilder: (context, index) {
          final student = controller.filteredStudents[index];
          final status = controller.lunchMap[student.id] ?? LunchStatus.notTaken;

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
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: _getStatusColor(status).withValues(alpha: 0.1),
                  child: Icon(
                    _getStatusIcon(status),
                    color: _getStatusColor(status),
                    size: 20,
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
                  width: 140,
                  child: controller.isEditMode
                      ? CustomDropdown<LunchStatus>(
                          onChanged: (newStatus) {
                            if (newStatus != null) {
                              controller.toggleStudentLunch(student.id, newStatus);
                            }
                          },
                          value: status,
                          items: LunchStatus.values.map((s) => DropdownMenuItem(
                                value: s,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(_getStatusIcon(s), size: 16, color: _getStatusColor(s)),
                                    const SizedBox(width: 4),
                                    Text(
                                      _getStatusLabel(s),
                                      style: TextStyle(
                                        color: _getStatusColor(s),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              )).toList(),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
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
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDesktopTable(BuildContext context, ThemeData theme, LunchController controller) {
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
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.12)),
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
                      _TableHeaderCell('Lunch Status', flex: 3),
                      _TableHeaderCell('Actions', flex: 1, align: TextAlign.center),
                    ],
                  ),
                ),
                // Table Rows
                ...controller.filteredStudents.asMap().entries.map((entry) {
                  final index = entry.key;
                  final student = entry.value;
                  final isEven = index % 2 == 0;
                  final status = controller.lunchMap[student.id] ?? LunchStatus.notTaken;

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
                                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      student.enrollmentNumber,
                                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Lunch Action Segmented Control
                        Expanded(
                          flex: 3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              if (controller.isEditMode) ...[
                                SegmentedButton<LunchStatus>(
                                  segments: LunchStatus.values.map((s) => ButtonSegment<LunchStatus>(
                                    value: s,
                                    icon: Icon(_getStatusIcon(s), size: 16),
                                    label: Text(_getStatusLabel(s), style: const TextStyle(fontSize: 12)),
                                  )).toList(),
                                  selected: {status},
                                  onSelectionChanged: (Set<LunchStatus> newSelection) {
                                    controller.toggleStudentLunch(student.id, newSelection.first);
                                  },
                                  style: SegmentedButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                ),
                              ] else ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(_getStatusIcon(status), size: 16, color: _getStatusColor(status)),
                                      const SizedBox(width: 6),
                                      Text(
                                        _getStatusLabel(status),
                                        style: TextStyle(
                                          color: _getStatusColor(status),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Action placeholder
                        Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.history, size: 20),
                                onPressed: () {
                                  // Implementation for history view if needed
                                },
                                tooltip: 'View History',
                                style: IconButton.styleFrom(
                                  foregroundColor: theme.colorScheme.primary,
                                ),
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

  Widget _buildModeToggle(LunchController controller) {
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

  Widget _buildViewTypeToggle(LunchController controller) {
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

  Widget _buildMiniStat(ThemeData theme, IconData icon, String value, String label, Color color) {
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

  Widget _buildBulkActions(LunchController controller) {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: controller.markAllFullMeal,
          icon: const Icon(Icons.restaurant, size: 18, color: Colors.green),
          label: const Text('All Full', style: TextStyle(color: Colors.green)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.green),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: controller.markAllNotTaken,
          icon: const Icon(Icons.block, size: 18, color: Colors.red),
          label: const Text('None', style: TextStyle(color: Colors.red)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(LunchStatus status) {
    switch (status) {
      case LunchStatus.fullMeal:
        return Colors.green;
      case LunchStatus.halfMeal:
        return Colors.orange;
      case LunchStatus.notTaken:
        return Colors.grey;
      case LunchStatus.absent:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(LunchStatus status) {
    switch (status) {
      case LunchStatus.fullMeal:
        return Icons.restaurant;
      case LunchStatus.halfMeal:
        return Icons.lunch_dining;
      case LunchStatus.notTaken:
        return Icons.no_meals;
      case LunchStatus.absent:
        return Icons.person_off;
    }
  }

  String _getStatusLabel(LunchStatus status) {
    switch (status) {
      case LunchStatus.fullMeal:
        return 'Full';
      case LunchStatus.halfMeal:
        return 'Half';
      case LunchStatus.notTaken:
        return 'None';
      case LunchStatus.absent:
        return 'Absent';
    }
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String title;
  final int flex;
  final TextAlign? align;

  const _TableHeaderCell(this.title, {required this.flex, this.align});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      flex: flex,
      child: Text(
        title,
        textAlign: align ?? TextAlign.left,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
