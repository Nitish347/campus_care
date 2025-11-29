import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:intl/intl.dart';

class StudentTimetableScreen extends StatefulWidget {
  const StudentTimetableScreen({super.key});

  @override
  State<StudentTimetableScreen> createState() => _StudentTimetableScreenState();
}

class _StudentTimetableScreenState extends State<StudentTimetableScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Days of the week
  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  // Static timetable data with enhanced structure
  final Map<String, List<Map<String, dynamic>>> _timetable = {
    'Monday': [
      {
        'time': '9:00 AM - 10:00 AM',
        'subject': 'Mathematics',
        'teacher': 'Mr. Brown',
        'room': 'Room 101',
        'type': 'lecture',
      },
      {
        'time': '10:00 AM - 11:00 AM',
        'subject': 'Science',
        'teacher': 'Ms. Johnson',
        'room': 'Lab 2',
        'type': 'lab',
      },
      {
        'time': '11:00 AM - 12:00 PM',
        'subject': 'English',
        'teacher': 'Ms. Smith',
        'room': 'Room 203',
        'type': 'lecture',
      },
      {
        'time': '12:00 PM - 1:00 PM',
        'subject': 'Lunch Break',
        'teacher': '',
        'room': 'Cafeteria',
        'type': 'break',
      },
      {
        'time': '1:00 PM - 2:00 PM',
        'subject': 'History',
        'teacher': 'Mr. Davis',
        'room': 'Room 105',
        'type': 'lecture',
      },
      {
        'time': '2:00 PM - 3:00 PM',
        'subject': 'Physical Education',
        'teacher': 'Mr. Wilson',
        'room': 'Sports Ground',
        'type': 'activity',
      },
    ],
    'Tuesday': [
      {
        'time': '9:00 AM - 10:00 AM',
        'subject': 'Science',
        'teacher': 'Ms. Johnson',
        'room': 'Lab 2',
        'type': 'lab',
      },
      {
        'time': '10:00 AM - 11:00 AM',
        'subject': 'Mathematics',
        'teacher': 'Mr. Brown',
        'room': 'Room 101',
        'type': 'lecture',
      },
      {
        'time': '11:00 AM - 12:00 PM',
        'subject': 'Geography',
        'teacher': 'Ms. Anderson',
        'room': 'Room 204',
        'type': 'lecture',
      },
      {
        'time': '12:00 PM - 1:00 PM',
        'subject': 'Lunch Break',
        'teacher': '',
        'room': 'Cafeteria',
        'type': 'break',
      },
      {
        'time': '1:00 PM - 2:00 PM',
        'subject': 'English',
        'teacher': 'Ms. Smith',
        'room': 'Room 203',
        'type': 'lecture',
      },
      {
        'time': '2:00 PM - 3:00 PM',
        'subject': 'Art',
        'teacher': 'Mr. Wilson',
        'room': 'Art Studio',
        'type': 'activity',
      },
    ],
    'Wednesday': [
      {
        'time': '9:00 AM - 10:00 AM',
        'subject': 'English',
        'teacher': 'Ms. Smith',
        'room': 'Room 203',
        'type': 'lecture',
      },
      {
        'time': '10:00 AM - 11:00 AM',
        'subject': 'Mathematics',
        'teacher': 'Mr. Brown',
        'room': 'Room 101',
        'type': 'lecture',
      },
      {
        'time': '11:00 AM - 12:00 PM',
        'subject': 'Science',
        'teacher': 'Ms. Johnson',
        'room': 'Lab 2',
        'type': 'lab',
      },
      {
        'time': '12:00 PM - 1:00 PM',
        'subject': 'Lunch Break',
        'teacher': '',
        'room': 'Cafeteria',
        'type': 'break',
      },
      {
        'time': '1:00 PM - 2:00 PM',
        'subject': 'History',
        'teacher': 'Mr. Davis',
        'room': 'Room 105',
        'type': 'lecture',
      },
      {
        'time': '2:00 PM - 3:00 PM',
        'subject': 'Music',
        'teacher': 'Ms. Taylor',
        'room': 'Music Room',
        'type': 'activity',
      },
    ],
    'Thursday': [
      {
        'time': '9:00 AM - 10:00 AM',
        'subject': 'Mathematics',
        'teacher': 'Mr. Brown',
        'room': 'Room 101',
        'type': 'lecture',
      },
      {
        'time': '10:00 AM - 11:00 AM',
        'subject': 'Computer Science',
        'teacher': 'Mr. Lee',
        'room': 'Computer Lab',
        'type': 'lab',
      },
      {
        'time': '11:00 AM - 12:00 PM',
        'subject': 'English',
        'teacher': 'Ms. Smith',
        'room': 'Room 203',
        'type': 'lecture',
      },
      {
        'time': '12:00 PM - 1:00 PM',
        'subject': 'Lunch Break',
        'teacher': '',
        'room': 'Cafeteria',
        'type': 'break',
      },
      {
        'time': '1:00 PM - 2:00 PM',
        'subject': 'Science',
        'teacher': 'Ms. Johnson',
        'room': 'Lab 2',
        'type': 'lab',
      },
      {
        'time': '2:00 PM - 3:00 PM',
        'subject': 'Geography',
        'teacher': 'Ms. Anderson',
        'room': 'Room 204',
        'type': 'lecture',
      },
    ],
    'Friday': [
      {
        'time': '9:00 AM - 10:00 AM',
        'subject': 'Science',
        'teacher': 'Ms. Johnson',
        'room': 'Lab 2',
        'type': 'lab',
      },
      {
        'time': '10:00 AM - 11:00 AM',
        'subject': 'English',
        'teacher': 'Ms. Smith',
        'room': 'Room 203',
        'type': 'lecture',
      },
      {
        'time': '11:00 AM - 12:00 PM',
        'subject': 'Mathematics',
        'teacher': 'Mr. Brown',
        'room': 'Room 101',
        'type': 'lecture',
      },
      {
        'time': '12:00 PM - 1:00 PM',
        'subject': 'Lunch Break',
        'teacher': '',
        'room': 'Cafeteria',
        'type': 'break',
      },
      {
        'time': '1:00 PM - 2:00 PM',
        'subject': 'Library Period',
        'teacher': 'Ms. White',
        'room': 'Library',
        'type': 'activity',
      },
      {
        'time': '2:00 PM - 3:00 PM',
        'subject': 'Sports',
        'teacher': 'Mr. Wilson',
        'room': 'Sports Ground',
        'type': 'activity',
      },
    ],
    'Saturday': [
      {
        'time': '9:00 AM - 10:00 AM',
        'subject': 'Extra Classes',
        'teacher': 'Various',
        'room': 'As Assigned',
        'type': 'lecture',
      },
      {
        'time': '10:00 AM - 11:00 AM',
        'subject': 'Club Activities',
        'teacher': 'Club Mentors',
        'room': 'Various',
        'type': 'activity',
      },
      {
        'time': '11:00 AM - 12:00 PM',
        'subject': 'Sports Practice',
        'teacher': 'Mr. Wilson',
        'room': 'Sports Ground',
        'type': 'activity',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    // Set initial tab to current day
    final currentDay = DateFormat('EEEE').format(DateTime.now());
    final initialIndex = _days.indexOf(currentDay);
    _tabController = TabController(
      length: _days.length,
      vsync: this,
      initialIndex: initialIndex >= 0 ? initialIndex : 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getSubjectColor(String type, ThemeData theme) {
    switch (type) {
      case 'lecture':
        return theme.colorScheme.primary;
      case 'lab':
        return theme.colorScheme.secondary;
      case 'break':
        return Colors.orange;
      case 'activity':
        return Colors.purple;
      default:
        return theme.colorScheme.primary;
    }
  }

  IconData _getSubjectIcon(String type) {
    switch (type) {
      case 'lecture':
        return Icons.school_outlined;
      case 'lab':
        return Icons.science_outlined;
      case 'break':
        return Icons.restaurant_outlined;
      case 'activity':
        return Icons.sports_outlined;
      default:
        return Icons.book_outlined;
    }
  }

  bool _isCurrentDay(String day) {
    final currentDay = DateFormat('EEEE').format(DateTime.now());
    return currentDay == day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Timetable'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Get.toNamed(AppRoutes.studentNotifications),
            tooltip: 'Notifications',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorWeight: 3,
          tabs: _days.map((day) {
            final isToday = _isCurrentDay(day);
            return Tab(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: isToday
                    ? BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      )
                    : null,
                child: Text(
                  day.substring(0, 3),
                  style: TextStyle(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      body: Column(
        children: [
          // Current day indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.secondaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE, MMMM dd').format(DateTime.now()),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      'Week Schedule',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer
                            .withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Timetable content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _days.map((day) {
                final periods = _timetable[day] ?? [];

                if (periods.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No classes scheduled',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ResponsivePadding(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: periods.length,
                    itemBuilder: (context, index) {
                      final period = periods[index];
                      final subject = period['subject'] as String;
                      final teacher = period['teacher'] as String;
                      final room = period['room'] as String;
                      final time = period['time'] as String;
                      final type = period['type'] as String;

                      final color = _getSubjectColor(type, theme);
                      final icon = _getSubjectIcon(type);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
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
                            onTap: type != 'break'
                                ? () {
                                    // Show period details
                                    _showPeriodDetails(context, period);
                                  }
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Time indicator
                                  Container(
                                    width: 4,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Icon
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      icon,
                                      color: color,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          subject,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        if (teacher.isNotEmpty)
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.person_outline,
                                                size: 16,
                                                color: theme.colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                teacher,
                                                style: theme
                                                    .textTheme.bodyMedium
                                                    ?.copyWith(
                                                  color: theme.colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              size: 16,
                                              color: theme
                                                  .colorScheme.onSurfaceVariant,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              room,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: theme.colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Time
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          time.split(' - ')[0],
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                            color: color,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        time.split(' - ')[1],
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
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
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showPeriodDetails(BuildContext context, Map<String, dynamic> period) {
    final theme = Theme.of(context);
    final type = period['type'] as String;
    final color = _getSubjectColor(type, theme);

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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getSubjectIcon(type),
                    color: color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        period['subject'] as String,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        period['time'] as String,
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
            _buildDetailRow(
              context,
              Icons.person_outline,
              'Teacher',
              period['teacher'] as String,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              Icons.location_on_outlined,
              'Location',
              period['room'] as String,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              Icons.category_outlined,
              'Type',
              type.toUpperCase(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
