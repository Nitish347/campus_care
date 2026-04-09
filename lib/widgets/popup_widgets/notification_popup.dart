import 'package:campus_care/utils/app_utils.dart';
import 'package:campus_care/utils/upload_url_utils.dart';
import 'package:campus_care/widgets/common/file_display_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/notice_model.dart';

class NotificationDetailPopup {
  static void show(BuildContext context, NoticeModel notice) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: _NotificationPopupContent(notice: notice),
      ),
    );
  }
}

class _NotificationPopupContent extends StatelessWidget {
  final NoticeModel notice;

  const _NotificationPopupContent({
    required this.notice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageAttachments = _getImageAttachmentCandidates(notice.attachment);
    final nonImageAttachments = _getNonImageAttachments(notice.attachment);

    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppUtils.getPriorityColor(
                notice.priority,
              ).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppUtils.getPriorityColor(
                      notice.priority,
                    ).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    AppUtils.getPriorityIcon(notice.priority),
                    color: AppUtils.getPriorityColor(notice.priority),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notice.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppUtils.getPriorityColor(
                            notice.priority,
                          ).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          notice.priority.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppUtils.getPriorityColor(
                              notice.priority,
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    context,
                    Icons.description,
                    'Description',
                    notice.description,
                  ),
                  if (imageAttachments.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Images',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...imageAttachments.map((imageUrls) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: FileDisplayWidget(
                          fileUrls: imageUrls,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(10),
                          enablePreview: true,
                          previewTitle: notice.title,
                          errorWidget: Container(
                            height: 100,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('Unable to load image'),
                          ),
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    context,
                    Icons.calendar_today,
                    'Issued Date',
                    DateFormat('EEEE, MMMM dd, yyyy').format(notice.issuedDate),
                  ),
                  if (notice.expiryDate != null) ...[
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      context,
                      Icons.event_busy,
                      'Expiry Date',
                      DateFormat('EEEE, MMMM dd, yyyy')
                          .format(notice.expiryDate!),
                    ),
                  ],
                  if (nonImageAttachments.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Attachments',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...nonImageAttachments.map((attachment) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () {
                            // Handle attachment download/open
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.attach_file,
                                  size: 20,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    attachment,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                                Icon(
                                  Icons.download,
                                  size: 20,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<List<String>> _getImageAttachmentCandidates(List<String>? attachments) {
    if (attachments == null || attachments.isEmpty) return const [];

    final results = <List<String>>[];
    for (final attachment in attachments) {
      if (_isImageAttachment(attachment)) {
        final candidates = UploadUrlUtils.buildCandidateUrls(attachment);
        if (candidates.isNotEmpty) {
          results.add(candidates);
        }
      }
    }
    return results;
  }

  List<String> _getNonImageAttachments(List<String>? attachments) {
    if (attachments == null || attachments.isEmpty) return const [];

    return attachments.where((item) => !_isImageAttachment(item)).toList();
  }

  bool _isImageAttachment(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return false;

    final withoutQuery = normalized.split('?').first;
    return withoutQuery.endsWith('.png') ||
        withoutQuery.endsWith('.jpg') ||
        withoutQuery.endsWith('.jpeg') ||
        withoutQuery.endsWith('.webp') ||
        withoutQuery.endsWith('.gif');
  }
}
