import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/models/student/student_attendance_model.dart';
import 'package:campus_care/services/storage_service.dart';
import 'package:campus_care/services/auth_service.dart';
import 'package:campus_care/core/constants/app_constants.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/widgets/common/info_card.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';

class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  State<StudentAttendanceScreen> createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  List<StudentAttendanceModel> _allAttendance = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = AuthService.getCurrentUser();
      if (currentUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Load attendance data from storage
      final attendanceData = StorageService.getData(AppConstants.keyAttendance);

      // Filter attendance for current student
      _allAttendance = attendanceData
          .where((data) => data['userId'] == currentUser.id)
          .map((data) => StudentAttendanceModel.fromJson(data))
          .toList();
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getAttendanceForMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDay.day;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Get the first day of week (0 = Sunday, 1 = Monday, etc.)
    final firstDayOfWeek = firstDay.weekday % 7;

    // Generate attendance data for the month
    final attendance = <Map<String, dynamic>>[];

    // Add empty cells for days before the first day of the month
    for (int i = 0; i < firstDayOfWeek; i++) {
      attendance.add({'date': null, 'status': null, 'attendance': null});
    }

    // Add days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      final dateOnly = DateTime(date.year, date.month, date.day);

      // Check if this date is in the future
      final isFuture = dateOnly.isAfter(today);

      // Find attendance record for this date
      StudentAttendanceModel? attendanceRecord;
      for (var att in _allAttendance) {
        final attDate = DateTime(
          att.dateTime.year,
          att.dateTime.month,
          att.dateTime.day,
        );
        if (attDate == dateOnly) {
          attendanceRecord = att;
          break;
        }
      }

      attendance.add({
        'date': date,
        'status': attendanceRecord?.status,
        'attendance': attendanceRecord,
        'isFuture': isFuture,
      });
    }

    return attendance;
  }

  List<Map<String, dynamic>> get _attendance =>
      _getAttendanceForMonth(_selectedDate);

  int get _presentDays {
    final markedDays = _attendance
        .where((a) => a['date'] != null && a['status'] != null)
        .toList();
    return markedDays.where((a) => a['status'] == 'present').length;
  }

  int get _absentDays {
    final markedDays = _attendance
        .where((a) => a['date'] != null && a['status'] != null)
        .toList();
    return markedDays.where((a) => a['status'] == 'absent').length;
  }

  int get _attendancePercentage {
    final markedDays = _attendance
        .where((a) => a['date'] != null && a['status'] != null)
        .toList();
    if (markedDays.isEmpty) return 0;
    return (_presentDays / markedDays.length * 100).round();
  }

  void _previousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Attendance'),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => Get.toNamed(AppRoutes.studentNotifications),
              tooltip: 'Notifications',
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Calendar View'),
              Tab(text: 'List View'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Month/Year Selector
                  ResponsivePadding(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: _previousMonth,
                            icon: const Icon(Icons.arrow_back_ios),
                            tooltip: 'Previous Month',
                          ),
                          const SizedBox(width: 10),
                          Text(
                            DateFormat('MMMM yyyy').format(_selectedDate),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: _nextMonth,
                            icon: const Icon(Icons.arrow_forward_ios),
                            tooltip: 'Next Month',
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Summary Card
                  ResponsivePadding(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(context, 'Present', '$_presentDays',
                              Colors.green),
                          _buildStatItem(
                              context, 'Absent', '$_absentDays', Colors.red),
                          _buildStatItem(
                              context,
                              'Percentage',
                              '$_attendancePercentage%',
                              theme.colorScheme.primary),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildCalendarView(context),
                        _buildListView(context),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildCalendarView(BuildContext context) {
    final theme = Theme.of(context);
    final weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return ResponsivePadding(
      child: Column(
        children: [
          // Week day headers
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 7,
            itemBuilder: (context, index) {
              return Center(
                child: Text(
                  weekDays[index],
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          // Calendar days
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _attendance.length,
              itemBuilder: (context, index) {
                final att = _attendance[index];
                final date = att['date'] as DateTime?;

                // Empty cell for days before month starts
                if (date == null) {
                  return const SizedBox.shrink();
                }

                final status = att['status'] as String?;
                final isFuture = att['isFuture'] as bool;
                final isPresent = status == 'present';
                final isAbsent = status == 'absent';
                final dateOnly = DateTime(date.year, date.month, date.day);
                final isToday = dateOnly == today;

                return Container(
                  decoration: BoxDecoration(
                    color: isFuture
                        ? theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5)
                        : isPresent
                            ? Colors.green.withValues(alpha: 0.2)
                            : isAbsent
                                ? Colors.red.withValues(alpha: 0.2)
                                : theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isToday
                          ? theme.colorScheme.primary
                          : isFuture
                              ? theme.colorScheme.outline.withValues(alpha: 0.3)
                              : isPresent
                                  ? Colors.green
                                  : isAbsent
                                      ? Colors.red
                                      : theme.colorScheme.outline
                                          .withValues(alpha: 0.2),
                      width: isToday ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('dd').format(date),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.normal,
                          color: isFuture
                              ? theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5)
                              : isToday
                                  ? theme.colorScheme.primary
                                  : null,
                        ),
                      ),
                      if (isPresent || isAbsent) ...[
                        const SizedBox(height: 4),
                        Icon(
                          isPresent ? Icons.check_circle : Icons.cancel,
                          size: 16,
                          color: isPresent ? Colors.green : Colors.red,
                        ),
                      ] else if (isFuture) ...[
                        const SizedBox(height: 4),
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(BuildContext context) {
    final theme = Theme.of(context);
    final attendanceList = _attendance.where((a) => a['date'] != null).toList();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return ResponsivePadding(
      child: attendanceList.isEmpty
          ? Center(
              child: Text(
                'No attendance data for this month',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : ListView.builder(
              itemCount: attendanceList.length,
              itemBuilder: (context, index) {
                final att = attendanceList[index];
                final date = att['date'] as DateTime;
                final status = att['status'] as String?;
                final attendanceRecord =
                    att['attendance'] as StudentAttendanceModel?;
                final isFuture = att['isFuture'] as bool;
                final dateOnly = DateTime(date.year, date.month, date.day);
                final isToday = dateOnly == today;
                final isPresent = status == 'present';
                final isAbsent = status == 'absent';

                return InfoCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isFuture
                            ? theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5)
                            : isPresent
                                ? Colors.green.withValues(alpha: 0.1)
                                : isAbsent
                                    ? Colors.red.withValues(alpha: 0.1)
                                    : theme.colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isFuture
                            ? Icons.schedule
                            : isPresent
                                ? Icons.check_circle
                                : isAbsent
                                    ? Icons.cancel
                                    : Icons.help_outline,
                        color: isFuture
                            ? theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5)
                            : isPresent
                                ? Colors.green
                                : isAbsent
                                    ? Colors.red
                                    : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            DateFormat('EEEE, MMMM dd, yyyy').format(date),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: isFuture
                                  ? theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.6)
                                  : null,
                            ),
                          ),
                        ),
                        if (isToday)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Today',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('dd MMM yyyy').format(date),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (attendanceRecord != null &&
                            attendanceRecord.remark != null &&
                            attendanceRecord.remark!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Remark: ${attendanceRecord.remark}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: isFuture
                        ? Chip(
                            label: Text(
                              'Not Marked',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                            backgroundColor: theme
                                .colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                          )
                        : status != null
                            ? Chip(
                                label: Text(
                                  isPresent ? 'Present' : 'Absent',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: isPresent
                                    ? Colors.green.withValues(alpha: 0.2)
                                    : Colors.red.withValues(alpha: 0.2),
                              )
                            : null,
                  ),
                );
              },
            ),
    );
  }
}
