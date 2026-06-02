import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/services/api/notice_api_service.dart';
import 'package:campus_care/utils/app_utils.dart';
import 'package:campus_care/widgets/popup_widgets/notification_popup.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/models/notice_model.dart';
import 'package:campus_care/widgets/common/info_card.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/student/student_app_bar.dart';
import 'package:get/get.dart';

class StudentNotificationsScreen extends StatefulWidget {
  const StudentNotificationsScreen({super.key});

  @override
  State<StudentNotificationsScreen> createState() =>
      _StudentNotificationsScreenState();
}

class _StudentNotificationsScreenState
    extends State<StudentNotificationsScreen> {
  final NoticeApiService _noticeApi = NoticeApiService();
  final AuthController _authController = Get.find<AuthController>();
  List<NoticeModel> _notices = [];
  bool _isLoading = true;
  String? _studentClassId;
  String? _studentSection;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final student = _authController.currentStudent;
      if (student == null) {
        return;
      }

      _studentClassId = student.class_;
      _studentSection = student.section;

      final noticesData = await _noticeApi.getNotices(
        classId: _studentClassId,
        section: _studentSection,
        targetRole: 'student',
      );
      final allNotices = noticesData
          .whereType<Map>()
          .map((data) => NoticeModel.fromJson(Map<String, dynamic>.from(data)))
          .toList();

      // Filter notices for this student
      _notices = allNotices.where((notice) {
        // Check if notice is targeted to this student's class/section
        if (notice.targetedClassId != null &&
            notice.targetedClassId!.isNotEmpty) {
          if (!notice.targetedClassId!.contains(_studentClassId)) {
            return false;
          }
        }
        if (notice.targetSections != null &&
            notice.targetSections!.isNotEmpty) {
          if (!notice.targetSections!.contains(_studentSection)) {
            return false;
          }
        }
        // Check if notice has expired
        if (notice.expiryDate != null &&
            notice.expiryDate!.isBefore(DateTime.now())) {
          return false;
        }
        return true;
      }).toList();

      _notices.sort((a, b) {
        final priorityOrder = {'high': 3, 'medium': 2, 'low': 1};
        final aPriority = priorityOrder[
                a.priority.toLowerCase().replaceAll('normal', 'medium')] ??
            0;
        final bPriority = priorityOrder[
                b.priority.toLowerCase().replaceAll('normal', 'medium')] ??
            0;
        if (aPriority != bPriority) {
          return bPriority.compareTo(aPriority);
        }
        return b.issuedDate.compareTo(a.issuedDate);
      });
    } catch (_) {
      _notices = [];
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: StudentAppBar(
        title: 'Notifications',
        extraActions: [
          const SizedBox(width: 6),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _loadNotifications,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.refresh, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notices.isEmpty
              ? const EmptyState(
                  icon: Icons.notifications_none,
                  title: 'No notifications',
                  message: 'You have no notifications at this time',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notices.length,
                  itemBuilder: (context, index) {
                    final notice = _notices[index];
                    final priorityColor =
                        AppUtils.getPriorityColor(notice.priority);
                    final isExpired = notice.expiryDate != null &&
                        notice.expiryDate!.isBefore(DateTime.now());

                    return InfoCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () =>
                            NotificationDetailPopup.show(context, notice),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: priorityColor,
                                width: 4,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Container(
                                //   padding: const EdgeInsets.all(12),
                                //   decoration: BoxDecoration(
                                //     color: priorityColor.withValues(alpha: 0.1),
                                //     borderRadius: BorderRadius.circular(12),
                                //   ),
                                //   child: Icon(
                                //     AppUtils.getPriorityIcon(notice.priority),
                                //     color: priorityColor,
                                //     size: 24,
                                //   ),
                                // ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              notice.title,
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          // Container(
                                          //   padding: const EdgeInsets.symmetric(
                                          //     horizontal: 8,
                                          //     vertical: 4,
                                          //   ),
                                          //   decoration: BoxDecoration(
                                          //     color: priorityColor
                                          //         .withValues(alpha: 0.2),
                                          //     borderRadius:
                                          //         BorderRadius.circular(6),
                                          //   ),
                                          //   child: Text(
                                          //     notice.priority.toUpperCase(),
                                          //     style: theme.textTheme.labelSmall
                                          //         ?.copyWith(
                                          //       color: priorityColor,
                                          //       fontWeight: FontWeight.bold,
                                          //     ),
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        notice.description,
                                        style: theme.textTheme.bodyMedium,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 14,
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            DateFormat('MMM dd, yyyy')
                                                .format(notice.issuedDate),
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: theme
                                                  .colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                          if (isExpired) ...[
                                            const SizedBox(width: 12),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey
                                                    .withValues(alpha: 0.2),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'Expired',
                                                style: theme
                                                    .textTheme.labelSmall
                                                    ?.copyWith(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Icon(
                                //   Icons.chevron_right,
                                //   color: theme.colorScheme.onSurfaceVariant,
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
