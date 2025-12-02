import 'package:campus_care/widgets/common/summary_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/models/student/student_attendance_model.dart';
import 'package:campus_care/services/storage_service.dart';
import 'package:campus_care/services/auth_service.dart';
import 'package:campus_care/core/constants/app_constants.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';

class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  State<StudentAttendanceScreen> createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  List<StudentAttendanceModel> _allAttendance = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Present', 'Absent'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAttendance();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  List<Map<String, dynamic>> get _filteredAttendanceList {
    final list = _attendance
        .where((a) => a['date'] != null && a['status'] != null)
        .toList()
        .reversed
        .toList();

    if (_selectedFilter == 'All') {
      return list;
    }
    return list
        .where((a) => a['status'] == _selectedFilter.toLowerCase())
        .toList();
  }

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_outlined),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Get.toNamed(AppRoutes.studentNotifications),
            tooltip: 'Notifications',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.calendar_month),
              text: 'Calendar',
            ),
            Tab(
              icon: Icon(Icons.list),
              text: 'List',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary Header with Gradient
                SummaryCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem(
                        context,
                        Icons.check_circle_outline,
                        '$_presentDays',
                        'Present',
                        Colors.green,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                      _buildSummaryItem(
                        context,
                        Icons.cancel_outlined,
                        '$_absentDays',
                        'Absent',
                        Colors.red,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                      _buildSummaryItem(
                        context,
                        Icons.percent,
                        '$_attendancePercentage%',
                        'Rate',
                        _attendancePercentage >= 75
                            ? Colors.green
                            : _attendancePercentage >= 50
                                ? Colors.orange
                                : Colors.red,
                      ),
                    ],
                  ),
                ),

                // Month Selector
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: _previousMonth,
                        icon: const Icon(Icons.chevron_left),
                        tooltip: 'Previous Month',
                      ),
                      Text(
                        DateFormat('MMMM yyyy').format(_selectedDate),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: _nextMonth,
                        icon: const Icon(Icons.chevron_right),
                        tooltip: 'Next Month',
                      ),
                    ],
                  ),
                ),

                // TabBarView
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCalendarView(context),
                      _buildListView(context),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
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
          const SizedBox(height: 16),
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
                    color: theme.colorScheme.primary,
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

                return InkWell(
                  onTap: () {
                    if (att['attendance'] != null) {
                      _showAttendanceDetails(
                          context, att['attendance'] as StudentAttendanceModel);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: isPresent
                          ? LinearGradient(
                              colors: [
                                Colors.green.withOpacity(0.2),
                                Colors.green.withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : isAbsent
                              ? LinearGradient(
                                  colors: [
                                    Colors.red.withOpacity(0.2),
                                    Colors.red.withOpacity(0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                      color: isFuture
                          ? theme.colorScheme.surfaceContainerHighest
                              .withOpacity(0.3)
                          : !isPresent && !isAbsent
                              ? theme.colorScheme.surfaceContainerHighest
                                  .withOpacity(0.5)
                              : null,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isToday
                            ? theme.colorScheme.primary
                            : isPresent
                                ? Colors.green.withOpacity(0.5)
                                : isAbsent
                                    ? Colors.red.withOpacity(0.5)
                                    : theme.colorScheme.outline
                                        .withOpacity(0.2),
                        width: isToday ? 3 : 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('dd').format(date),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.w600,
                            color: isFuture
                                ? theme.colorScheme.onSurfaceVariant
                                    .withOpacity(0.5)
                                : isToday
                                    ? theme.colorScheme.primary
                                    : null,
                          ),
                        ),
                        if (isPresent || isAbsent) ...[
                          const SizedBox(height: 4),
                          Icon(
                            isPresent ? Icons.check_circle : Icons.cancel,
                            size: 18,
                            color: isPresent ? Colors.green : Colors.red,
                          ),
                        ] else if (isFuture) ...[
                          const SizedBox(height: 4),
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.4),
                          ),
                        ],
                      ],
                    ),
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
    final attendanceList = _filteredAttendanceList;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return ResponsivePadding(
      child: attendanceList.isEmpty
          ? EmptyState(
              icon: Icons.event_busy,
              title: 'No attendance records',
              message: _selectedFilter == 'All'
                  ? 'No attendance records for this month'
                  : 'No $_selectedFilter records for this month',
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: attendanceList.length,
              itemBuilder: (context, index) {
                final att = attendanceList[index];
                final date = att['date'] as DateTime;
                final status = att['status'] as String;
                final attendanceRecord =
                    att['attendance'] as StudentAttendanceModel?;
                final dateOnly = DateTime(date.year, date.month, date.day);
                final isToday = dateOnly == today;
                final isPresent = status == 'present';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: attendanceRecord != null
                          ? () =>
                              _showAttendanceDetails(context, attendanceRecord)
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Status Icon
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isPresent
                                      ? [
                                          Colors.green.withOpacity(0.2),
                                          Colors.green.withOpacity(0.1),
                                        ]
                                      : [
                                          Colors.red.withOpacity(0.2),
                                          Colors.red.withOpacity(0.1),
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isPresent ? Icons.check_circle : Icons.cancel,
                                color: isPresent ? Colors.green : Colors.red,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Date and Status
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        DateFormat('EEEE').format(date),
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (isToday) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: theme
                                                .colorScheme.primaryContainer,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'Today',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('MMMM dd, yyyy').format(date),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  if (attendanceRecord?.remark != null &&
                                      attendanceRecord!.remark!.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.note_outlined,
                                          size: 16,
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            attendanceRecord.remark!,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: theme
                                                  .colorScheme.onSurfaceVariant,
                                              fontStyle: FontStyle.italic,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // Status Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isPresent
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isPresent ? 'Present' : 'Absent',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: isPresent ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _filters.map((filter) {
            return RadioListTile<String>(
              title: Text(filter),
              value: filter,
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedFilter = 'All';
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAttendanceDetails(
      BuildContext context, StudentAttendanceModel attendance) {
    final theme = Theme.of(context);
    final isPresent = attendance.status == 'present';

    showModalBottomSheet(
      context: context,
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isPresent
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isPresent ? Icons.check_circle : Icons.cancel,
                    color: isPresent ? Colors.green : Colors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPresent ? 'Present' : 'Absent',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isPresent ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, MMMM dd, yyyy')
                            .format(attendance.dateTime),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Details
            if (attendance.remark != null && attendance.remark!.isNotEmpty) ...[
              Text(
                'Remark',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  attendance.remark!,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Time
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Marked at ${DateFormat('hh:mm a').format(attendance.dateTime)}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
