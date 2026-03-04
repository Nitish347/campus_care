import 'package:campus_care/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/controllers/notice_controller.dart';
import 'package:campus_care/models/notice_model.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:campus_care/widgets/inputs/custom_dropdown.dart';
import 'package:campus_care/widgets/common/info_card.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';

class NoticeManagementScreen extends GetView<NoticeController> {
  const NoticeManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    if (!Get.isRegistered<NoticeController>()) {
      Get.put(NoticeController());
    }
    final authController = Get.find<AuthController>();

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notice Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadNotices(),
            tooltip: 'Refresh',
          ),
          if (authController.isAdmin())
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddEditDialog(context, null),
              tooltip: 'Add Notice',
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: CustomTextField(
              hintText: 'Search notices by title or description...',
              prefixIcon: const Icon(Icons.search),
              onChanged: controller.searchNotices,
            ),
          ),

          // Notices list
          Expanded(
            child: Obx(() {
              if (controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.notices.isEmpty) {
                return EmptyState(
                  icon: Icons.announcement_outlined,
                  title: 'No notices found',
                  message: controller.searchQuery.isEmpty
                      ? 'Start by publishing a notice'
                      : 'No notices match your search',
                  action: controller.searchQuery.isEmpty
                      ? ElevatedButton.icon(
                          onPressed: () => _showAddEditDialog(context, null),
                          icon: const Icon(Icons.add),
                          label: const Text('Create Notice'),
                        )
                      : null,
                );
              }

              return ResponsivePadding(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: controller.notices.length,
                  itemBuilder: (context, index) {
                    final notice = controller.notices[index];
                    return _buildNoticeCard(
                        context, theme, notice, authController.isAdmin());
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeCard(
      BuildContext context, ThemeData theme, NoticeModel notice, bool isAdmin) {
    Color priorityColor;
    switch (notice.priority) {
      case 'high':
        priorityColor = Colors.red;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.blue;
    }

    return InfoCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showNoticeDetails(context, notice),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 80,
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notice.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notice.description,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: priorityColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            notice.priority.toUpperCase(),
                            style: TextStyle(
                              color: priorityColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('MMM dd, yyyy')
                                  .format(notice.issuedDate),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        if (notice.expiryDate != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 14,
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Expires: ${DateFormat('MMM dd').format(notice.expiryDate!)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isAdmin)
                PopupMenuButton(
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
                      _showAddEditDialog(context, notice);
                    } else if (value == 'delete') {
                      _showDeleteDialog(context, notice);
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNoticeDetails(BuildContext context, NoticeModel notice) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      notice.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                notice.description,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _buildDetailChip(
                      Icons.flag, 'Priority: ${notice.priority.toUpperCase()}'),
                  _buildDetailChip(Icons.calendar_today,
                      'Issued: ${DateFormat('MMM dd, yyyy').format(notice.issuedDate)}'),
                  if (notice.expiryDate != null)
                    _buildDetailChip(Icons.event_busy,
                        'Expires: ${DateFormat('MMM dd, yyyy').format(notice.expiryDate!)}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(text),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  void _showAddEditDialog(BuildContext context, NoticeModel? notice) {
    final theme = Theme.of(context);
    final isEdit = notice != null;

    final titleController = TextEditingController(text: notice?.title ?? '');
    final descriptionController =
        TextEditingController(text: notice?.description ?? '');
    String selectedPriority = notice?.priority ?? 'normal';
    DateTime? expiryDate = notice?.expiryDate;

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isEdit ? 'Edit Notice' : 'Create Notice',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CustomTextField(
                              controller: titleController,
                              labelText: 'Notice Title *',
                              hintText: 'Enter notice title',
                              prefixIcon: const Icon(Icons.title),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter notice title';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: descriptionController,
                              labelText: 'Description *',
                              hintText: 'Enter description',
                              maxLines: 6,
                              prefixIcon: const Icon(Icons.description),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter description';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomDropdown<String>(
                              value: selectedPriority,
                              labelText: 'Priority *',
                              prefixIcon: const Icon(Icons.flag),
                              items: const [
                                DropdownMenuItem(
                                    value: 'high',
                                    child: Text('High Priority')),
                                DropdownMenuItem(
                                    value: 'normal',
                                    child: Text('Normal Priority')),
                                DropdownMenuItem(
                                    value: 'low', child: Text('Low Priority')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedPriority = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            ListTile(
                              leading: const Icon(Icons.event_busy),
                              title: Text(
                                expiryDate == null
                                    ? 'Set Expiry Date (Optional)'
                                    : 'Expires: ${DateFormat('MMM dd, yyyy').format(expiryDate!)}',
                              ),
                              trailing: expiryDate != null
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          expiryDate = null;
                                        });
                                      },
                                    )
                                  : null,
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: expiryDate ??
                                      DateTime.now()
                                          .add(const Duration(days: 7)),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 365)),
                                );
                                if (picked != null) {
                                  setState(() {
                                    expiryDate = picked;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;

                          final newNotice = NoticeModel(
                            id: notice?.id ?? '',
                            title: titleController.text,
                            description: descriptionController.text,
                            issuedBy: notice?.issuedBy ?? '',
                            priority: selectedPriority,
                            issuedDate: notice?.issuedDate ?? DateTime.now(),
                            expiryDate: expiryDate,
                            targetedClassId: notice?.targetedClassId,
                            targetSections: notice?.targetSections,
                            attachment: notice?.attachment,
                          );

                          bool success;
                          if (isEdit) {
                            success = await controller.updateNotice(
                                notice.id, newNotice);
                          } else {
                            success = await controller.createNotice(newNotice);
                          }

                          if (success && context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        child: Text(isEdit ? 'Update' : 'Create'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, NoticeModel notice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notice'),
        content: Text('Are you sure you want to delete "${notice.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await controller.deleteNotice(notice.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
