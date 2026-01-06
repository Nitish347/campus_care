import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/controllers/class_controller.dart';
import 'package:campus_care/screens/admin/academic/add_class_screen.dart';
import 'package:campus_care/models/class.dart';
import 'package:campus_care/widgets/common/info_card.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/buttons/primary_button.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';

class ClassManagementScreen extends StatelessWidget {
  ClassManagementScreen({super.key});

  final ClassController _controller = Get.put(ClassController());

  void _showAddSectionDialog(BuildContext context, String classId) {
    final sectionController = TextEditingController();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add Section',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: sectionController,
                labelText: 'Section Name',
                hintText: 'e.g., C',
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                onPressed: () {
                  if (sectionController.text.isNotEmpty) {
                    _controller.addSection(
                        classId, sectionController.text.trim());
                    Get.back();
                  }
                },
                child: const Text('Add Section'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, String classId, String className) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class'),
        content: Text(
            'Are you sure you want to delete $className? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _controller.deleteClass(classId);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Management'),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.classes.isEmpty) {
          return EmptyState(
            icon: Icons.class_outlined,
            title: 'No classes found',
            message: 'Start by adding a new class',
          );
        }

        return ResponsivePadding(
          child: ListView.builder(
            itemCount: _controller.classes.length,
            itemBuilder: (context, index) {
              final schoolClass = _controller.classes[index];
              return InfoCard(
                child: ExpansionTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.class_,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(
                    '${schoolClass.name} - Grade ${schoolClass.grade}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Sections: ${schoolClass.sections.join(", ")} | Students: ${schoolClass.maxStudents} max',
                  ),
                  trailing: PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        Get.to(() => AddClassScreen(schoolClass: schoolClass));
                      } else if (value == 'delete') {
                        _showDeleteDialog(
                          context,
                          schoolClass.id,
                          '${schoolClass.name} - Grade ${schoolClass.grade}',
                        );
                      }
                    },
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (schoolClass.teacherId != null)
                            Text(
                              'Class Teacher ID: ${schoolClass.teacherId}', // ideally fetch teacher name
                              style: theme.textTheme.bodyLarge,
                            ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Sections:',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => _showAddSectionDialog(
                                    context, schoolClass.id),
                                icon: const Icon(Icons.add),
                                label: const Text('Add Section'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: schoolClass.sections
                                .map((section) => Chip(
                                      label: Text(
                                        section,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(AppRoutes.addClass);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
