import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/services/api/timetable_api_service.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/student/student_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StudentTimetableScreen extends StatefulWidget {
  const StudentTimetableScreen({super.key});

  @override
  State<StudentTimetableScreen> createState() => _StudentTimetableScreenState();
}

class _StudentTimetableScreenState extends State<StudentTimetableScreen>
    with SingleTickerProviderStateMixin {
  final TimetableApiService _timetableApi = TimetableApiService();
  final AuthController _authController = Get.find<AuthController>();

  final List<String> _days = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  late TabController _tabController;
  int _currentTabIndex = 0;
  bool _isLoading = true;
  final Map<String, List<Map<String, dynamic>>> _timetableByDay = {};

  @override
  void initState() {
    super.initState();
    final currentDay = DateFormat('EEEE').format(DateTime.now());
    final initialIndex = _days.indexOf(currentDay);
    _tabController = TabController(
      length: _days.length,
      vsync: this,
      initialIndex: initialIndex >= 0 ? initialIndex : 0,
    );
    _currentTabIndex = _tabController.index;
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging &&
          _currentTabIndex != _tabController.index) {
        setState(() => _currentTabIndex = _tabController.index);
      }
    });
    _loadTimetable();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTimetable() async {
    final student = _authController.currentStudent;
    if (student == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      setState(() => _isLoading = true);
      final data = await _timetableApi.getTimetables(
        classId: student.class_,
        section: student.section,
      );

      final grouped = <String, List<Map<String, dynamic>>>{};
      for (final day in _days) {
        grouped[day] = [];
      }

      for (final item in data.whereType<Map>()) {
        final row = Map<String, dynamic>.from(item);
        final day = (row['day_of_week'] ?? row['dayOfWeek'] ?? '').toString();
        if (!grouped.containsKey(day)) continue;
        grouped[day]!.add(row);
      }

      for (final day in _days) {
        grouped[day]!.sort((a, b) {
          final aPeriod = (a['period_number'] as num?)?.toInt() ?? 0;
          final bPeriod = (b['period_number'] as num?)?.toInt() ?? 0;
          return aPeriod.compareTo(bPeriod);
        });
      }

      if (!mounted) return;
      setState(() {
        _timetableByDay
          ..clear()
          ..addAll(grouped);
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isToday(String day) => DateFormat('EEEE').format(DateTime.now()) == day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: StudentAppBar(
        title: 'My Timetable',
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: List.generate(_days.length, (index) {
                  final day = _days[index];
                  return Expanded(
                    child: _buildAnimatedDayTab(
                      label: day.substring(0, 3),
                      tabIndex: index,
                      isToday: _isToday(day),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
        extraActions: [
          const SizedBox(width: 6),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _loadTimetable,
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
                _buildTimetableSummaryHero(context),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: _days.map((day) {
                      final entries = _timetableByDay[day] ?? [];
                      if (entries.isEmpty) {
                        return const EmptyState(
                          icon: Icons.event_busy,
                          title: 'No classes scheduled',
                          message: 'No timetable entries for this day',
                        );
                      }

                      return ResponsivePadding(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            final row = entries[index];
                            final periodNumber =
                                (row['period_number'] as num?)?.toInt() ??
                                    index + 1;
                            final subject = (row['subject_id'] ??
                                    row['subject'] ??
                                    'Subject')
                                .toString();
                            final start = (row['start_time'] ?? '').toString();
                            final end = (row['end_time'] ?? '').toString();
                            final room =
                                (row['room_number'] ?? row['room'] ?? 'N/A')
                                    .toString();

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: theme.colorScheme.primary
                                      .withValues(alpha: 0.1),
                                  child: Text('P$periodNumber'),
                                ),
                                title: Text(subject),
                                subtitle: Text(
                                  '$start - $end\nRoom: $room',
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAnimatedDayTab({
    required String label,
    required int tabIndex,
    required bool isToday,
  }) {
    final selected = _currentTabIndex == tabIndex;
    final accent = isToday ? Colors.orange : Colors.blue;

    return GestureDetector(
      onTap: () {
        _tabController.animateTo(tabIndex);
        setState(() => _currentTabIndex = tabIndex);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          color: selected ? Colors.white : Colors.transparent,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            style: TextStyle(
              color: selected ? accent : Colors.white,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              fontSize: 13,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }

  Widget _buildTimetableSummaryHero(BuildContext context) {
    final theme = Theme.of(context);
    final selectedDay = _days[_currentTabIndex];
    final selectedEntries = _timetableByDay[selectedDay] ?? [];
    final totalWeeklyClasses = _timetableByDay.values.fold<int>(
      0,
      (total, entries) => total + entries.length,
    );
    final firstClass =
        selectedEntries.isNotEmpty ? selectedEntries.first : null;
    final startTime = (firstClass?['start_time'] ?? 'N/A').toString();
    final room =
        (firstClass?['room_number'] ?? firstClass?['room'] ?? 'N/A').toString();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF0891B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0891B2).withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedDay,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('MMMM dd, yyyy').format(DateTime.now()),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.16),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.24)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${selectedEntries.length}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Classes',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.76),
                        fontWeight: FontWeight.w700,
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
                child: _summaryHeroTile(
                  context,
                  icon: Icons.access_time_outlined,
                  label: 'Starts',
                  value: startTime,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryHeroTile(
                  context,
                  icon: Icons.meeting_room_outlined,
                  label: 'Room',
                  value: room,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryHeroTile(
                  context,
                  icon: Icons.view_week_outlined,
                  label: 'Weekly',
                  value: '$totalWeeklyClasses',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryHeroTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
