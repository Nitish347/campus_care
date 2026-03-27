import 'package:campus_care/widgets/admin/admin_page_header.dart';
import 'package:campus_care/widgets/admin/confirm_dialog.dart';
import 'package:campus_care/widgets/admin/detail_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/controllers/teacher_controller.dart';
import 'package:campus_care/screens/admin/teacher_management/add_teacher_screen.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/models/teacher/teacher.dart';
import 'package:intl/intl.dart';

class TeacherListScreen extends GetView<TeacherController> {
  const TeacherListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<TeacherController>()) {
      Get.put(TeacherController());
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: Column(
        children: [
          // Gradient Page Header
          AdminPageHeader(
            title: 'Teacher Management',
            subtitle: 'View, search and manage all teachers',
            icon: Icons.badge_rounded,
            showBreadcrumb: true,
            breadcrumbLabel: 'Teachers',
            showBackButton: true,
            actions: [
              HeaderActionButton(
                icon: Icons.refresh_rounded,
                label: 'Refresh',
                onPressed: () => controller.loadTeachers(),
              ),
              const SizedBox(width: 8),
              HeaderActionButton(
                icon: Icons.person_add_rounded,
                label: 'Add Teacher',
                onPressed: () => Get.toNamed(AppRoutes.addTeacher),
              ),
            ],
          ),

          // Main content
          Expanded(
            child: Obx(() {
              if (controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return _buildTeacherList(context);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherList(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;

    return Column(
      children: [
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
                  hintText: 'Search teachers by name, ID, or email...',
                  prefixIcon: Icon(Icons.search_rounded,
                      color: theme.colorScheme.onSurfaceVariant),
                  onChanged: controller.searchTeachers,
                ),
              ),
              const SizedBox(width: 12),
              Obx(() => _TeacherCountBadge(
                    count: controller.filteredTeachers.length,
                  )),
            ],
          ),
        ),

        // List/Table
        Expanded(
          child: Obx(() {
            if (controller.filteredTeachers.isEmpty) {
              return EmptyState(
                icon: Icons.badge_outlined,
                title: 'No teachers found',
                message: 'Try adjusting your search criteria',
                action: ElevatedButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.addTeacher),
                  icon: const Icon(Icons.person_add_rounded, size: 18),
                  label: const Text('Add Teacher'),
                ),
              );
            }
            return isDesktop
                ? _buildDesktopTable(context, controller.filteredTeachers)
                : _buildMobileList(context, controller.filteredTeachers);
          }),
        ),
      ],
    );
  }

  Widget _buildMobileList(BuildContext context, List<Teacher> teachers) {
    final theme = Theme.of(context);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: teachers.length,
      itemBuilder: (context, index) {
        final teacher = teachers[index];
        return _TeacherMobileCard(
          teacher: teacher,
          theme: theme,
          onView: () => _showTeacherDetails(context, teacher),
          onEdit: () => Get.to(() => AddTeacherScreen(teacher: teacher)),
          onDelete: () => _showDeleteDialog(context, teacher),
        );
      },
    );
  }

  Widget _buildDesktopTable(BuildContext context, List<Teacher> teachers) {
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
                    _TableHeaderCell('Teacher', flex: 3),
                    _TableHeaderCell('Teacher ID', flex: 2),
                    _TableHeaderCell('Email', flex: 3),
                    _TableHeaderCell('Phone', flex: 2),
                    _TableHeaderCell('Department', flex: 2),
                    _TableHeaderCell('Actions', flex: 1, align: TextAlign.center),
                  ],
                ),
              ),
              // Table rows
              ...teachers.asMap().entries.map((entry) {
                final index = entry.key;
                final teacher = entry.value;
                final isEven = index % 2 == 0;
                return _DesktopTeacherRow(
                  teacher: teacher,
                  isEven: isEven,
                  theme: theme,
                  onView: () => _showTeacherDetails(context, teacher),
                  onEdit: () => Get.to(() => AddTeacherScreen(teacher: teacher)),
                  onDelete: () => _showDeleteDialog(context, teacher),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showTeacherDetails(BuildContext context, Teacher teacher) {
    showDialog(
      context: context,
      builder: (context) => DetailDialog(
        avatarInitial: teacher.fullName.substring(0, 1),
        title: teacher.fullName,
        subtitle: 'ID: ${teacher.id}',
        accentColor: const Color(0xFF059669), // Green for teachers
        sections: [
          DetailSection(
            title: 'Personal Information',
            rows: [
              DetailRow(
                  icon: Icons.person_rounded,
                  label: 'Full Name',
                  value: teacher.fullName),
              DetailRow(
                  icon: Icons.badge_rounded,
                  label: 'Teacher ID',
                  value: teacher.id),
              DetailRow(
                  icon: Icons.email_rounded,
                  label: 'Email',
                  value: teacher.email),
              DetailRow(
                  icon: Icons.phone_rounded,
                  label: 'Phone',
                  value: teacher.phone ?? 'Not provided'),
              if (teacher.address != null && teacher.address!.isNotEmpty)
                DetailRow(
                    icon: Icons.location_on_rounded,
                    label: 'Address',
                    value: teacher.address!),
            ],
          ),
          DetailSection(
            title: 'Professional Information',
            rows: [
              DetailRow(
                  icon: Icons.business_rounded,
                  label: 'Department',
                  value: teacher.department ?? 'N/A'),
              if (teacher.hireDate != null)
                DetailRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Hire Date',
                  value: DateFormat('MMM dd, yyyy').format(teacher.hireDate!),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Teacher teacher) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Teacher',
      message:
          'Are you sure you want to delete "${teacher.fullName}"? This action cannot be undone.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      isDanger: true,
      icon: Icons.delete_forever_rounded,
    );
    if (confirmed) {
      controller.deleteTeacher(teacher.id);
    }
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _TeacherCountBadge extends StatelessWidget {
  final int count;

  const _TeacherCountBadge({required this.count});

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
          Icon(Icons.badge_rounded,
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
            count == 1 ? 'teacher' : 'teachers',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherMobileCard extends StatelessWidget {
  final Teacher teacher;
  final ThemeData theme;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TeacherMobileCard({
    required this.teacher,
    required this.theme,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
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
                        teacher.fullName.substring(0, 1).toUpperCase(),
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
                          teacher.fullName,
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
                              teacher.id,
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
                          value: teacher.email,
                          theme: theme)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _InfoChip(
                          icon: Icons.business_rounded,
                          value: teacher.department ?? 'N/A',
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

class _DesktopTeacherRow extends StatefulWidget {
  final Teacher teacher;
  final bool isEven;
  final ThemeData theme;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DesktopTeacherRow({
    required this.teacher,
    required this.isEven,
    required this.theme,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_DesktopTeacherRow> createState() => _DesktopTeacherRowState();
}

class _DesktopTeacherRowState extends State<_DesktopTeacherRow> {
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
                // Teacher name
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
                            widget.teacher.fullName
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
                          widget.teacher.fullName,
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
                    widget.teacher.id,
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
                          widget.teacher.email,
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
                    widget.teacher.phone ?? '—',
                    style: widget.theme.textTheme.bodySmall,
                  ),
                ),
                // Department badge
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
                      widget.teacher.department ?? 'N/A',
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
