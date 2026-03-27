import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/models/teacher/teacher.dart';
import 'package:campus_care/services/api/timetable_api_service.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';

import 'package:campus_care/widgets/admin/admin_page_header.dart';
class TeacherDetailsScreen extends StatefulWidget {
  final Teacher teacher;

  const TeacherDetailsScreen({
    super.key,
    required this.teacher,
  });

  @override
  State<TeacherDetailsScreen> createState() => _TeacherDetailsScreenState();
}

class _TeacherDetailsScreenState extends State<TeacherDetailsScreen> {
  final TimetableApiService _timetableApi = TimetableApiService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _teacherSchedule = [];
  Map<String, List<Map<String, dynamic>>> _scheduleByDay = {};

  @override
  void initState() {
    super.initState();
    _loadTeacherSchedule();
  }

  Future<void> _loadTeacherSchedule() async {
    try {
      setState(() => _isLoading = true);
      final schedule = await _timetableApi.getTimetables(
        teacherId: widget.teacher.id,
      );

      // Group by day
      final Map<String, List<Map<String, dynamic>>> byDay = {};
      for (var entry in schedule) {
        final day = entry['dayOfWeek'] as String;
        if (!byDay.containsKey(day)) {
          byDay[day] = [];
        }
        byDay[day]!.add(entry);
      }

      // Sort each day's schedule by start time
      byDay.forEach((key, value) {
        value.sort((a, b) =>
            (a['startTime'] as String).compareTo(b['startTime'] as String));
      });

      setState(() {
        _teacherSchedule = schedule.cast<Map<String, dynamic>>();
        _scheduleByDay = byDay;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar('Error', 'Failed to load teacher schedule: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AdminPageHeader(
        subtitle: 'View teacher profile details',
        icon: Icons.person,
        showBreadcrumb: true,
        breadcrumbLabel: 'Teachers',
        showBackButton: true,
        title: const Text('Teacher Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTeacherSchedule,
            tooltip: 'Refresh Schedule',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Get.snackbar('Info', 'Edit feature coming soon'),
            tooltip: 'Edit Teacher',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: ResponsivePadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              _buildProfileHeader(theme),
              const SizedBox(height: 24),

              // Personal Information
              _buildSectionCard(
                theme,
                'Personal Information',
                Icons.person_rounded,
                Colors.blue,
                [
                  _buildInfoRow(theme, Icons.badge_rounded, 'Teacher ID',
                      widget.teacher.id),
                  _buildInfoRow(theme, Icons.email_rounded, 'Email',
                      widget.teacher.email),
                  _buildInfoRow(theme, Icons.phone_rounded, 'Phone',
                      widget.teacher.phone ?? 'N/A'),
                  _buildInfoRow(theme, Icons.location_on_rounded, 'Address',
                      widget.teacher.address ?? 'N/A'),
                ],
              ),
              const SizedBox(height: 16),

              // Professional Information
              _buildSectionCard(
                theme,
                'Professional Information',
                Icons.work_rounded,
                Colors.purple,
                [
                  _buildInfoRow(theme, Icons.school_rounded, 'Department',
                      widget.teacher.department ?? 'N/A'),
                  _buildInfoRow(
                      theme,
                      Icons.calendar_today_rounded,
                      'Joining Date',
                      widget.teacher.hireDate != null
                          ? widget.teacher.hireDate.toString().split(' ')[0]
                          : 'N/A'),
                  _buildInfoRow(theme, Icons.class_rounded, 'Total Classes',
                      _getUniqueClassesCount().toString()),
                ],
              ),
              const SizedBox(height: 16),

              // Teaching Schedule
              _buildScheduleSection(theme),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: Colors.white,
            child: Text(
              widget.teacher.fullName.substring(0, 1).toUpperCase(),
              style: theme.textTheme.displayMedium?.copyWith(
                color: const Color(0xFF4F46E5),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.teacher.fullName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Text(
                    widget.teacher.department ?? 'Teacher',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    ThemeData theme,
    String title,
    IconData icon,
    Color accentColor,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(left: BorderSide(color: accentColor, width: 4)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon,
              size: 20, color: theme.colorScheme.primary.withOpacity(0.7)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(left: BorderSide(color: Colors.green, width: 4)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    const Icon(Icons.schedule, color: Colors.green, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Teaching Schedule',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (!_isLoading)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_teacherSchedule.length} periods/week',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_teacherSchedule.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.event_busy,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant
                            .withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text(
                      'No classes assigned yet',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._buildScheduleList(theme),
        ],
      ),
    );
  }

  List<Widget> _buildScheduleList(ThemeData theme) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    final widgets = <Widget>[];

    for (var day in days) {
      final daySchedule = _scheduleByDay[day];
      if (daySchedule != null && daySchedule.isNotEmpty) {
        widgets.add(_buildDaySchedule(theme, day, daySchedule));
        widgets.add(const SizedBox(height: 12));
      }
    }

    return widgets;
  }

  Widget _buildDaySchedule(
      ThemeData theme, String day, List<Map<String, dynamic>> schedule) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(_getDayIcon(day), color: theme.colorScheme.primary),
        title: Text(
          day,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
            '${schedule.length} ${schedule.length == 1 ? 'period' : 'periods'}'),
        children:
            schedule.map((period) => _buildPeriodTile(theme, period)).toList(),
      ),
    );
  }

  Widget _buildPeriodTile(ThemeData theme, Map<String, dynamic> period) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  period['startTime'] ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  period['endTime'] ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  period['subject'] ?? '',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.class_,
                        size: 14, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      'Class ${period['class']} - Section ${period['section']}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (period['room'] != null &&
                        (period['room'] as String).isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.room,
                          size: 14, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        'Room ${period['room']}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDayIcon(String day) {
    switch (day) {
      case 'Monday':
        return Icons.calendar_today;
      case 'Tuesday':
        return Icons.calendar_view_week;
      case 'Wednesday':
        return Icons.calendar_view_day;
      case 'Thursday':
        return Icons.event;
      case 'Friday':
        return Icons.event_available;
      case 'Saturday':
        return Icons.weekend;
      default:
        return Icons.calendar_today;
    }
  }

  int _getUniqueClassesCount() {
    final classes = <String>{};
    for (var period in _teacherSchedule) {
      classes.add('${period['class']}-${period['section']}');
    }
    return classes.length;
  }
}
