import 'package:campus_care/controllers/class_controller.dart';
import 'package:campus_care/controllers/subject_controller.dart';
import 'package:campus_care/models/subject.dart';
import 'package:campus_care/widgets/admin/admin_page_header.dart';
import 'package:campus_care/widgets/admin/confirm_dialog.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'add_edit_subject_screen.dart';

class SubjectManagementScreen extends StatelessWidget {
  SubjectManagementScreen({super.key});

  final SubjectController _controller = Get.put(SubjectController());
  final ClassController _classController = Get.put(ClassController());

  Future<void> _showDeleteDialog(
      BuildContext context, String subjectId, String subjectName) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Subject',
      message:
          'Are you sure you want to delete "$subjectName"? This cannot be undone.',
      confirmLabel: 'Delete',
      isDanger: true,
      icon: Icons.delete_forever_rounded,
    );
    if (confirmed) _controller.deleteSubject(subjectId);
  }

  String _getClassName(String? classId) {
    if (classId == null) return 'Not assigned';
    try {
      return _classController.classes.firstWhere((c) => c.id == classId).name;
    } catch (_) {
      return 'Unknown Class';
    }
  }

  Map<String?, List<Subject>> _groupSubjectsByClass() {
    final Map<String?, List<Subject>> grouped = {};
    for (final s in _controller.subjects) {
      grouped.putIfAbsent(s.classId, () => []).add(s);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _classController.fetchClasses();

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Column(
        children: [
          AdminPageHeader(
            title: 'Subject Management',
            subtitle: 'Manage subjects grouped by class',
            icon: Icons.book_rounded,
            showBreadcrumb: true,
            breadcrumbLabel: 'Subjects',
            actions: [
              HeaderActionButton(
                icon: Icons.add_rounded,
                label: 'Add Subject',
                onPressed: () => Get.to(() => AddEditSubjectScreen()),
              ),
            ],
          ),
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_controller.subjects.isEmpty) {
                return EmptyState(
                  icon: Icons.book_outlined,
                  title: 'No subjects found',
                  message: 'Start by adding your first subject',
                  action: ElevatedButton.icon(
                    onPressed: () => Get.to(() => AddEditSubjectScreen()),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Subject'),
                  ),
                );
              }

              final groupedSubjects = _groupSubjectsByClass();

              return ResponsivePadding(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: groupedSubjects.entries
                      .map(
                        (entry) => _SubjectClassGroup(
                          classId: entry.key,
                          className: _getClassName(entry.key),
                          subjects: entry.value,
                          theme: theme,
                          onEdit: (s) =>
                              Get.to(() => AddEditSubjectScreen(subject: s)),
                          onDelete: (s) =>
                              _showDeleteDialog(context, s.id, s.name),
                        ),
                      )
                      .toList(),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SubjectClassGroup extends StatelessWidget {
  final String? classId;
  final String className;
  final List<Subject> subjects;
  final ThemeData theme;
  final void Function(Subject) onEdit;
  final void Function(Subject) onDelete;

  const _SubjectClassGroup({
    required this.classId,
    required this.className,
    required this.subjects,
    required this.theme,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.class_rounded, color: Colors.white, size: 20),
          ),
          title: Text(
            className,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${subjects.length} subject${subjects.length == 1 ? '' : 's'}',
            style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant),
          ),
          children: subjects
              .map((subject) => _SubjectTile(
                    subject: subject,
                    theme: theme,
                    onEdit: () => onEdit(subject),
                    onDelete: () => onDelete(subject),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _SubjectTile extends StatelessWidget {
  final Subject subject;
  final ThemeData theme;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SubjectTile({
    required this.subject,
    required this.theme,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.08)),
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF059669).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: const Color(0xFF059669).withValues(alpha: 0.25)),
          ),
          child: const Icon(Icons.book_rounded,
              color: Color(0xFF059669), size: 18),
        ),
        title: Text(
          subject.name,
          style:
              theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Code: ${subject.code}',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
            if (subject.description.isNotEmpty)
              Text(
                subject.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionBtn(
              icon: Icons.edit_rounded,
              color: theme.colorScheme.primary,
              onPressed: onEdit,
            ),
            const SizedBox(width: 4),
            _ActionBtn(
              icon: Icons.delete_rounded,
              color: theme.colorScheme.error,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionBtn(
      {required this.icon, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onPressed,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 15, color: color),
      ),
    );
  }
}
