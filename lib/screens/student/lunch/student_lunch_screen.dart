import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/services/api/lunch_api_service.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/common/summary_card.dart';
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
  final AuthController _authController = Get.find<AuthController>();

  bool _isLoading = true;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  List<Map<String, dynamic>> _records = [];

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
      final data = await _lunchApi.getLunch(studentId: student.id);
      final records =
          data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      records.sort((a, b) => _parseUnix(b['date']).compareTo(_parseUnix(a['date'])));
      if (records.isNotEmpty) {
        final latest = _parseUnix(records.first['date']);
        _selectedMonth = DateTime(latest.year, latest.month);
      }
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

      Map<String, dynamic>? record;
      for (final item in _records) {
        final d = _parseUnix(item['date']);
        final itemDate = DateTime(d.year, d.month, d.day);
        if (itemDate == dateOnly) {
          record = item;
          break;
        }
      }

      cells.add({
        'date': date,
        'status': record == null ? null : _status(record['status']),
        'record': record,
      });
    }
    return cells;
  }

  int get _fullMealCount =>
      _records.where((r) => _status(r['status']).toLowerCase() == 'full meal').length;
  int get _halfMealCount =>
      _records.where((r) => _status(r['status']).toLowerCase() == 'half meal').length;
  int get _notTakenCount =>
      _records.where((r) => _status(r['status']).toLowerCase() == 'not taken').length;

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
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
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
          : Column(
              children: [
                SummaryCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _summaryItem(context, 'Full Meal', '$_fullMealCount', Colors.green),
                      _summaryItem(context, 'Half Meal', '$_halfMealCount', Colors.orange),
                      _summaryItem(context, 'Not Taken', '$_notTakenCount', theme.colorScheme.outline),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _previousMonth,
                          icon: const Icon(Icons.chevron_left_rounded),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              DateFormat('MMMM yyyy').format(_selectedMonth),
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _nextMonth,
                          icon: const Icon(Icons.chevron_right_rounded),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ResponsivePadding(
                    child: _records.isEmpty
                        ? const EmptyState(
                            icon: Icons.no_meals,
                            title: 'No lunch records',
                            message: 'No lunch records found for this month.',
                          )
                        : Column(
                            children: [
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 7,
                                  crossAxisSpacing: 6,
                                  mainAxisSpacing: 6,
                                ),
                                itemCount: 7,
                                itemBuilder: (_, index) => Center(
                                  child: Text(
                                    weekDays[index],
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 7,
                                    crossAxisSpacing: 6,
                                    mainAxisSpacing: 6,
                                  ),
                                  itemCount: cells.length,
                                  itemBuilder: (_, index) {
                                    final item = cells[index];
                                    final date = item['date'] as DateTime?;
                                    if (date == null) return const SizedBox.shrink();

                                    final status = item['status'] as String?;
                                    final record = item['record'] as Map<String, dynamic>?;
                                    final isToday =
                                        DateTime(date.year, date.month, date.day) == todayDate;

                                    final color = status == null
                                        ? theme.colorScheme.outline.withValues(alpha: 0.25)
                                        : _statusColor(status, theme);

                                    return InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: record == null
                                          ? null
                                          : () => _showLunchDetails(context, date, status!),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.14),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isToday ? theme.colorScheme.primary : color.withValues(alpha: 0.5),
                                            width: isToday ? 2 : 1.2,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              DateFormat('dd').format(date),
                                              style: theme.textTheme.titleSmall?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: isToday ? theme.colorScheme.primary : null,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            if (status != null)
                                              Icon(
                                                _statusIcon(status),
                                                size: 14,
                                                color: color,
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _summaryItem(BuildContext context, String label, String value, Color color) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: color),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
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
}
