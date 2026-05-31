import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/services/api/timetable_api_service.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/common/summary_card.dart';
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
      if (!_tabController.indexIsChanging && _currentTabIndex != _tabController.index) {
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
                SummaryCard(
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE, MMMM dd').format(DateTime.now()),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Class schedule',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
                                (row['period_number'] as num?)?.toInt() ?? index + 1;
                            final subject =
                                (row['subject_id'] ?? row['subject'] ?? 'Subject').toString();
                            final start = (row['start_time'] ?? '').toString();
                            final end = (row['end_time'] ?? '').toString();
                            final room =
                                (row['room_number'] ?? row['room'] ?? 'N/A').toString();

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      theme.colorScheme.primary.withOpacity(0.1),
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
}
