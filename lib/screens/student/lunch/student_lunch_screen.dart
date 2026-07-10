import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/models/holiday_model.dart';
import 'package:campus_care/services/api/holiday_api_service.dart';
import 'package:campus_care/services/api/lunch_api_service.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/student/student_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StudentLunchScreen extends StatefulWidget {
  const StudentLunchScreen({super.key});

  @override
  State<StudentLunchScreen> createState() => _StudentLunchScreenState();
}

class _StudentLunchScreenState extends State<StudentLunchScreen> {
  final LunchApiService _lunchApi = LunchApiService();
  final HolidayApiService _holidayApi = HolidayApiService();
  final AuthController _authController = Get.find<AuthController>();

  bool _isLoading = true;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  List<Map<String, dynamic>> _records = [];
  List<HolidayModel> _holidays = [];

  @override
  void initState() {
    super.initState();
    _loadLunch();
  }

  Future<void> _loadLunch() async {
    final student = _authController.currentStudent;
    if (student == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      setState(() => _isLoading = true);
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
      final data = await _lunchApi.getLunch(
        studentId: student.id,
        startDate: startDate,
        endDate: endDate,
      );
      _holidays = await _holidayApi.getHolidays(
        startDate: startDate,
        endDate: endDate,
      );
      final records = data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      records.sort(
          (a, b) => _parseUnix(b['date']).compareTo(_parseUnix(a['date'])));
      setState(() => _records = records);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  DateTime _parseUnix(dynamic raw) {
    if (raw is int) {
      final ms = raw > 10000000000 ? raw : raw * 1000;
      return DateTime.fromMillisecondsSinceEpoch(ms);
    }
    if (raw is String) {
      final asInt = int.tryParse(raw);
      if (asInt != null) {
        final ms = asInt > 10000000000 ? asInt : asInt * 1000;
        return DateTime.fromMillisecondsSinceEpoch(ms);
      }
      return DateTime.tryParse(raw) ?? DateTime.now();
    }
    return DateTime.now();
  }

  String _status(dynamic raw) => (raw?.toString() ?? 'Not Taken').trim();

  List<Map<String, dynamic>> get _monthRecords {
    return _records.where((record) {
      final date = _parseUnix(record['date']);
      return date.year == _selectedMonth.year &&
          date.month == _selectedMonth.month &&
          _holidayForDate(DateTime(date.year, date.month, date.day)) == null &&
          DateTime(date.year, date.month, date.day).weekday != DateTime.sunday;
    }).toList();
  }

  HolidayModel? _holidayForDate(DateTime date) {
    for (final holiday in _holidays) {
      if (holiday.isActive && holiday.isSameDate(date)) return holiday;
    }
    return null;
  }

  List<Map<String, dynamic>> _calendarDataForMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final firstDayOfWeek = firstDay.weekday % 7;
    final cells = <Map<String, dynamic>>[];

    for (int i = 0; i < firstDayOfWeek; i++) {
      cells.add({'date': null, 'status': null, 'record': null});
    }

    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(month.year, month.month, day);
      final dateOnly = DateTime(date.year, date.month, date.day);
      final holiday = _holidayForDate(dateOnly);
      final isWeekOff = holiday == null && dateOnly.weekday == DateTime.sunday;

      Map<String, dynamic>? record;
      if (holiday == null && !isWeekOff) {
        for (final item in _records) {
          final d = _parseUnix(item['date']);
          final itemDate = DateTime(d.year, d.month, d.day);
          if (itemDate == dateOnly) {
            record = item;
            break;
          }
        }
      }

      cells.add({
        'date': date,
        'status': record == null ? null : _status(record['status']),
        'record': record,
        'holiday': holiday,
        'isWeekOff': isWeekOff,
      });
    }
    return cells;
  }

  int get _fullMealCount => _monthRecords
      .where((r) => _status(r['status']).toLowerCase() == 'full meal')
      .length;
  int get _halfMealCount => _monthRecords
      .where((r) => _status(r['status']).toLowerCase() == 'half meal')
      .length;
  int get _notTakenCount => _monthRecords
      .where((r) => _status(r['status']).toLowerCase() == 'not taken')
      .length;

  int get _mealMarkedCount => _monthRecords.length;
  int get _holidayCount => _holidays
      .where((h) =>
          h.date.year == _selectedMonth.year &&
          h.date.month == _selectedMonth.month)
      .length;
  int get _weekOffCount => _calendarDataForMonth(_selectedMonth)
      .where((cell) => cell['isWeekOff'] == true)
      .length;

  Color _statusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'full meal':
        return Colors.green;
      case 'half meal':
        return Colors.orange;
      case 'absent':
        return Colors.red;
      case 'not taken':
        return theme.colorScheme.outline;
      default:
        return theme.colorScheme.outline;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'full meal':
        return Icons.restaurant;
      case 'half meal':
        return Icons.lunch_dining;
      case 'absent':
        return Icons.event_busy;
      default:
        return Icons.no_meals;
    }
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
    _loadLunch();
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
    _loadLunch();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final cells = _calendarDataForMonth(_selectedMonth);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    return Scaffold(
      appBar: StudentAppBar(
        title: 'Lunch',
        extraActions: [
          const SizedBox(width: 6),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _loadLunch,
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
              onRefresh: _loadLunch,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  ResponsivePadding(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLunchHero(theme),
                        const SizedBox(height: 16),
                        _buildMonthSwitcher(theme),
                        const SizedBox(height: 14),
                        _buildLegend(theme),
                        const SizedBox(height: 14),
                        _buildCalendarCard(theme, weekDays, cells, todayDate),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLunchHero(ThemeData theme) {
    final primaryStatus = _fullMealCount >= _halfMealCount
        ? 'Full meal'
        : _halfMealCount > 0
            ? 'Half meal'
            : 'No meals';

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
            color: const Color(0xFF0891B2).withValues(alpha: 0.20),
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
                      'Lunch overview',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _mealMarkedCount == 0
                          ? 'No lunch records have been marked this month.'
                          : '$_mealMarkedCount lunch record${_mealMarkedCount == 1 ? '' : 's'} this month',
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.restaurant_rounded,
                        color: Color(0xFFFFEDD5), size: 24),
                    const SizedBox(height: 4),
                    Text(
                      primaryStatus,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _heroStat(theme, 'Full', '$_fullMealCount',
                    Icons.restaurant_rounded, const Color(0xFFBBF7D0)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _heroStat(theme, 'Half', '$_halfMealCount',
                    Icons.lunch_dining_rounded, const Color(0xFFFFEDD5)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _heroStat(theme, 'Not Taken', '$_notTakenCount',
                    Icons.no_meals_rounded, Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _heroStat(
                    theme,
                    'Off Days',
                    '${_holidayCount + _weekOffCount}',
                    Icons.event_busy_rounded,
                    const Color(0xFFBAE6FD)),
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
        _legendPill('Full Meal', Colors.green, Icons.restaurant_rounded, theme),
        _legendPill(
            'Half Meal', Colors.orange, Icons.lunch_dining_rounded, theme),
        _legendPill('Holiday', Colors.blue, Icons.event_busy_rounded, theme),
        _legendPill('Sunday', Colors.purple, Icons.weekend_rounded, theme),
        _legendPill('Not Taken', theme.colorScheme.outline,
            Icons.no_meals_rounded, theme),
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
    List<Map<String, dynamic>> cells,
    DateTime todayDate,
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
            itemCount: cells.length,
            itemBuilder: (_, index) {
              final item = cells[index];
              final date = item['date'] as DateTime?;
              if (date == null) return const SizedBox.shrink();

              final status = item['status'] as String?;
              final record = item['record'] as Map<String, dynamic>?;
              final holiday = item['holiday'] as HolidayModel?;
              final isWeekOff = item['isWeekOff'] == true;
              final isToday =
                  DateTime(date.year, date.month, date.day) == todayDate;
              final color = holiday != null
                  ? Colors.blue
                  : isWeekOff
                      ? Colors.purple
                      : status == null
                          ? theme.colorScheme.outline
                          : _statusColor(status, theme);

              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: holiday != null
                    ? () => _showHolidayDetails(context, holiday)
                    : isWeekOff
                        ? () => _showWeekOffDetails(context, date)
                        : record == null
                            ? null
                            : () => _showLunchDetails(context, date, status!),
                child: Container(
                  decoration: BoxDecoration(
                    color: color.withValues(
                        alpha: status == null && holiday == null && !isWeekOff
                            ? 0.06
                            : 0.13),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isToday
                          ? theme.colorScheme.primary
                          : color.withValues(
                              alpha: status == null &&
                                      holiday == null &&
                                      !isWeekOff
                                  ? 0.12
                                  : 0.38),
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
                      if (holiday != null || isWeekOff || status != null) ...[
                        const SizedBox(height: 2),
                        Icon(
                          holiday != null
                              ? Icons.event_busy_rounded
                              : isWeekOff
                                  ? Icons.weekend_rounded
                                  : _statusIcon(status!),
                          size: 15,
                          color: color,
                        ),
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

  void _showLunchDetails(BuildContext context, DateTime date, String status) {
    final theme = Theme.of(context);
    final color = _statusColor(status, theme);

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
              status,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              DateFormat('EEEE, MMM dd, yyyy').format(date),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showHolidayDetails(BuildContext context, HolidayModel holiday) {
    final theme = Theme.of(context);
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
              holiday.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 6),
            Text(DateFormat('EEEE, MMM dd, yyyy').format(holiday.date)),
            const SizedBox(height: 8),
            Text('Lunch records are not counted on holidays.',
                style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  void _showWeekOffDetails(BuildContext context, DateTime date) {
    final theme = Theme.of(context);
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
              'Sunday Week Off',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 6),
            Text(DateFormat('EEEE, MMM dd, yyyy').format(date)),
            const SizedBox(height: 8),
            Text('Lunch records are not counted on Sundays.',
                style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
