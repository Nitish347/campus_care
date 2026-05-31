import 'package:campus_care/widgets/admin/admin_page_header.dart';
import 'package:campus_care/widgets/admin/confirm_dialog.dart';
import 'package:campus_care/widgets/inputs/class_section_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/core/constants/app_constants.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/screens/admin/student_management/add_student_screen.dart';
import 'package:campus_care/controllers/student_controller.dart';
import 'package:campus_care/controllers/class_controller.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/models/student/student.dart';
import 'package:campus_care/widgets/common/file_display_widget.dart';

class StudentListScreen extends GetView<StudentController> {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isTeacherView = Get.isRegistered<AuthController>() &&
        Get.find<AuthController>().currentRole == AppConstants.roleTeacher;

    if (!Get.isRegistered<StudentController>()) {
      Get.put(StudentController());
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: Column(
        children: [
          // Gradient Page Header
          AdminPageHeader(
            title: 'Student Management',
            subtitle: 'View, search and manage all students',
            icon: Icons.people_rounded,
            showBreadcrumb: true,
            breadcrumbLabel: 'Students',
            showBackButton: true,
            showProfileControls: false,
            actions: [
              HeaderActionButton(
                icon: Icons.refresh_rounded,
                label: 'Refresh',
                onPressed: () {
                  controller.resetSelection();
                },
              ),
              if (!isTeacherView) ...[
                const SizedBox(width: 8),
                HeaderActionButton(
                  icon: Icons.person_add_rounded,
                  label: 'Add Student',
                  onPressed: () => Get.toNamed(AppRoutes.addStudent),
                ),
              ],
            ],
          ),

          // Main content
          Expanded(
            child: Obx(() {
              if (controller.isInitialLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return _buildStudentList(context);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;
    const toolbarControlHeight = 56.0;

    return Column(
      children: [
        // Class, section, search and count toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final hasSingleRowSpace = constraints.maxWidth >= 1100;

              final classAndSection = ClassSectionDropDown(
                padding: 0,
                fieldHeight: toolbarControlHeight,
                onChangedClass: (val) => controller.selectClass(val),
                onChangedSection: (val) => controller.selectSection(val),
              );

              final searchBar = CustomTextField(
                fieldHeight: toolbarControlHeight,
                labelText: 'Search',
                hintText: 'Search students by name, ID, or email...',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onChanged: controller.searchStudents,
              );

              final sortControl = _SortControl(
                height: toolbarControlHeight,
                sortBy: controller.sortBy,
                sortOrder: controller.sortOrder,
                onSelected: controller.setSort,
              );

              final countBadge = Obx(
                () => SizedBox(
                  height: toolbarControlHeight,
                  child: _StudentCountBadge(
                    count: controller.totalStudents,
                  ),
                ),
              );

              if (hasSingleRowSpace) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: classAndSection),
                    const SizedBox(width: 12),
                    Expanded(flex: 4, child: searchBar),
                    const SizedBox(width: 12),
                    sortControl,
                    const SizedBox(width: 12),
                    countBadge,
                  ],
                );
              }

              return Column(
                children: [
                  classAndSection,
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: searchBar),
                      const SizedBox(width: 12),
                      sortControl,
                      const SizedBox(width: 12),
                      countBadge,
                    ],
                  ),
                ],
              );
            },
          ),
        ),

        // List/Table
        Expanded(
          child: Column(
            children: [
              Obx(
                () => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: controller.isListLoading
                      ? const Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 2),
                          child: Center(child: _RefreshingResultsBadge()),
                        )
                      : const SizedBox(height: 12),
                ),
              ),
              Expanded(
                child: Obx(() {
                  final students = controller.filteredStudents;
                  final content = students.isEmpty
                      ? EmptyState(
                          icon: Icons.people_outline_rounded,
                          title: 'No students found',
                          message:
                              'Try adjusting your search or filter criteria',
                          action: ElevatedButton.icon(
                            onPressed: () => Get.toNamed(AppRoutes.addStudent),
                            icon:
                                const Icon(Icons.person_add_rounded, size: 18),
                            label: const Text('Add Student'),
                          ),
                        )
                      : isDesktop
                          ? _buildDesktopTable(context, students)
                          : _buildMobileList(context, students);

                  return content;
                }),
              ),
              Obx(
                () => _StudentPaginationBar(
                  currentPage: controller.currentPage,
                  totalPages: controller.totalPages,
                  totalStudents: controller.totalStudents,
                  pageSize: StudentController.studentsPerPage,
                  hasPreviousPage: controller.hasPreviousPage,
                  hasNextPage: controller.hasNextPage,
                  onPrevious: controller.previousPage,
                  onNext: controller.nextPage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileList(BuildContext context, List<Student> students) {
    final theme = Theme.of(context);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return _StudentMobileCard(
          student: student,
          theme: theme,
          onView: () => _openStudentDetails(student),
          onEdit: () => Get.to(() => AddStudentScreen(student: student)),
          onDelete: () => _showDeleteDialog(context, student),
          getClassName: _getClassName,
        );
      },
    );
  }

  Widget _buildDesktopTable(BuildContext context, List<Student> students) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        const tableMinWidth = 1180.0;
        final tableWidth = constraints.maxWidth < tableMinWidth
            ? tableMinWidth
            : constraints.maxWidth;

        return Scrollbar(
          thumbVisibility: constraints.maxWidth < tableMinWidth,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
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
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary
                                    .withValues(alpha: 0.08),
                                theme.colorScheme.primaryContainer
                                    .withValues(alpha: 0.04),
                              ],
                            ),
                          ),
                          child: Row(
                            children: [
                              _TableHeaderCell(
                                'Student',
                                flex: 3,
                                sortKey: 'name',
                                currentSort: controller.sortBy,
                                sortOrder: controller.sortOrder,
                                onSort: controller.setSort,
                              ),
                              _TableHeaderCell(
                                'Student ID',
                                flex: 2,
                                sortKey: 'enrollmentNumber',
                                currentSort: controller.sortBy,
                                sortOrder: controller.sortOrder,
                                onSort: controller.setSort,
                              ),
                              _TableHeaderCell(
                                'Email',
                                flex: 3,
                                sortKey: 'email',
                                currentSort: controller.sortBy,
                                sortOrder: controller.sortOrder,
                                onSort: controller.setSort,
                              ),
                              _TableHeaderCell('Phone', flex: 2),
                              _TableHeaderCell(
                                'Class',
                                flex: 1,
                                sortKey: 'class',
                                currentSort: controller.sortBy,
                                sortOrder: controller.sortOrder,
                                onSort: controller.setSort,
                              ),
                              _TableHeaderCell('Actions',
                                  flex: 2, align: TextAlign.center),
                            ],
                          ),
                        ),
                        ...students.asMap().entries.map((entry) {
                          final index = entry.key;
                          final student = entry.value;
                          final isEven = index % 2 == 0;
                          return _DesktopStudentRow(
                            student: student,
                            isEven: isEven,
                            theme: theme,
                            className: _getClassName(student.class_),
                            onView: () => _openStudentDetails(student),
                            onEdit: () => Get.to(
                                () => AddStudentScreen(student: student)),
                            onDelete: () => _showDeleteDialog(context, student),
                          );
                        }),
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

  void _openStudentDetails(Student student) {
    Get.toNamed(AppRoutes.adminStudentDetails, arguments: student);
  }

  void _showDeleteDialog(BuildContext context, Student student) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Student',
      message:
          'Are you sure you want to delete "${student.fullName}"? This action cannot be undone.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      isDanger: true,
      icon: Icons.delete_forever_rounded,
    );
    if (confirmed) {
      controller.deleteStudent(student.id);
    }
  }

  String _getClassName(String? classId) {
    if (classId == null) return 'N/A';
    try {
      final cls = Get.find<ClassController>()
          .classes
          .firstWhere((c) => c.id == classId);
      return cls.name;
    } catch (_) {
      return 'Unknown';
    }
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _StudentCountBadge extends StatelessWidget {
  final int count;

  const _StudentCountBadge({
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_rounded,
              size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            count == 1 ? 'student' : 'students',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );

    return badge;
  }
}

class _SortControl extends StatelessWidget {
  final double height;
  final String sortBy;
  final String sortOrder;
  final ValueChanged<String> onSelected;

  const _SortControl({
    required this.height,
    required this.sortBy,
    required this.sortOrder,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = switch (sortBy) {
      'enrollmentNumber' => 'Student ID',
      'rollNumber' => 'Roll No',
      'email' => 'Email',
      'class' => 'Class',
      'section' => 'Section',
      'createdAt' => 'Created',
      _ => 'Name',
    };

    return SizedBox(
      height: height,
      child: PopupMenuButton<String>(
        tooltip: 'Sort students',
        onSelected: onSelected,
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'name', child: Text('Name')),
          PopupMenuItem(value: 'enrollmentNumber', child: Text('Student ID')),
          PopupMenuItem(value: 'rollNumber', child: Text('Roll No')),
          PopupMenuItem(value: 'email', child: Text('Email')),
          PopupMenuItem(value: 'class', child: Text('Class')),
          PopupMenuItem(value: 'section', child: Text('Section')),
          PopupMenuItem(value: 'createdAt', child: Text('Created')),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                sortOrder == 'asc'
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentPaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalStudents;
  final int pageSize;
  final bool hasPreviousPage;
  final bool hasNextPage;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _StudentPaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.totalStudents,
    required this.pageSize,
    required this.hasPreviousPage,
    required this.hasNextPage,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final start = totalStudents == 0 ? 0 : ((currentPage - 1) * pageSize) + 1;
    final end = (currentPage * pageSize).clamp(0, totalStudents);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.12),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              totalStudents == 0
                  ? 'No students'
                  : 'Showing $start-$end of $totalStudents students',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            tooltip: 'Previous page',
            onPressed: hasPreviousPage ? onPrevious : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Text(
            'Page $currentPage of $totalPages',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          IconButton(
            tooltip: 'Next page',
            onPressed: hasNextPage ? onNext : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _RefreshingResultsBadge extends StatelessWidget {
  const _RefreshingResultsBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Updating',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentMobileCard extends StatelessWidget {
  final Student student;
  final ThemeData theme;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String Function(String?) getClassName;

  const _StudentMobileCard({
    required this.student,
    required this.theme,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.getClassName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _ProfileAvatar(
                    size: 50,
                    initial:
                        student.fullName.isNotEmpty ? student.fullName[0] : 'S',
                    imageUrl: student.profileImageUrl,
                    theme: theme,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.fullName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(Icons.badge_outlined,
                                size: 13,
                                color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              student.enrollmentNumber,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    onSelected: (v) {
                      if (v == 'view') onView();
                      if (v == 'edit') onEdit();
                      if (v == 'delete') onDelete();
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(children: [
                          Icon(Icons.visibility_rounded, size: 18),
                          SizedBox(width: 10),
                          Text('View Details'),
                        ]),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(children: [
                          Icon(Icons.edit_rounded, size: 18),
                          SizedBox(width: 10),
                          Text('Edit'),
                        ]),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [
                          Icon(Icons.delete_rounded,
                              size: 18, color: theme.colorScheme.error),
                          const SizedBox(width: 10),
                          Text('Delete',
                              style: TextStyle(color: theme.colorScheme.error)),
                        ]),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(
                  height: 1,
                  color: theme.colorScheme.outline.withValues(alpha: 0.12)),
              const SizedBox(height: 12),
              // Info chips
              Row(
                children: [
                  Expanded(
                      child: _InfoChip(
                          icon: Icons.email_outlined,
                          value: student.email,
                          theme: theme)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _InfoChip(
                          icon: Icons.class_outlined,
                          value:
                              '${getClassName(student.class_)} · ${student.section ?? '—'}',
                          theme: theme)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final ThemeData theme;

  const _InfoChip({
    required this.icon,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: theme.colorScheme.primary),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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
  final String? sortKey;
  final String? currentSort;
  final String? sortOrder;
  final ValueChanged<String>? onSort;

  const _TableHeaderCell(
    this.label, {
    this.flex = 1,
    this.align = TextAlign.left,
    this.sortKey,
    this.currentSort,
    this.sortOrder,
    this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSorted = sortKey != null && sortKey == currentSort;
    final child = Row(
      mainAxisSize:
          align == TextAlign.center ? MainAxisSize.min : MainAxisSize.max,
      mainAxisAlignment: align == TextAlign.center
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            label,
            textAlign: align,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        if (sortKey != null) ...[
          const SizedBox(width: 4),
          Icon(
            isSorted
                ? (sortOrder == 'desc'
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded)
                : Icons.unfold_more_rounded,
            size: 14,
            color: isSorted
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ],
    );

    return Expanded(
      flex: flex,
      child: sortKey == null || onSort == null
          ? child
          : InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () => onSort!(sortKey!),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: child,
              ),
            ),
    );
  }
}

class _DesktopStudentRow extends StatefulWidget {
  final Student student;
  final bool isEven;
  final ThemeData theme;
  final String className;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DesktopStudentRow({
    required this.student,
    required this.isEven,
    required this.theme,
    required this.className,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_DesktopStudentRow> createState() => _DesktopStudentRowState();
}

class _DesktopStudentRowState extends State<_DesktopStudentRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: _hovered
            ? widget.theme.colorScheme.primary.withValues(alpha: 0.05)
            : (widget.isEven
                ? widget.theme.colorScheme.surface
                : widget.theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.15)),
        child: InkWell(
          onTap: widget.onView,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                // Student name
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      _ProfileAvatar(
                        size: 36,
                        initial: widget.student.fullName.isNotEmpty
                            ? widget.student.fullName[0]
                            : 'S',
                        imageUrl: widget.student.profileImageUrl,
                        theme: widget.theme,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.student.fullName,
                          style: widget.theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // ID
                Expanded(
                  flex: 2,
                  child: Text(
                    widget.student.enrollmentNumber,
                    style: widget.theme.textTheme.bodySmall?.copyWith(
                      color: widget.theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Email
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Icon(Icons.email_outlined,
                          size: 14,
                          color: widget.theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.student.email,
                          style: widget.theme.textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // Phone
                Expanded(
                  flex: 2,
                  child: Text(
                    widget.student.phone ?? '-',
                    style: widget.theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Class badge
                Expanded(
                  flex: 1,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.className} · ${widget.student.section ?? '—'}',
                      style: widget.theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: widget.theme.colorScheme.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                // Actions
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ActionIconButton(
                        icon: Icons.visibility_rounded,
                        color: widget.theme.colorScheme.primary,
                        tooltip: 'View',
                        onPressed: widget.onView,
                      ),
                      _ActionIconButton(
                        icon: Icons.edit_rounded,
                        color: widget.theme.colorScheme.secondary,
                        tooltip: 'Edit',
                        onPressed: widget.onEdit,
                      ),
                      _ActionIconButton(
                        icon: Icons.delete_rounded,
                        color: widget.theme.colorScheme.error,
                        tooltip: 'Delete',
                        onPressed: widget.onDelete,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final double size;
  final String initial;
  final String? imageUrl;
  final ThemeData theme;

  const _ProfileAvatar({
    required this.size,
    required this.initial,
    this.imageUrl,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileAvatarWidget(
      size: size,
      imageUrl: imageUrl,
      displayName: initial,
      enablePreview: true,
      backgroundGradient: LinearGradient(
        colors: [
          theme.colorScheme.primary,
          theme.colorScheme.primary.withValues(alpha: 0.7),
        ],
      ),
      textStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: size > 45 ? 20 : 14,
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Container(
          width: 30,
          height: 30,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
      ),
    );
  }
}
