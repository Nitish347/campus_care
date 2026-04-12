import 'package:campus_care/widgets/admin/admin_page_header.dart';
import 'package:campus_care/widgets/admin/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/core/constants/app_constants.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/controllers/class_controller.dart';
import 'package:campus_care/screens/admin/academic/add_class_screen.dart';
import 'package:campus_care/models/class.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:campus_care/widgets/buttons/primary_button.dart';

class ClassManagementScreen extends StatelessWidget {
  ClassManagementScreen({super.key});

  final ClassController _controller = Get.put(ClassController());

  void _showAddSectionDialog(BuildContext context, String classId) {
    final sectionController = TextEditingController();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add_circle_outline_rounded,
                    color: Theme.of(context).colorScheme.primary, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                'Add Section',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: sectionController,
                labelText: 'Section Name',
                hintText: 'e.g. C',
                prefixIcon: const Icon(Icons.label_outline_rounded),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  onPressed: () {
                    if (sectionController.text.isNotEmpty) {
                      _controller.addSection(
                          classId, sectionController.text.trim());
                      Get.back();
                    }
                  },
                  prefixIcon: Icons.add_rounded,
                  child: const Text('Add Section',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(
      BuildContext context, String classId, String className) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Class',
      message:
          'Are you sure you want to delete "$className"? This cannot be undone.',
      confirmLabel: 'Delete',
      isDanger: true,
      icon: Icons.delete_forever_rounded,
    );
    if (confirmed) _controller.deleteClass(classId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTeacherView = Get.isRegistered<AuthController>() &&
        Get.find<AuthController>().currentRole == AppConstants.roleTeacher;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Column(
        children: [
          AdminPageHeader(
            title: 'Class Management',
            subtitle: 'Manage classes, grades and sections',
            icon: Icons.class_rounded,
            showBreadcrumb: true,
            breadcrumbLabel: 'Classes',
            showBackButton: true,
            actions: [
              HeaderActionButton(
                icon: Icons.refresh_rounded,
                label: 'Refresh',
                onPressed: _controller.fetchClasses,
              ),
              if (!isTeacherView) ...[
                const SizedBox(width: 8),
                HeaderActionButton(
                  icon: Icons.add_rounded,
                  label: 'Add Class',
                  onPressed: () => Get.toNamed(AppRoutes.addClass),
                ),
              ],
            ],
          ),
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_controller.classes.isEmpty) {
                return EmptyState(
                  icon: Icons.class_outlined,
                  title: 'No classes found',
                  message: 'Start by adding your first class',
                  action: ElevatedButton.icon(
                    onPressed: () => Get.toNamed(AppRoutes.addClass),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Class'),
                  ),
                );
              }
              return ResponsivePadding(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: _controller.classes.length,
                  itemBuilder: (context, index) {
                    final schoolClass = _controller.classes[index];
                    return _ClassCard(
                      schoolClass: schoolClass,
                      theme: theme,
                      onEdit: () => Get.to(
                          () => AddClassScreen(schoolClass: schoolClass)),
                      onDelete: () => _showDeleteDialog(
                        context,
                        schoolClass.id,
                        '${schoolClass.name} - Grade ${schoolClass.grade}',
                      ),
                      onAddSection: () =>
                          _showAddSectionDialog(context, schoolClass.id),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final SchoolClass schoolClass;
  final ThemeData theme;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddSection;

  const _ClassCard({
    required this.schoolClass,
    required this.theme,
    required this.onEdit,
    required this.onDelete,
    required this.onAddSection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.class_rounded, color: Colors.white, size: 20),
          ),
          title: Text(
            '${schoolClass.name} — Grade ${schoolClass.grade}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              '${schoolClass.sections.length} section${schoolClass.sections.length == 1 ? '' : 's'} · Max ${schoolClass.maxStudents} students',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SmallActionButton(
                icon: Icons.edit_rounded,
                color: theme.colorScheme.primary,
                tooltip: 'Edit',
                onPressed: onEdit,
              ),
              const SizedBox(width: 4),
              _SmallActionButton(
                icon: Icons.delete_rounded,
                color: theme.colorScheme.error,
                tooltip: 'Delete',
                onPressed: onDelete,
              ),
              const SizedBox(width: 4),
              const Icon(Icons.expand_more_rounded),
            ],
          ),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                      color: theme.colorScheme.outline.withValues(alpha: 0.15)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sections',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: onAddSection,
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Add Section'),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: schoolClass.sections
                        .map(
                          (section) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C3AED)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF7C3AED)
                                    .withValues(alpha: 0.25),
                              ),
                            ),
                            child: Text(
                              section,
                              style: const TextStyle(
                                color: Color(0xFF7C3AED),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  if (schoolClass.teacherId != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.person_pin_rounded,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          'Teacher ID: ${schoolClass.teacherId}',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  const _SmallActionButton({
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
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}
