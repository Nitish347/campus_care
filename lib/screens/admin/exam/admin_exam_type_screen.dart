import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/models/exam_type_model.dart';
import 'package:campus_care/controllers/exam_type_controller.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/screens/admin/exam/admin_add_edit_exam_type_screen.dart';

class AdminExamTypeScreen extends StatelessWidget {
  const AdminExamTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ExamTypeController controller = Get.put(ExamTypeController());
    final theme = Theme.of(context);

    return Container(
      color: Colors.transparent,
      child: Column(
        children: [
          // Actions Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 8,
              spacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () =>
                      Get.to(() => const AdminAddEditExamTypeScreen()),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Exam Schedule'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Obx(() => OutlinedButton.icon(
                      onPressed: controller.toggleActiveFilter,
                      icon: Icon(
                        controller.showOnlyActive.value
                            ? Icons.check_circle
                            : Icons.check_circle_outline,
                        size: 18,
                      ),
                      label: Text(
                        controller.showOnlyActive.value
                            ? 'Show All'
                            : 'Active Only',
                      ),
                    )),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: controller.refresh,
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),

          // Exam Type List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final examTypes = controller.examTypeList;

              if (examTypes.isEmpty) {
                return EmptyState(
                  icon: Icons.event_note,
                  title: 'No exam schedules',
                  message: controller.showOnlyActive.value
                      ? 'No active exam schedules found'
                      : 'No exam schedules created yet',
                );
              }

              return ResponsivePadding(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: examTypes.length,
                  itemBuilder: (context, index) {
                    final examType = examTypes[index];
                    final statusColor = _getStatusColor(examType);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      color: theme.colorScheme.surface,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.22),
                          width: 1,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () =>
                            _showExamTypeDetails(context, examType, controller),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header Row
                              Row(
                                children: [
                                  // Status Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          statusColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color:
                                            statusColor.withValues(alpha: 0.28),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      examType.status,
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  // Active/Inactive Badge
                                  if (!examType.isActive)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.grey.withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        'Inactive',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Title
                              Text(
                                examType.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (examType.description != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  examType.description!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 12),

                              // Weightage Row
                              if (examType.weightage != null)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme
                                        .colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.percent,
                                        size: 20,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Weightage: ${examType.weightage}%',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 10),

                              // Action Buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () =>
                                        Get.to(() => AdminAddEditExamTypeScreen(
                                              examType: examType,
                                            )),
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text('Edit'),
                                    style: TextButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () => _showDeleteConfirmation(
                                        context, examType, controller),
                                    icon: const Icon(Icons.delete, size: 18),
                                    label: const Text('Delete'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: theme.colorScheme.error,
                                      visualDensity: VisualDensity.compact,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
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

  Color _getStatusColor(ExamTypeModel examType) {
    return examType.isActive ? Colors.green : Colors.grey;
  }

  void _showExamTypeDetails(BuildContext context, ExamTypeModel examType,
      ExamTypeController controller) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(examType);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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

            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    examType.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    examType.status,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            if (examType.description != null) ...[
              const SizedBox(height: 12),
              Text(
                examType.description!,
                style: theme.textTheme.bodyMedium,
              ),
            ],

            const SizedBox(height: 24),

            // Details
            if (examType.weightage != null)
              Row(
                children: [
                  Icon(Icons.percent,
                      size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Weightage: ${examType.weightage}%',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(examType.isActive ? Icons.check_circle : Icons.cancel,
                    size: 20,
                    color: examType.isActive ? Colors.green : Colors.grey),
                const SizedBox(width: 8),
                Text(
                  examType.isActive ? 'Active' : 'Inactive',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Get.to(() => AdminAddEditExamTypeScreen(
                            examType: examType,
                          ));
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
                      _showDeleteConfirmation(context, examType, controller);
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

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ExamTypeModel examType,
      ExamTypeController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exam Schedule'),
        content: Text(
            'Are you sure you want to delete "${examType.name}"? This will also delete all exams associated with this schedule.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await controller.deleteExamType(examType.id);
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
