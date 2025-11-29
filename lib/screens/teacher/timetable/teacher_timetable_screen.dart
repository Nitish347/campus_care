import 'package:flutter/material.dart';
import 'package:campus_care/widgets/common/info_card.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';

class TeacherTimetableScreen extends StatelessWidget {
  const TeacherTimetableScreen({super.key});

  // Static UI data
  static final _timetable = [
    {
      'day': 'Monday',
      'period': 1,
      'time': '09:00 - 10:00',
      'subject': 'Mathematics',
      'classId': 'class_001',
      'section': 'A',
      'room': 'Room 101',
    },
    {
      'day': 'Monday',
      'period': 2,
      'time': '10:00 - 11:00',
      'subject': 'Mathematics',
      'classId': 'class_002',
      'section': 'A',
      'room': 'Room 102',
    },
    {
      'day': 'Tuesday',
      'period': 1,
      'time': '09:00 - 10:00',
      'subject': 'Mathematics',
      'classId': 'class_001',
      'section': 'A',
      'room': 'Room 101',
    },
    {
      'day': 'Wednesday',
      'period': 1,
      'time': '09:00 - 10:00',
      'subject': 'Mathematics',
      'classId': 'class_003',
      'section': 'A',
      'room': 'Room 103',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Group by day
    final Map<String, List<Map<String, dynamic>>> timetableByDay = {};
    for (var entry in _timetable) {
      final day = entry['day'] as String;
      if (!timetableByDay.containsKey(day)) {
        timetableByDay[day] = [];
      }
      timetableByDay[day]!.add(entry as Map<String, dynamic>);
    }

    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

    return DefaultTabController(
      length: days.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Timetable'),
          bottom: TabBar(
            isScrollable: true,
            tabs: days.map((day) => Tab(text: day.substring(0, 3))).toList(),
          ),
        ),
        body: TabBarView(
          children: days.map((day) {
            final daySchedule = timetableByDay[day] ?? [];
            
            if (daySchedule.isEmpty) {
              return EmptyState(
                icon: Icons.event_busy,
                title: 'No classes scheduled',
                message: 'No classes scheduled for $day',
              );
            }

            return ResponsivePadding(
              child: ListView.builder(
                itemCount: daySchedule.length,
                itemBuilder: (context, index) {
                  final period = daySchedule[index];
                  
                  return InfoCard(
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'P${period['period']}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              (period['time'] as String).split(' - ')[0],
                              style: theme.textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                      title: Text(
                        period['subject'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('${period['classId']} - ${period['section']}'),
                          Text('Room: ${period['room']}'),
                        ],
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
