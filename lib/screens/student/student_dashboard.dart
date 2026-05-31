import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/services/api/attendance_api_service.dart';
import 'package:campus_care/services/api/exam_api_service.dart';
import 'package:campus_care/services/api/homework_api_service.dart';
import 'package:campus_care/services/api/lunch_api_service.dart';
import 'package:campus_care/services/api/notice_api_service.dart';
import 'package:campus_care/services/api/transport_api_service.dart';
import 'package:campus_care/widgets/cards/dashboard_card.dart';
import 'package:campus_care/widgets/cards/stat_card.dart';
import 'package:campus_care/widgets/common/info_card.dart';
import 'package:campus_care/widgets/common/section_header.dart';
import 'package:campus_care/widgets/responsive/responsive_grid.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/student/student_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final AuthController _authController = Get.find<AuthController>();
  final HomeworkApiService _homeworkApi = HomeworkApiService();
  final AttendanceApiService _attendanceApi = AttendanceApiService();
  final NoticeApiService _noticeApi = NoticeApiService();
  final ExamApiService _examApi = ExamApiService();
  final LunchApiService _lunchApi = LunchApiService();
  final TransportApiService _transportApi = TransportApiService();

  bool _isLoading = true;
  int _activeHomework = 0;
  int _attendancePercentage = 0;
  String _latestLunchStatus = 'N/A';
  String _transportRouteSummary = 'Not assigned';
  List<Map<String, dynamic>> _upcomingExams = [];
  List<Map<String, dynamic>> _notices = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  DateTime _parseDate(dynamic raw) {
    if (raw is int) {
      final ms = raw > 10000000000 ? raw : raw * 1000;
      return DateTime.fromMillisecondsSinceEpoch(ms);
    }
    if (raw is String) {
      final parsedInt = int.tryParse(raw);
      if (parsedInt != null) {
        final ms = parsedInt > 10000000000 ? parsedInt : parsedInt * 1000;
        return DateTime.fromMillisecondsSinceEpoch(ms);
      }
      return DateTime.tryParse(raw) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Future<void> _loadDashboard() async {
    final student = _authController.currentStudent;
    if (student == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      setState(() => _isLoading = true);
      final homeworkFuture = _homeworkApi.getHomework(
        classId: student.class_,
        section: student.section,
      );
      final attendanceFuture = _attendanceApi.getAttendance(studentId: student.id);
      final noticeFuture = _noticeApi.getNotices();
      final examFuture =
          _examApi.getExams(classId: student.class_, section: student.section);
      final lunchFuture = _lunchApi.getLunch(studentId: student.id);
      final transportRouteFuture = _transportApi.getRoutes(isActive: true);
      final transportAssignmentFuture = _transportApi.getAssignments(status: 'active');

      final results = await Future.wait([
        homeworkFuture,
        attendanceFuture,
        noticeFuture,
        examFuture,
        lunchFuture,
        transportRouteFuture,
        transportAssignmentFuture,
      ]);

      final homework = results[0].whereType<Map<String, dynamic>>().toList();
      final attendance = results[1].whereType<Map<String, dynamic>>().toList();
      final notices = results[2].whereType<Map<String, dynamic>>().toList();
      final exams = results[3].whereType<Map<String, dynamic>>().toList();
      final lunchRecords = results[4].whereType<Map<String, dynamic>>().toList();
      final transportRoutes = results[5].whereType<Map<String, dynamic>>().toList();
      final transportAssignments = results[6].whereType<Map<String, dynamic>>().toList();

      final now = DateTime.now();
      final activeHomework = homework.where((item) {
        final due = _parseDate(item['due_date'] ?? item['dueDate']);
        return !due.isBefore(now);
      }).length;
      final present = attendance.where((a) {
        final status = (a['status'] ?? '').toString().toLowerCase();
        return status == 'present';
      }).length;
      final attendanceRate =
          attendance.isEmpty ? 0 : ((present / attendance.length) * 100).round();

      notices.sort((a, b) => _parseDate(b['publish_date']).compareTo(_parseDate(a['publish_date'])));

      final upcomingExams = exams.where((exam) {
        final examDate = _parseDate(exam['exam_date'] ?? exam['examDate']);
        return examDate.isAfter(now);
      }).toList()
        ..sort((a, b) => _parseDate(a['exam_date']).compareTo(_parseDate(b['exam_date'])));

      lunchRecords.sort((a, b) => _parseDate(b['date']).compareTo(_parseDate(a['date'])));
      final latestLunch = lunchRecords.isNotEmpty
          ? (lunchRecords.first['status']?.toString() ?? 'N/A')
          : 'N/A';

      final studentRouteId = student.routeId;
      Map<dynamic, dynamic>? matchedRoute;
      if (studentRouteId != null && studentRouteId.isNotEmpty) {
        for (final route in transportRoutes) {
          if (route['id']?.toString() == studentRouteId) {
            matchedRoute = route;
            break;
          }
        }
      }

      String transportSummary = 'Not assigned';
      if (matchedRoute != null) {
        final routeNumber = matchedRoute['route_number']?.toString() ?? '';
        final routeName = matchedRoute['route_name']?.toString() ?? '';
        transportSummary = '$routeNumber ${routeName.trim()}'.trim();
      } else if (transportAssignments.isNotEmpty) {
        final first = transportAssignments.first;
        final routeNumber = first['route_number']?.toString() ?? '';
        final routeName = first['route_name']?.toString() ?? '';
        transportSummary = '$routeNumber ${routeName.trim()}'.trim();
      }

      if (!mounted) return;
      setState(() {
        _activeHomework = activeHomework;
        _attendancePercentage = attendanceRate;
        _latestLunchStatus = latestLunch;
        _transportRouteSummary = transportSummary.isEmpty ? 'Assigned' : transportSummary;
        _upcomingExams = upcomingExams.cast<Map<String, dynamic>>();
        _notices = notices.cast<Map<String, dynamic>>();
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: StudentAppBar(
        title: 'School Stream',
        showBackButton: false,
        showRightActions: true,
        extraActions: [
          const SizedBox(width: 6),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _loadDashboard,
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
          : SingleChildScrollView(
              child: ResponsivePadding(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => Text(
                        'Welcome back, ${_authController.currentStudent?.fullName ?? 'Student'}!',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Here's your latest school overview",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const SectionHeader(title: 'Quick Stats'),
                    const SizedBox(height: 12),
                    ResponsiveGrid(
                      childAspectRatio: 1.1,
                      children: [
                        StatCard(
                          icon: Icons.assignment_outlined,
                          title: 'Active Homework',
                          value: '$_activeHomework',
                          color: theme.colorScheme.primary,
                        ),
                        StatCard(
                          icon: Icons.check_circle_outline,
                          title: 'Attendance',
                          value: '$_attendancePercentage%',
                          color: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const SectionHeader(title: 'Quick Access'),
                    const SizedBox(height: 12),
                    ResponsiveGrid(
                      mobileColumns: 2,
                      tabletColumns: 3,
                      desktopColumns: 4,
                      childAspectRatio: isMobile ? 1.0 : 1.08,
                      children: [
                        DashboardCard(
                          icon: Icons.assignment_outlined,
                          title: 'Homework',
                          subtitle: '$_activeHomework active',
                          onTap: () => Get.toNamed(AppRoutes.studentHomework),
                          iconColor: theme.colorScheme.primary,
                        ),
                        DashboardCard(
                          icon: Icons.calendar_today_outlined,
                          title: 'Attendance',
                          subtitle: '$_attendancePercentage% present',
                          onTap: () => Get.toNamed(AppRoutes.studentAttendance),
                          iconColor: theme.colorScheme.secondary,
                        ),
                        DashboardCard(
                          icon: Icons.restaurant,
                          title: 'Lunch',
                          subtitle: _latestLunchStatus,
                          onTap: () => Get.toNamed(AppRoutes.studentLunch),
                          iconColor: theme.colorScheme.tertiary,
                        ),
                        DashboardCard(
                          icon: Icons.directions_bus_outlined,
                          title: 'Transport',
                          subtitle: _transportRouteSummary,
                          onTap: () => Get.toNamed(AppRoutes.studentTransport),
                          iconColor: theme.colorScheme.primary,
                        ),
                        DashboardCard(
                          icon: Icons.assignment_outlined,
                          title: 'Exam Timetable',
                          subtitle: '${_upcomingExams.length} upcoming',
                          onTap: () => Get.toNamed(AppRoutes.studentExamTimetable),
                          iconColor: theme.colorScheme.secondary,
                        ),
                        DashboardCard(
                          icon: Icons.assessment_outlined,
                          title: 'Results',
                          subtitle: 'View marks',
                          onTap: () => Get.toNamed(AppRoutes.studentResults),
                          iconColor: theme.colorScheme.tertiary,
                        ),
                        DashboardCard(
                          icon: Icons.schedule_outlined,
                          title: 'Class Timetable',
                          subtitle: 'View schedule',
                          onTap: () => Get.toNamed(AppRoutes.studentTimetable),
                          iconColor: theme.colorScheme.secondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const SectionHeader(title: 'Upcoming Exams'),
                    const SizedBox(height: 12),
                    if (_upcomingExams.isEmpty)
                      const InfoCard(
                        child: ListTile(
                          title: Text('No upcoming exams'),
                          subtitle: Text('You are all set for now'),
                        ),
                      )
                    else
                      ..._upcomingExams.take(3).map((exam) {
                        final examDate = _parseDate(exam['exam_date'] ?? exam['examDate']);
                        return InfoCard(
                          child: ListTile(
                            leading: const Icon(Icons.event_note),
                            title: Text(exam['subject']?.toString() ?? 'Exam'),
                            subtitle: Text(DateFormat('MMM dd, yyyy - hh:mm a').format(examDate)),
                            trailing: Text(
                              exam['type']?.toString().toUpperCase() ?? '',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 24),
                    const SectionHeader(title: 'Recent Notices'),
                    const SizedBox(height: 12),
                    if (_notices.isEmpty)
                      const InfoCard(
                        child: ListTile(
                          title: Text('No notices'),
                          subtitle: Text('No active notices available'),
                        ),
                      )
                    else
                      ..._notices.take(3).map((notice) {
                        final publishDate = _parseDate(notice['publish_date']);
                        final priority = (notice['priority'] ?? 'normal').toString();
                        final color = priority == 'high'
                            ? Colors.red
                            : priority == 'normal'
                                ? Colors.orange
                                : Colors.blue;
                        return InfoCard(
                          child: ListTile(
                            leading: Container(
                              width: 4,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            title: Text(notice['title']?.toString() ?? 'Notice'),
                            subtitle:
                                Text(DateFormat('MMM dd, yyyy').format(publishDate)),
                          ),
                        );
                      }),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
