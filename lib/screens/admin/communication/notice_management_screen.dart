import 'dart:typed_data';

import 'package:campus_care/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/controllers/notice_controller.dart';
import 'package:campus_care/models/notice_model.dart';
import 'package:campus_care/utils/upload_url_utils.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:campus_care/widgets/inputs/custom_dropdown.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/common/file_display_widget.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:image_picker/image_picker.dart';

import 'package:campus_care/widgets/admin/admin_page_header.dart';

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
    final isAdmin = authController.isAdmin();
    final isDesktopWeb = MediaQuery.of(context).size.width >= 1100;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AdminPageHeader(
        subtitle: 'Broadcast announcements',
        icon: Icons.campaign,
        showBreadcrumb: true,
        breadcrumbLabel: 'Notices',
        showBackButton: true,
        title: const Text('Notice Management'),
        actions: [
          HeaderActionButton(
            icon: Icons.refresh_rounded,
            label: 'Refresh',
            onPressed: () => controller.loadNotices(),
          ),
          if (isAdmin) const SizedBox(width: 8),
          if (isAdmin)
            HeaderActionButton(
              icon: Icons.add_rounded,
              label: 'Add Notice',
              onPressed: () => _showAddEditDialog(context, null),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchToolbar(context, theme, isAdmin, isDesktopWeb),

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
                  action: controller.searchQuery.isEmpty && isAdmin
                      ? ElevatedButton.icon(
                          onPressed: () => _showAddEditDialog(context, null),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Create Notice'),
                        )
                      : null,
                );
              }

              if (isDesktopWeb) {
                return _buildDesktopNoticeGrid(
                  context,
                  theme,
                  controller.notices,
                  isAdmin,
                );
              }

              return ResponsivePadding(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(0, 12, 0, 20),
                  itemCount: controller.notices.length,
                  itemBuilder: (context, index) {
                    final notice = controller.notices[index];
                    return _buildNoticeCard(
                      context,
                      theme,
                      notice,
                      isAdmin,
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

  Widget _buildDesktopNoticeGrid(
    BuildContext context,
    ThemeData theme,
    List<NoticeModel> notices,
    bool isAdmin,
  ) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 560,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            mainAxisExtent: 340,
          ),
          itemCount: notices.length,
          itemBuilder: (context, index) {
            final notice = notices[index];
            return _buildNoticeCard(
              context,
              theme,
              notice,
              isAdmin,
              compact: true,
              withBottomMargin: false,
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchToolbar(
    BuildContext context,
    ThemeData theme,
    bool isAdmin,
    bool isDesktopWeb,
  ) {
    return ResponsivePadding(
      desktopPadding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDesktopWeb ? 1240 : double.infinity,
          ),
          child: Container(
            margin: const EdgeInsets.only(top: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Obx(() {
              final noticeCount = controller.notices.length;
              final query = controller.searchQuery;
              final expiredCount = controller.notices
                  .where(
                    (notice) =>
                        notice.expiryDate != null &&
                        notice.expiryDate!.isBefore(DateTime.now()),
                  )
                  .length;
              final activeCount = noticeCount - expiredCount;
              final highPriorityCount = controller.notices
                  .where((notice) => notice.priority.toLowerCase() == 'high')
                  .length;

              if (isDesktopWeb) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: CustomTextField(
                        hintText: 'Search notices by title or description...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        onChanged: controller.searchNotices,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.end,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _buildToolbarPill(
                              theme,
                              icon: Icons.campaign_rounded,
                              label: '$noticeCount notices',
                            ),
                            _buildToolbarPill(
                              theme,
                              icon: Icons.check_circle_outline_rounded,
                              label: '$activeCount active',
                              color: Colors.green,
                            ),
                            if (expiredCount > 0)
                              _buildToolbarPill(
                                theme,
                                icon: Icons.warning_amber_rounded,
                                label: '$expiredCount expired',
                                color: theme.colorScheme.error,
                              ),
                            if (highPriorityCount > 0)
                              _buildToolbarPill(
                                theme,
                                icon: Icons.priority_high_rounded,
                                label: '$highPriorityCount high priority',
                                color: const Color(0xFFD97706),
                              ),
                            if (query.isNotEmpty)
                              _buildToolbarPill(
                                theme,
                                icon: Icons.filter_alt_rounded,
                                label: 'Filtered',
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  CustomTextField(
                    hintText: 'Search notices by title or description...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    onChanged: controller.searchNotices,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildToolbarPill(
                        theme,
                        icon: Icons.campaign_rounded,
                        label: '$noticeCount notices',
                      ),
                      const SizedBox(width: 8),
                      if (query.isNotEmpty)
                        _buildToolbarPill(
                          theme,
                          icon: Icons.filter_alt_rounded,
                          label: 'Filtered',
                        ),
                      const Spacer(),
                      if (isAdmin)
                        TextButton.icon(
                          onPressed: () => _showAddEditDialog(context, null),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('New Notice'),
                        ),
                    ],
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarPill(
    ThemeData theme, {
    required IconData icon,
    required String label,
    Color? color,
  }) {
    final pillColor = color ?? theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: pillColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: pillColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: pillColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeCard(
    BuildContext context,
    ThemeData theme,
    NoticeModel notice,
    bool isAdmin, {
    bool compact = false,
    bool withBottomMargin = true,
  }) {
    final priorityColor = _priorityColor(notice.priority, theme);
    final priorityLabel = _priorityLabel(notice.priority);
    final isExpired = notice.expiryDate != null &&
        notice.expiryDate!.isBefore(DateTime.now());
    final noticeImageUrls = _getFirstImageAttachmentUrls(notice.attachment);
    return Container(
      margin: withBottomMargin ? const EdgeInsets.only(bottom: 12) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showNoticeDetails(context, notice),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: EdgeInsets.all(compact ? 12 : 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: priorityColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notice.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Issued ${DateFormat('MMM dd, yyyy').format(notice.issuedDate)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildPriorityBadge(theme, priorityColor, priorityLabel),
                    if (isAdmin) ...[
                      const SizedBox(width: 6),
                      PopupMenuButton(
                        splashRadius: 20,
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_rounded),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_rounded, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete',
                                    style: TextStyle(color: Colors.red)),
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
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  notice.description,
                  style: theme.textTheme.bodyMedium,
                  maxLines: compact ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (noticeImageUrls.isNotEmpty) ...[
                  SizedBox(height: compact ? 10 : 12),
                  FileDisplayWidget(
                    fileUrls: noticeImageUrls,
                    width: double.infinity,
                    height: compact ? 130 : 160,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(12),
                    enablePreview: true,
                    previewTitle: notice.title,
                    errorWidget: const SizedBox.shrink(),
                  ),
                ],
                SizedBox(height: compact ? 10 : 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildMetaChip(
                      theme,
                      icon: Icons.notifications_active_rounded,
                      label: 'Announcement',
                    ),
                    if (notice.expiryDate != null)
                      _buildMetaChip(
                        theme,
                        icon: isExpired
                            ? Icons.warning_amber_rounded
                            : Icons.event_busy_rounded,
                        label:
                            'Expires ${DateFormat('MMM dd').format(notice.expiryDate!)}',
                        color: isExpired
                            ? theme.colorScheme.error
                            : theme.colorScheme.secondary,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _priorityColor(String priority, ThemeData theme) {
    switch (priority.toLowerCase()) {
      case 'high':
        return theme.colorScheme.error;
      case 'medium':
      case 'normal':
        return const Color(0xFFD97706);
      case 'low':
        return theme.colorScheme.primary;
      default:
        return theme.colorScheme.primary;
    }
  }

  String _priorityLabel(String priority) {
    if (priority.toLowerCase() == 'normal') {
      return 'MEDIUM';
    }
    return priority.toUpperCase();
  }

  Widget _buildPriorityBadge(
    ThemeData theme,
    Color color,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildMetaChip(
    ThemeData theme, {
    required IconData icon,
    required String label,
    Color? color,
  }) {
    final chipColor = color ?? theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showNoticeDetails(BuildContext context, NoticeModel notice) {
    final theme = Theme.of(context);
    final noticeImageUrls = _getFirstImageAttachmentUrls(notice.attachment);
    final priorityColor = _priorityColor(notice.priority, theme);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(22),
          child: SingleChildScrollView(
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
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _buildPriorityBadge(
                  theme,
                  priorityColor,
                  _priorityLabel(notice.priority),
                ),
                const SizedBox(height: 14),
                Text(
                  notice.description,
                  style: theme.textTheme.bodyLarge,
                ),
                if (noticeImageUrls.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  FileDisplayWidget(
                    fileUrls: noticeImageUrls,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(12),
                    enablePreview: true,
                    previewTitle: notice.title,
                    errorWidget: Container(
                      height: 120,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Could not load notice image',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _buildDetailChip(
                      theme,
                      Icons.calendar_today_rounded,
                      'Issued: ${DateFormat('MMM dd, yyyy').format(notice.issuedDate)}',
                    ),
                    if (notice.expiryDate != null)
                      _buildDetailChip(
                        theme,
                        Icons.event_busy_rounded,
                        'Expires: ${DateFormat('MMM dd, yyyy').format(notice.expiryDate!)}',
                        color: theme.colorScheme.secondary,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip(
    ThemeData theme,
    IconData icon,
    String text, {
    Color? color,
  }) {
    final chipColor = color ?? theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
    final imagePicker = ImagePicker();
    Uint8List? selectedImageBytes;
    String? selectedImageFileName;
    List<String> existingImageUrls =
        _getFirstImageAttachmentUrls(notice?.attachment);
    bool removeExistingImage = false;
    bool isSubmitting = false;

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600, maxHeight: 760),
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
                            const SizedBox(height: 12),
                            Text(
                              'Notice Image (Optional)',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 180,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                border: Border.all(
                                  color: theme.colorScheme.outline.withValues(
                                    alpha: 0.25,
                                  ),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: selectedImageBytes != null
                                    ? Image.memory(
                                        selectedImageBytes!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      )
                                    : (!removeExistingImage &&
                                            existingImageUrls.isNotEmpty)
                                        ? FileDisplayWidget(
                                            fileUrls: existingImageUrls,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            enablePreview: true,
                                            previewTitle:
                                                notice?.title ?? 'Notice Image',
                                            errorWidget:
                                                _buildImagePlaceholder(theme),
                                          )
                                        : _buildImagePlaceholder(theme),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: isSubmitting
                                      ? null
                                      : () async {
                                          final picked =
                                              await imagePicker.pickImage(
                                            source: ImageSource.gallery,
                                            imageQuality: 85,
                                            maxWidth: 1600,
                                          );
                                          if (picked == null) return;
                                          final bytes =
                                              await picked.readAsBytes();
                                          if (!context.mounted) return;

                                          setState(() {
                                            selectedImageBytes = bytes;
                                            selectedImageFileName = picked.name;
                                            removeExistingImage = false;
                                          });
                                        },
                                  icon:
                                      const Icon(Icons.photo_library_outlined),
                                  label: const Text('Choose Image'),
                                ),
                                if (selectedImageBytes != null ||
                                    (!removeExistingImage &&
                                        existingImageUrls.isNotEmpty))
                                  TextButton.icon(
                                    onPressed: isSubmitting
                                        ? null
                                        : () {
                                            setState(() {
                                              selectedImageBytes = null;
                                              selectedImageFileName = null;
                                              removeExistingImage = true;
                                              if (!isEdit) {
                                                existingImageUrls = const [];
                                              }
                                            });
                                          },
                                    icon: const Icon(Icons.delete_outline),
                                    label: const Text('Remove'),
                                  ),
                              ],
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
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;

                                setState(() {
                                  isSubmitting = true;
                                });

                                final currentAttachments = <String>[];
                                if (notice?.attachment != null) {
                                  if (removeExistingImage) {
                                    currentAttachments.addAll(
                                      notice!.attachment!.where(
                                        (item) => !_isImageAttachment(item),
                                      ),
                                    );
                                  } else {
                                    currentAttachments.addAll(
                                      List<String>.from(notice!.attachment!),
                                    );
                                  }
                                }

                                final attachmentPayload =
                                    (currentAttachments.isEmpty &&
                                            !removeExistingImage)
                                        ? null
                                        : currentAttachments;

                                final newNotice = NoticeModel(
                                  id: notice?.id ?? '',
                                  title: titleController.text,
                                  description: descriptionController.text,
                                  issuedBy: notice?.issuedBy ?? '',
                                  priority: selectedPriority,
                                  issuedDate:
                                      notice?.issuedDate ?? DateTime.now(),
                                  expiryDate: expiryDate,
                                  targetedClassId: notice?.targetedClassId,
                                  targetSections: notice?.targetSections,
                                  attachment: attachmentPayload,
                                );

                                bool success;
                                if (isEdit) {
                                  success = await controller.updateNotice(
                                    notice.id,
                                    newNotice,
                                    imageBytes: selectedImageBytes,
                                    imageFileName: selectedImageFileName,
                                  );
                                } else {
                                  success = await controller.createNotice(
                                    newNotice,
                                    imageBytes: selectedImageBytes,
                                    imageFileName: selectedImageFileName,
                                  );
                                }

                                if (context.mounted) {
                                  setState(() {
                                    isSubmitting = false;
                                  });
                                }

                                if (success && context.mounted) {
                                  Navigator.pop(context);
                                }
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(isEdit ? 'Update' : 'Create'),
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

  Widget _buildImagePlaceholder(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 40,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            'No image selected',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getFirstImageAttachmentUrls(List<String>? attachments) {
    if (attachments == null || attachments.isEmpty) return const [];

    for (final attachment in attachments) {
      if (_isImageAttachment(attachment)) {
        return UploadUrlUtils.buildCandidateUrls(attachment);
      }
    }

    return const [];
  }

  bool _isImageAttachment(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return false;

    final base = normalized.split('?').first;
    return base.endsWith('.png') ||
        base.endsWith('.jpg') ||
        base.endsWith('.jpeg') ||
        base.endsWith('.webp') ||
        base.endsWith('.gif');
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
