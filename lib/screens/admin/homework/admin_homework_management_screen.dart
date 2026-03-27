import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:campus_care/controllers/homework_controller.dart';
import 'package:campus_care/controllers/class_controller.dart';
import 'package:campus_care/controllers/subject_controller.dart';
import 'package:campus_care/models/homework_model.dart';
import 'package:campus_care/widgets/admin/admin_page_header.dart';
import 'package:campus_care/widgets/buttons/primary_button.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/inputs/class_section_dropdown.dart';
import 'package:campus_care/widgets/inputs/custom_dropdown.dart';
import 'package:campus_care/screens/admin/homework/admin_add_edit_homework_screen.dart';

class AdminHomeworkManagementScreen extends GetView<HomeworkController> {
  const AdminHomeworkManagementScreen({super.key});

  /// Resolves a class ID to its display name (e.g. "Class 10").
  String _getClassName(String classId) {
    try {
      final classController = Get.find<ClassController>();
      final match =
          classController.classes.firstWhereOrNull((c) => c.id == classId);
      return match?.name ?? classId;
    } catch (_) {
      return classId;
    }
  }

  /// Resolves a subject ID to its display name (e.g. "Mathematics").
  String _getSubjectName(String subjectId) {
    try {
      final subjectController = Get.find<SubjectController>();
      final match =
          subjectController.subjects.firstWhereOrNull((s) => s.id == subjectId);
      return match?.name ?? subjectId;
    } catch (_) {
      return subjectId;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<HomeworkController>()) {
      Get.put(HomeworkController());
    }
    // Ensure class/subject controllers are ready for name lookups
    Get.put(ClassController());
    Get.put(SubjectController());

    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktopWidth = size.width > 800;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      floatingActionButton: Obx(() {
        if (!controller.isLoading.value) {
          return FloatingActionButton.extended(
            onPressed: () => _showAddHomeworkDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Homework'),
          );
        }
        return const SizedBox.shrink();
      }),
      body: Column(
        children: [
          // Gradient Page Header
          const AdminPageHeader(
            subtitle: 'Monitor student homework',
            icon: Icons.assignment_turned_in,
            showBreadcrumb: true,
            breadcrumbLabel: 'Homework',
            showBackButton: true,
            title: 'Homework Management',
          ),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildUnifiedHeader(context, theme, isDesktopWidth),
                  Obx(() {
                    if (controller.isLoading.value) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final filteredHomework = controller.getFilteredHomework();

                    if (filteredHomework.isEmpty) {
                      return EmptyState(
                        icon: Icons.assignment_outlined,
                        title: 'No homework',
                        message: controller.selectedSubject.value == 'All'
                            ? 'No homework assignments created yet'
                            : 'No homework found for ${controller.selectedSubject.value}',
                      );
                    }

                    return Column(
                      children: [
                        controller.isTableView
                            ? _buildDesktopTable(context, theme, filteredHomework)
                            : _buildMobileList(context, theme, filteredHomework),
                        const SizedBox(height: 80), // Padding for FAB
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
          // Filters Row
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 3,
                      child: ClassSectionDropDown(
                        onChangedClass: (val) => controller.setClassFilter(val),
                        onChangedSection: (val) => controller.setSectionFilter(val),
                        padding: 0,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Obx(() => CustomDropdown<String>(
                            labelText: 'Subject',
                            value: controller.selectedSubject.value.isEmpty ? 'All' : controller.selectedSubject.value,
                            prefixIcon: const Icon(Icons.book),
                            items: [
                              'All',
                              'Mathematics',
                              'Science',
                              'English',
                              'History',
                              'Computer Science' // Typically populated dynamically, keeping original values
                            ]
                                .map((subject) => DropdownMenuItem(
                                      value: subject,
                                      child: Text(subject),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) controller.setSubjectFilter(value);
                            },
                          )),
                    ),
                    const SizedBox(width: 16),
                    PrimaryButton(
                      height: 52,
                      onPressed: () {
                        controller.clearFilters();
                        controller.fetchHomework();
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text('Clear', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    ClassSectionDropDown(
                      onChangedClass: (val) => controller.setClassFilter(val),
                      onChangedSection: (val) => controller.setSectionFilter(val),
                      padding: 0,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Obx(() => CustomDropdown<String>(
                                labelText: 'Subject',
                                value: controller.selectedSubject.value.isEmpty ? 'All' : controller.selectedSubject.value,
                                prefixIcon: const Icon(Icons.book),
                                items: [
                                  'All',
                                  'Mathematics',
                                  'Science',
                                  'English',
                                  'History',
                                  'Computer Science'
                                ]
                                    .map((subject) => DropdownMenuItem(
                                          value: subject,
                                          child: Text(subject, overflow: TextOverflow.ellipsis),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) controller.setSubjectFilter(value);
                                },
                              )),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: PrimaryButton(
                            height: 52,
                            onPressed: () {
                              controller.clearFilters();
                              controller.fetchHomework();
                            },
                            child: const Text('Clear', maxLines: 1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
          
          // Stats & Toggles
          Obx(() {
            final filteredHomework = controller.getFilteredHomework();
            if (filteredHomework.isEmpty && controller.isLoading.value) return const SizedBox.shrink();

            final activeCount = filteredHomework.where((h) => _getStatus(h.dueDate) == 'Active').length;
            final overdueCount = filteredHomework.where((h) => _getStatus(h.dueDate) == 'Overdue').length;

            return Column(
              children: [
                const SizedBox(height: 16),
                Divider(
                    color: theme.colorScheme.outlineVariant
                        .withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                
                isDesktop
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left side: Table/Card Toggle
                          _buildViewTypeToggle(),
                          // Right side: Mini Stats
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _buildMiniStat(theme, Icons.assignment_outlined, 'Total',
                                    '${filteredHomework.length}', theme.colorScheme.primary),
                                const SizedBox(width: 12),
                                _buildMiniStat(theme, Icons.pending_actions, 'Active',
                                    '$activeCount', Colors.blue),
                                const SizedBox(width: 12),
                                _buildMiniStat(theme, Icons.warning_amber, 'Overdue',
                                    '$overdueCount', Colors.red),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildViewTypeToggle(),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: _buildMiniStat(theme, Icons.assignment_outlined,
                                    'Total', '${filteredHomework.length}', theme.colorScheme.primary),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: _buildMiniStat(theme, Icons.pending_actions,
                                    'Active', '$activeCount', Colors.blue),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: _buildMiniStat(theme, Icons.warning_amber, 'Overdue',
                                    '$overdueCount', Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
              ],
            );
          }),
        ],
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

  Widget _buildMobileList(BuildContext context, ThemeData theme, List<HomeWorkModel> homeworkList) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: homeworkList.length,
      itemBuilder: (context, index) {
        final homework = homeworkList[index];
        final subjectColor = _getSubjectColor(homework.subject);
        final status = _getStatus(homework.dueDate);
        final statusColor = _getStatusColor(status);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showHomeworkDetails(context, homework),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: statusColor, width: 4),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: subjectColor.withValues(alpha: 0.1),
                                  child: Icon(Icons.menu_book_rounded, size: 14, color: subjectColor),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getSubjectName(homework.subject),
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: subjectColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                status,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Title & Desc
                        Text(
                          homework.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          homework.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),

                        // Info Badges (Date & Class)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildInfoBadge(theme, Icons.calendar_month_rounded, DateFormat('MMM dd, yyyy').format(homework.dueDate)),
                              const SizedBox(width: 8),
                              _buildInfoBadge(theme, Icons.class_rounded, '${_getClassName(homework.classId)} - Sec ${homework.section}'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3), height: 1),
                        const SizedBox(height: 10),

                        // Footer Actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.people_alt_rounded, size: 16, color: theme.colorScheme.primary),
                                const SizedBox(width: 6),
                                Text(
                                  '${homework.assignedStudents.length}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (homework.priority.isNotEmpty) ...[
                                  const SizedBox(width: 12),
                                  Icon(Icons.flag_rounded, size: 16, color: _getPriorityColor(homework.priority)),
                                  const SizedBox(width: 4),
                                  Text(
                                    homework.priority.toUpperCase(),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: _getPriorityColor(homework.priority),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            // Action Buttons
                            Row(
                              children: [
                                _buildActionIcon(theme, Icons.edit_rounded, theme.colorScheme.primary, () => _showEditHomeworkDialog(context, homework)),
                                const SizedBox(width: 8),
                                _buildActionIcon(theme, Icons.delete_rounded, theme.colorScheme.error, () => _showDeleteConfirmation(context, homework)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoBadge(ThemeData theme, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(ThemeData theme, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _buildDesktopTable(BuildContext context, ThemeData theme, List<HomeWorkModel> homeworkList) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          constraints: BoxConstraints(
             minWidth: MediaQuery.of(context).size.width > 800 ? MediaQuery.of(context).size.width - 32 : 800,
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
                      _TableHeaderCell('Homework Details', flex: 3),
                      _TableHeaderCell('Subject & Class', flex: 2),
                      _TableHeaderCell('Due Date & Status', flex: 2),
                      _TableHeaderCell('Actions', flex: 1, align: TextAlign.center),
                    ],
                  ),
                ),
                // Table Rows
                ...homeworkList.asMap().entries.map((entry) {
                  final index = entry.key;
                  final homework = entry.value;
                  final isEven = index % 2 == 0;
                  final subjectColor = _getSubjectColor(homework.subject);
                  final status = _getStatus(homework.dueDate);
                  final statusColor = _getStatusColor(status);

                  return InkWell(
                    onTap: () => _showHomeworkDetails(context, homework),
                    child: Container(
                      color: isEven ? Colors.transparent : theme.colorScheme.surfaceContainerLowest.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  homework.title,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    if (homework.priority.isNotEmpty) ...[
                                      Text(
                                        'Priority: ${homework.priority.toUpperCase()}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: _getPriorityColor(homework.priority),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Icon(Icons.people, size: 12, color: theme.colorScheme.onSurfaceVariant),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${homework.assignedStudents.length} Students assigned',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: subjectColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _getSubjectName(homework.subject),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: subjectColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_getClassName(homework.classId)} - Sec ${homework.section}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('MMM dd, yyyy - HH:mm').format(homework.dueDate),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    status,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  iconSize: 20,
                                  color: theme.colorScheme.primary,
                                  onPressed: () => _showEditHomeworkDialog(context, homework),
                                  tooltip: 'Edit Phase',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  iconSize: 20,
                                  color: theme.colorScheme.error,
                                  onPressed: () => _showDeleteConfirmation(context, homework),
                                  tooltip: 'Delete',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  void _showHomeworkDetails(BuildContext context, HomeWorkModel homework) {
    final theme = Theme.of(context);
    final subjectColor = _getSubjectColor(homework.subject);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Text(
                homework.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: subjectColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      homework.subject,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: subjectColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (homework.priority.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(homework.priority).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Priority: ${homework.priority.toUpperCase()}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: _getPriorityColor(homework.priority),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 24),
              Text(
                'Description',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Text(
                  homework.description,
                  style: theme.textTheme.bodyMedium,
                ),
              ),

              const SizedBox(height: 24),
              _buildDetailRow(theme, Icons.calendar_today, 'Due Date', DateFormat('EEEE, MMMM dd, yyyy - HH:mm').format(homework.dueDate)),
              const SizedBox(height: 12),
              _buildDetailRow(theme, Icons.people, 'Assigned To', '${homework.assignedStudents.length} students'),
              const SizedBox(height: 12),
              _buildDetailRow(theme, Icons.class_, 'Class Info', '${_getClassName(homework.classId)} - Section ${homework.section}'),
              
              if (homework.totalMarks != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(theme, Icons.grade, 'Total Marks', '${homework.totalMarks} Marks', color: Colors.purple),
              ],

              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditHomeworkDialog(context, homework);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showDeleteConfirmation(context, homework);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, IconData icon, String label, String value, {Color? color}) {
    final c = color ?? theme.colorScheme.primary;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: c),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getStatus(DateTime dueDate) {
    final now = DateTime.now();
    if (dueDate.isBefore(now)) return 'Overdue';
    if (dueDate.difference(now).inDays <= 2) return 'Due Soon';
    return 'Active';
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high': return Colors.red;
      case 'medium': return Colors.orange;
      default: return Colors.blue;
    }
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics': return Colors.blue;
      case 'science': return Colors.green;
      case 'english': return Colors.purple;
      case 'history': return Colors.brown;
      case 'computer science': return Colors.orange;
      default: return Colors.teal;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'due soon':
        return Colors.blue;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showAddHomeworkDialog(BuildContext context) {
    Get.to(() => const AdminAddEditHomeworkScreen());
  }

  void _showEditHomeworkDialog(BuildContext context, HomeWorkModel homework) {
    Get.to(() => AdminAddEditHomeworkScreen(homework: homework));
  }

  void _showDeleteConfirmation(BuildContext context, HomeWorkModel homework) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Homework'),
        content: Text('Are you sure you want to delete "${homework.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await controller.deleteHomework(homework.id);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
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
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: align,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
