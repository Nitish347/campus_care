import 'package:campus_care/widgets/admin/admin_page_header.dart';
import 'package:campus_care/widgets/admin/confirm_dialog.dart';
import 'package:campus_care/widgets/admin/detail_dialog.dart';
import 'package:campus_care/widgets/inputs/class_section_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/screens/admin/student_management/add_student_screen.dart';
import 'package:campus_care/controllers/student_controller.dart';
import 'package:campus_care/controllers/class_controller.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/models/student/student.dart';

class StudentListScreen extends GetView<StudentController> {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            actions: [
              HeaderActionButton(
                icon: Icons.refresh_rounded,
                label: 'Refresh',
                onPressed: () {
                  controller.resetSelection();
                  controller.loadStudents();
                },
              ),
              const SizedBox(width: 8),
              HeaderActionButton(
                icon: Icons.person_add_rounded,
                label: 'Add Student',
                onPressed: () => Get.toNamed(AppRoutes.addStudent),
              ),
            ],
          ),

          // Main content
          Expanded(
            child: Obx(() {
              if (controller.isLoading) {
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

    return Column(
      children: [
        // Filter row
        ClassSectionDropDown(
          onChangedClass: (val) => controller.selectClass(val),
          onChangedSection: (val) => controller.selectSection(val),
        ),

        // Search + count bar
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
          child: Row(
            children: [
              Expanded(
                child: CustomTextField(
                  hintText: 'Search students by name, ID, or email...',
                  prefixIcon: Icon(Icons.search_rounded,
                      color: theme.colorScheme.onSurfaceVariant),
                  onChanged: controller.searchStudents,
                ),
              ),
              const SizedBox(width: 12),
              Obx(() => _StudentCountBadge(
                    count: controller.filteredStudents.length,
                  )),
            ],
          ),
        ),

        // List/Table
        Expanded(
          child: Obx(() {
            if (controller.filteredStudents.isEmpty) {
              return EmptyState(
                icon: Icons.people_outline_rounded,
                title: 'No students found',
                message: 'Try adjusting your search or filter criteria',
                action: ElevatedButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.addStudent),
                  icon: const Icon(Icons.person_add_rounded, size: 18),
                  label: const Text('Add Student'),
                ),
              );
            }
            return isDesktop
                ? _buildDesktopTable(context, controller.filteredStudents)
                : _buildMobileList(context, controller.filteredStudents);
          }),
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
          onView: () => _showStudentDetails(context, student),
          onEdit: () => Get.to(() => AddStudentScreen(student: student)),
          onDelete: () => _showDeleteDialog(context, student),
          getClassName: _getClassName,
        );
      },
    );
  }

  Widget _buildDesktopTable(BuildContext context, List<Student> students) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
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
              // Table header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                    _TableHeaderCell('Student', flex: 3),
                    _TableHeaderCell('Student ID', flex: 2),
                    _TableHeaderCell('Email', flex: 3),
                    _TableHeaderCell('Phone', flex: 2),
                    _TableHeaderCell('Class', flex: 2),
                    _TableHeaderCell('Actions', flex: 1, align: TextAlign.center),
                  ],
                ),
              ),
              // Table rows
              ...students.asMap().entries.map((entry) {
                final index = entry.key;
                final student = entry.value;
                final isEven = index % 2 == 0;
                return _DesktopStudentRow(
                  student: student,
                  isEven: isEven,
                  theme: theme,
                  className: _getClassName(student.class_),
                  onView: () => _showStudentDetails(context, student),
                  onEdit: () => Get.to(() => AddStudentScreen(student: student)),
                  onDelete: () => _showDeleteDialog(context, student),
                );
              }),
            ],
          ),
        ),
      ),
    );
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
                  value: student.phone ?? '—'),
            ],
          ),
          DetailSection(
            title: 'Academic Information',
            rows: [
              DetailRow(
                  icon: Icons.class_rounded,
                  label: 'Class',
                  value:
                      '${_getClassName(student.class_)} - ${student.section ?? '—'}'),
            ],
          ),
          DetailSection(
            title: 'Guardian Information',
            rows: [
              DetailRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Guardian Name',
                  value: student.guardian?.name ?? '—'),
              DetailRow(
                  icon: Icons.phone_rounded,
                  label: 'Guardian Phone',
                  value: student.guardian?.phone ?? '—'),
              DetailRow(
                  icon: Icons.email_rounded,
                  label: 'Guardian Email',
                  value: student.guardian?.email ?? '—'),
            ],
          ),
        ],
        footerActions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Close'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Get.to(() => AddStudentScreen(student: student));
            },
            icon: const Icon(Icons.edit_rounded, size: 16),
            label: const Text('Edit Student'),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
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

  const _StudentCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                  // Avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        student.fullName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
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
                              style:
                                  TextStyle(color: theme.colorScheme.error)),
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

  const _TableHeaderCell(this.label,
      {this.flex = 1, this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: align,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.primary,
          letterSpacing: 0.5,
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
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.theme.colorScheme.primary,
                              widget.theme.colorScheme.primary
                                  .withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            widget.student.fullName
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
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
                    widget.student.phone ?? '—',
                    style: widget.theme.textTheme.bodySmall,
                  ),
                ),
                // Class badge
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
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
                  flex: 1,
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
