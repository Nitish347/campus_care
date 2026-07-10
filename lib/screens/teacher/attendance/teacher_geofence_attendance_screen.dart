import 'package:campus_care/controllers/teacher_attendance_controller.dart';
import 'package:campus_care/models/teacher_attendance_model.dart';
import 'package:campus_care/widgets/admin/admin_page_header.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TeacherGeofenceAttendanceScreen extends StatefulWidget {
  const TeacherGeofenceAttendanceScreen({super.key});

  @override
  State<TeacherGeofenceAttendanceScreen> createState() =>
      _TeacherGeofenceAttendanceScreenState();
}

class _TeacherGeofenceAttendanceScreenState
    extends State<TeacherGeofenceAttendanceScreen> {
  late final TeacherAttendanceController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<TeacherAttendanceController>()
        ? Get.find<TeacherAttendanceController>()
        : Get.put(TeacherAttendanceController());
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _controller.loadTeacherData());
  }

  String _fmtTime(DateTime? date) =>
      date == null ? '-' : DateFormat('hh:mm a').format(date.toLocal());

  String _fmtDate(DateTime date) => DateFormat('dd MMM yyyy').format(date);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: Column(
        children: [
          AdminPageHeader(
            title: 'My Attendance',
            subtitle: 'Check in and out from inside your campus geofence',
            icon: Icons.my_location_rounded,
            showBackButton: true,
            showProfileControls: true,
            actions: [
              HeaderActionButton(
                icon: Icons.refresh_rounded,
                label: 'Refresh',
                onPressed: _controller.loadTeacherData,
              ),
            ],
          ),
          Expanded(
            child: ResponsivePadding(
              child: Obx(() {
                if (_controller.isLoading.value &&
                    _controller.todayRecord.value == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                return RefreshIndicator(
                  onRefresh: _controller.loadTeacherData,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    children: [
                      _buildStatusPanel(context, _controller.todayRecord.value),
                      const SizedBox(height: 16),
                      _buildGeofencePanel(context),
                      const SizedBox(height: 16),
                      _buildHistoryPanel(context),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPanel(
    BuildContext context,
    TeacherAttendanceLog? record,
  ) {
    final theme = Theme.of(context);
    final openSession = record?.isCheckedIn ?? false;
    final latestCompleted = !openSession && (record?.isCheckedOut ?? false);
    final accent = latestCompleted
        ? const Color(0xFF2563EB)
        : openSession
            ? const Color(0xFFEA580C)
            : const Color(0xFF059669);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: accent.withValues(alpha: 0.14),
                child: Icon(
                  latestCompleted
                      ? Icons.done_all_rounded
                      : openSession
                          ? Icons.login_rounded
                          : Icons.location_searching_rounded,
                  color: accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      latestCompleted
                          ? 'Ready for next check in'
                          : openSession
                              ? 'Checked in'
                              : 'Ready to check in',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      _fmtDate(DateTime.now()),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _timeChip(context, 'Check in', _fmtTime(record?.checkInAt)),
              _timeChip(context, 'Check out', _fmtTime(record?.checkOutAt)),
              _timeChip(
                context,
                'Accuracy',
                record?.checkInAccuracyMeters == null
                    ? '-'
                    : '${record!.checkInAccuracyMeters!.toStringAsFixed(0)} m',
              ),
            ],
          ),
          const SizedBox(height: 18),
          Obx(() {
            final submitting = _controller.isSubmittingLocation.value;
            return Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: submitting || openSession
                        ? null
                        : () => _controller.checkIn(),
                    icon: submitting && !openSession
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.login_rounded),
                    label: const Text('Check In'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: submitting || !openSession
                        ? null
                        : () => _controller.checkOut(),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Check Out'),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _timeChip(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Container(
      width: 170,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeofencePanel(BuildContext context) {
    final theme = Theme.of(context);
    if (_controller.geofences.isEmpty) {
      return EmptyState(
        icon: Icons.location_off_outlined,
        title: 'No active campus geofence',
        message: 'Ask your admin to add an active geofence before check-in.',
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Allowed campus zones',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          ..._controller.geofences.map((geofence) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.location_on_rounded),
              title: Text(geofence.name),
              subtitle: Text(
                'Radius ${geofence.radiusMeters.toStringAsFixed(0)} m',
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHistoryPanel(BuildContext context) {
    final theme = Theme.of(context);
    if (_controller.records.isEmpty) {
      return EmptyState(
        icon: Icons.history_outlined,
        title: 'No recent history',
        message: 'Your check-ins will appear here.',
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent attendance',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          ..._controller.records.take(10).map((record) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                record.isCheckedOut
                    ? Icons.done_all_rounded
                    : Icons.login_rounded,
              ),
              title: Text(_fmtDate(record.date)),
              subtitle: Text(
                'In ${_fmtTime(record.checkInAt)} | Out ${_fmtTime(record.checkOutAt)}',
              ),
            );
          }),
        ],
      ),
    );
  }
}
