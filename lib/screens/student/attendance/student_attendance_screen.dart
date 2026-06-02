import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/models/student/student.dart';
import 'package:campus_care/models/student/student_attendance_model.dart';
import 'package:campus_care/services/api/attendance_api_service.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/student/student_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  State<StudentAttendanceScreen> createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  final AttendanceApiService _attendanceApi = AttendanceApiService();
  final AuthController _authController = Get.find<AuthController>();
  final DateTime _today = DateTime.now();

  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  List<StudentAttendanceModel> _allAttendance = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    setState(() => _isLoading = true);
    try {
      final Student? currentUser = _authController.currentStudent;
      if (currentUser == null) return;

      final startDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      final endDate = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        0,
        23,
        59,
        59,
        999,
      );
      final attendanceData = await _attendanceApi.getAttendance(
        studentId: currentUser.id,
        startDate: startDate,
        endDate: endDate,
      );
      _allAttendance = attendanceData.whereType<Map>().map((dataRaw) {
        final data = Map<String, dynamic>.from(dataRaw);
        final dateRaw = data['date'];
        DateTime date;
        if (dateRaw is int) {
          final ms = dateRaw > 10000000000 ? dateRaw : dateRaw * 1000;
          date = DateTime.fromMillisecondsSinceEpoch(ms);
        } else if (dateRaw is String) {
          final asInt = int.tryParse(dateRaw);
          if (asInt != null) {
            final ms = asInt > 10000000000 ? asInt : asInt * 1000;
            date = DateTime.fromMillisecondsSinceEpoch(ms);
          } else {
            date = DateTime.tryParse(dateRaw) ?? DateTime.now();
          }
        } else {
          date = DateTime.now();
        }

        return StudentAttendanceModel(
          id: (data['id'] ?? '').toString(),
          dateTime: date,
          status: (data['status'] ?? '').toString().toLowerCase(),
          userId: (data['student_id'] ?? currentUser.id).toString(),
          type: 'daily',
          remark: data['remarks']?.toString(),
          markedBy: (data['marked_by'] ?? '').toString(),
        );
      }).toList()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _calendarDataForMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final firstDayOfWeek = firstDay.weekday % 7;
    final today = DateTime(_today.year, _today.month, _today.day);
    final cells = <Map<String, dynamic>>[];

    for (int i = 0; i < firstDayOfWeek; i++) {
      cells.add({
        'date': null,
        'status': null,
        'attendance': null,
        'isFuture': false
      });
    }

    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(month.year, month.month, day);
      final dateOnly = DateTime(date.year, date.month, date.day);
      final isFuture = dateOnly.isAfter(today);

      StudentAttendanceModel? attendanceRecord;
      for (final att in _allAttendance) {
        final attDate =
            DateTime(att.dateTime.year, att.dateTime.month, att.dateTime.day);
        if (attDate == dateOnly) {
          attendanceRecord = att;
          break;
        }
      }

      cells.add({
        'date': date,
        'status': attendanceRecord?.status,
        'attendance': attendanceRecord,
        'isFuture': isFuture,
      });
    }
    return cells;
  }

  List<Map<String, dynamic>> get _attendance =>
      _calendarDataForMonth(_selectedMonth);

  int get _presentDays =>
      _attendance.where((a) => a['status'] == 'present').length;

  int get _absentDays =>
      _attendance.where((a) => a['status'] == 'absent').length;

  int get _markedDays => _attendance.where((a) => a['status'] != null).length;

  double get _monthlyAttendanceRate {
    final markedDays = _markedDays;
    if (markedDays == 0) return 0;
    return (_presentDays / markedDays) * 100;
  }

  String get _monthlyAttendanceRateText =>
      _monthlyAttendanceRate.toStringAsFixed(2);

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
    _loadAttendance();
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
    _loadAttendance();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final today = DateTime(_today.year, _today.month, _today.day);
    final attendance = _attendance;

    return Scaffold(
      appBar: StudentAppBar(
        title: 'Attendance',
        extraActions: [
          const SizedBox(width: 6),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _loadAttendance,
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
          : RefreshIndicator(
              onRefresh: _loadAttendance,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  ResponsivePadding(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAttendanceHero(theme),
                        const SizedBox(height: 16),
                        _buildMonthSwitcher(theme),
                        const SizedBox(height: 14),
                        _buildLegend(theme),
                        const SizedBox(height: 14),
                        _buildCalendarCard(theme, weekDays, attendance, today),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAttendanceHero(ThemeData theme) {
    final color = _monthlyAttendanceRate >= 75 ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D4ED8), Color(0xFF0891B2)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0891B2).withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMMM').format(_selectedMonth),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Attendance overview',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _markedDays == 0
                          ? 'No attendance has been marked this month.'
                          : '$_markedDays marked day${_markedDays == 1 ? '' : 's'} this month',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.14),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.24)),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _monthlyAttendanceRateText,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: color == Colors.green
                              ? const Color(0xFFBBF7D0)
                              : const Color(0xFFFFEDD5),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Monthly',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.78),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _heroStat(theme, 'Present', '$_presentDays',
                    Icons.check_circle_rounded, const Color(0xFFBBF7D0)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _heroStat(theme, 'Absent', '$_absentDays',
                    Icons.cancel_rounded, const Color(0xFFFECACA)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _heroStat(theme, 'Marked', '$_markedDays',
                    Icons.event_available_rounded, Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSwitcher(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          IconButton.filledTonal(
            onPressed: _previousMonth,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(_selectedMonth),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Tap a marked date for details',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: _nextMonth,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(ThemeData theme) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        _legendPill('Present', Colors.green, Icons.check_circle_rounded, theme),
        _legendPill('Absent', Colors.red, Icons.cancel_rounded, theme),
        _legendPill('No Record', theme.colorScheme.outline,
            Icons.radio_button_unchecked_rounded, theme),
      ],
    );
  }

  Widget _legendPill(
    String text,
    Color color,
    IconData icon,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(
    ThemeData theme,
    List<String> weekDays,
    List<Map<String, dynamic>> attendance,
    DateTime today,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.3,
            ),
            itemCount: 7,
            itemBuilder: (_, index) => Center(
              child: Text(
                weekDays[index],
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 7,
              mainAxisSpacing: 7,
            ),
            itemCount: attendance.length,
            itemBuilder: (_, index) {
              final item = attendance[index];
              final date = item['date'] as DateTime?;
              if (date == null) return const SizedBox.shrink();

              final status = item['status'] as String?;
              final attendanceRecord =
                  item['attendance'] as StudentAttendanceModel?;
              final isPresent = status == 'present';
              final isAbsent = status == 'absent';
              final isToday =
                  DateTime(date.year, date.month, date.day) == today;
              final color = isPresent
                  ? Colors.green
                  : isAbsent
                      ? Colors.red
                      : theme.colorScheme.outline;
              final icon = isPresent
                  ? Icons.check_rounded
                  : isAbsent
                      ? Icons.close_rounded
                      : null;

              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: attendanceRecord == null
                    ? null
                    : () => _showAttendanceDetails(context, attendanceRecord),
                child: Container(
                  decoration: BoxDecoration(
                    color: color.withValues(
                        alpha: isPresent || isAbsent ? 0.13 : 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isToday
                          ? theme.colorScheme.primary
                          : color.withValues(
                              alpha: isPresent || isAbsent ? 0.38 : 0.12),
                      width: isToday ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('d').format(date),
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isToday ? theme.colorScheme.primary : null,
                        ),
                      ),
                      if (icon != null) ...[
                        const SizedBox(height: 2),
                        Icon(icon, color: color, size: 15),
                      ],
                    ],
                  ),
                ),
              );
            },
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
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isPresent ? 'Present' : 'Absent',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: isPresent ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              DateFormat('EEEE, MMM dd, yyyy').format(attendance.dateTime),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if ((attendance.remark ?? '').isNotEmpty) ...[
              const SizedBox(height: 14),
              Text('Remark', style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(attendance.remark!),
            ],
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}
