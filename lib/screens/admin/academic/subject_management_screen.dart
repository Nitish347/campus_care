import 'package:campus_care/controllers/class_controller.dart';
import 'package:campus_care/controllers/subject_controller.dart';
import 'package:campus_care/models/subject.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/common/info_card.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'add_edit_subject_screen.dart';

class SubjectManagementScreen extends StatelessWidget {
  SubjectManagementScreen({super.key});

  final SubjectController _controller = Get.put(SubjectController());
  final ClassController _classController = Get.put(ClassController());

  void _showDeleteDialog(
      BuildContext context, String subjectId, String subjectName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text(
            'Are you sure you want to delete $subjectName? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _controller.deleteSubject(subjectId);
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

  String _getClassName(String? classId) {
    if (classId == null) return 'Not assigned';
    try {
      final classData = _classController.classes.firstWhere(
        (c) => c.id == classId,
      );
      return classData.name;
    } catch (e) {
      return 'Unknown Class';
    }
  }

  // Group subjects by class
  Map<String?, List<Subject>> _groupSubjectsByClass() {
    final Map<String?, List<Subject>> grouped = {};
    for (var subject in _controller.subjects) {
      if (!grouped.containsKey(subject.classId)) {
        grouped[subject.classId] = [];
      }
      grouped[subject.classId]!.add(subject);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _classController.fetchClasses(); // Ensure classes are loaded

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subject Management'),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.subjects.isEmpty) {
          return EmptyState(
            icon: Icons.book_outlined,
            title: 'No subjects found',
            message: 'Start by adding a new subject',
          );
        }

        final groupedSubjects = _groupSubjectsByClass();

        return ResponsivePadding(
          child: ListView(
            children: groupedSubjects.entries.map((entry) {
              final classId = entry.key;
              final subjects = entry.value;
              final className = _getClassName(classId);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
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
                    className,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text('${subjects.length} subject(s)'),
                  children: subjects.map((subject) {
                    return InfoCard(
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.book,
                            color: theme.colorScheme.onSecondaryContainer,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          subject.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Code: ${subject.code}'),
                            if (subject.description.isNotEmpty)
                              Text(
                                subject.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
                              ),
                          ],
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
                                  Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              Get.to(
                                  () => AddEditSubjectScreen(subject: subject));
                            } else if (value == 'delete') {
                              _showDeleteDialog(
                                context,
                                subject.id,
                                subject.name,
                              );
                            }
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => AddEditSubjectScreen());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
