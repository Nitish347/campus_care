import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/controllers/notice_controller.dart';
import 'package:campus_care/controllers/teacher_timetable_controller.dart';
import 'package:campus_care/controllers/theme_controller.dart';
import 'package:campus_care/core/constants/admin_module_permissions.dart';
import 'package:campus_care/core/constants/app_constants.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/models/notice_model.dart';
import 'package:campus_care/models/timetable_model.dart';
import 'package:campus_care/widgets/cards/dashboard_card.dart';
import 'package:campus_care/widgets/common/section_header.dart';
import 'package:campus_care/widgets/common/file_display_widget.dart';
import 'package:campus_care/widgets/responsive/responsive_grid.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/admin/admin_sidebar.dart';

import '../../controllers/admin_controller.dart';

class AdminDashboard extends StatefulWidget {
  final bool isTeacherDashboard;

  const AdminDashboard({
    super.key,
    this.isTeacherDashboard = false,
  });

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late final AdminController _adminController;
  TeacherTimetableController? _teacherTimetableController;
  NoticeController? _noticeController;

  @override
  void initState() {
    super.initState();
    _adminController = Get.find<AdminController>();

    if (widget.isTeacherDashboard) {
      _teacherTimetableController = Get.isRegistered<TeacherTimetableController>()
          ? Get.find<TeacherTimetableController>()
          : Get.put(TeacherTimetableController());
      _noticeController = Get.isRegistered<NoticeController>()
          ? Get.find<NoticeController>()
          : Get.put(NoticeController());

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _teacherTimetableController?.fetchTeacherTimetable();
        _noticeController?.loadNotices();
      });
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _adminController.fetchDashboardStats();
    });
  }

  bool _hasModuleAccess(String moduleKey) {
    if (widget.isTeacherDashboard) {
      return true;
    }
    final admin = Get.find<AuthController>().currentAdmin;
    return admin?.hasModuleAccess(moduleKey) ?? true;
  }

  String _resolveWelcomeName() {
    final authController = Get.find<AuthController>();
    return authController.currentTeacher?.fullName ??
        authController.currentAdmin?.fullName ??
        'Admin';
  }

  List<SidebarSection> _buildSidebarSections() {
    final sections = <SidebarSection>[
      SidebarSection(
        title: 'Main',
        items: [
          SidebarItem(
            icon: Icons.home_rounded,
            title: 'Home',
            isSelected: true,
            onTap: () {},
          ),
        ],
      ),
    ];

    if (_hasModuleAccess(AdminModulePermissionKeys.studentManagement)) {
      final studentItems = <SidebarItem>[
        SidebarItem(
          icon: Icons.people_rounded,
          title: 'Student List',
          onTap: () => Get.toNamed(AppRoutes.studentList),
        ),
        if (!widget.isTeacherDashboard)
          SidebarItem(
            icon: Icons.person_add_rounded,
            title: 'Add Student',
            onTap: () => Get.toNamed(AppRoutes.addStudent),
          ),
      ];

      sections.add(
        SidebarSection(
          title: 'Student Management',
          items: studentItems,
        ),
      );
    }

    if (!widget.isTeacherDashboard) {
      final staffItems = <SidebarItem>[
        if (_hasModuleAccess(AdminModulePermissionKeys.teacherManagement))
          SidebarItem(
            icon: Icons.badge_rounded,
            title: 'Teacher List',
            onTap: () => Get.toNamed(AppRoutes.teacherList),
          ),
        if (_hasModuleAccess(AdminModulePermissionKeys.teacherManagement))
          SidebarItem(
            icon: Icons.person_add_alt_1_rounded,
            title: 'Add Teacher',
            onTap: () => Get.toNamed(AppRoutes.addTeacher),
          ),
        SidebarItem(
          icon: Icons.admin_panel_settings_rounded,
          title: 'Admin List',
          onTap: () => Get.toNamed(AppRoutes.adminList),
        ),
      ];
      if (staffItems.isNotEmpty) {
        sections
            .add(SidebarSection(title: 'Staff Management', items: staffItems));
      }
    }

    final academicItems = <SidebarItem>[
      if (_hasModuleAccess(AdminModulePermissionKeys.classManagement))
        SidebarItem(
          icon: Icons.class_rounded,
          title: 'Classes',
          onTap: () => Get.toNamed(AppRoutes.classManagement),
        ),
      if (_hasModuleAccess(AdminModulePermissionKeys.subjectManagement))
        SidebarItem(
          icon: Icons.book_rounded,
          title: 'Subjects',
          onTap: () => Get.toNamed(AppRoutes.subjectManagement),
        ),
      if (_hasModuleAccess(AdminModulePermissionKeys.timetable))
        SidebarItem(
          icon: Icons.schedule_rounded,
          title: 'Timetable',
          onTap: () => Get.toNamed(AppRoutes.timetable),
        ),
      if (_hasModuleAccess(AdminModulePermissionKeys.attendance))
        SidebarItem(
          icon: Icons.how_to_reg_rounded,
          title: 'Attendance',
          onTap: () => Get.toNamed(AppRoutes.adminAttendance),
        ),
      if (_hasModuleAccess(AdminModulePermissionKeys.lunchManagement))
        SidebarItem(
          icon: Icons.restaurant_menu_rounded,
          title: 'Lunch Management',
          onTap: () => Get.toNamed(AppRoutes.adminLunchManagement),
        ),
      if (_hasModuleAccess(AdminModulePermissionKeys.transportManagement))
        SidebarItem(
          icon: Icons.directions_bus_rounded,
          title: 'Transport',
          onTap: () => Get.toNamed(AppRoutes.adminTransportManagement),
        ),
      if (_hasModuleAccess(AdminModulePermissionKeys.homeworkManagement))
        SidebarItem(
          icon: Icons.assignment_rounded,
          title: 'Homework',
          onTap: () => Get.toNamed(AppRoutes.adminHomework),
        ),
      if (_hasModuleAccess(AdminModulePermissionKeys.examinations))
        SidebarItem(
          icon: Icons.assignment_rounded,
          title: 'Examinations',
          onTap: () => Get.toNamed(AppRoutes.adminExaminations),
        ),
      if (_hasModuleAccess(AdminModulePermissionKeys.examResults))
        SidebarItem(
          icon: Icons.fact_check_rounded,
          title: 'Exam Results & Marks',
          onTap: () => Get.toNamed(AppRoutes.adminExamResults),
        ),
    ];
    if (academicItems.isNotEmpty) {
      sections.add(SidebarSection(title: 'Academic', items: academicItems));
    }

    if (_hasModuleAccess(AdminModulePermissionKeys.noticesEvents)) {
      sections.add(
        SidebarSection(
          title: 'Communication',
          items: [
            SidebarItem(
              icon: Icons.campaign_rounded,
              title: 'Notices & Events',
              onTap: () => Get.toNamed(AppRoutes.noticeManagement),
            ),
          ],
        ),
      );
    }

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1200;
    final isTablet = size.width > 800 && size.width <= 1200;
    final showDrawerButton = !isDesktop;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      drawer: showDrawerButton
          ? AdminDrawer(sections: _buildSidebarSections())
          : null,
      body: Row(
        children: [
          if (isDesktop) AdminSidebar(sections: _buildSidebarSections()),
          Expanded(
            child: _buildMainContent(
              context,
              isDesktop,
              isTablet,
              showDrawerButton,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, bool isDesktop, bool isTablet,
      bool showDrawerButton) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final adminName = _resolveWelcomeName();
            return _WelcomeBanner(
              adminName: adminName,
              isDark: isDark,
              showDrawerButton: showDrawerButton,
              isTeacherDashboard: widget.isTeacherDashboard,
            );
          }),
          ResponsivePadding(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 28),
                if (widget.isTeacherDashboard)
                  _buildTeacherTodaySection(context)
                else
                  _buildAnalyticsSection(context),
                const SizedBox(height: 32),
                SectionHeader(
                  title: 'Quick Access',
                  subtitle: 'Navigate to key management areas',
                ),
                const SizedBox(height: 16),
                ResponsiveGrid(
                  childAspectRatio: 1.0,
                  children: [
                    if (_hasModuleAccess(
                        AdminModulePermissionKeys.studentManagement))
                      DashboardCard(
                        icon: Icons.people_rounded,
                        title: 'Student Management',
                        subtitle: 'Manage students',
                        onTap: () => Get.toNamed(AppRoutes.studentList),
                        iconColor: const Color(0xFF2563EB),
                      ),
                    if (_hasModuleAccess(
                            AdminModulePermissionKeys.teacherManagement) &&
                        !widget.isTeacherDashboard)
                      DashboardCard(
                        icon: Icons.badge_rounded,
                        title: 'Teacher Management',
                        subtitle: 'Manage teachers',
                        onTap: () => Get.toNamed(AppRoutes.teacherList),
                        iconColor: const Color(0xFF059669),
                      ),
                    if (_hasModuleAccess(
                            AdminModulePermissionKeys.classManagement) ||
                        _hasModuleAccess(
                            AdminModulePermissionKeys.subjectManagement))
                      DashboardCard(
                        icon: Icons.class_rounded,
                        title: 'Classes & Subjects',
                        subtitle: 'Manage classes',
                        onTap: () => Get.toNamed(AppRoutes.classManagement),
                        iconColor: const Color(0xFF7C3AED),
                      ),
                    if (_hasModuleAccess(AdminModulePermissionKeys.timetable))
                      DashboardCard(
                        icon: Icons.schedule_rounded,
                        title: 'Timetable',
                        subtitle: 'View schedule',
                        onTap: () => Get.toNamed(AppRoutes.timetable),
                        iconColor: const Color(0xFFF59E0B),
                      ),
                    if (_hasModuleAccess(AdminModulePermissionKeys.attendance))
                      DashboardCard(
                        icon: Icons.how_to_reg_rounded,
                        title: 'Attendance',
                        subtitle: 'Manage attendance',
                        onTap: () => Get.toNamed(AppRoutes.adminAttendance),
                        iconColor: const Color(0xFF0D9488),
                      ),
                    if (_hasModuleAccess(
                        AdminModulePermissionKeys.lunchManagement))
                      DashboardCard(
                        icon: Icons.restaurant_menu_rounded,
                        title: 'Lunch Management',
                        subtitle: 'Track student meals',
                        onTap: () =>
                            Get.toNamed(AppRoutes.adminLunchManagement),
                        iconColor: const Color(0xFF7C3AED),
                      ),
                    if (_hasModuleAccess(
                        AdminModulePermissionKeys.transportManagement))
                      DashboardCard(
                        icon: Icons.directions_bus_rounded,
                        title: 'Transport',
                        subtitle: 'Manage routes & vans',
                        onTap: () =>
                            Get.toNamed(AppRoutes.adminTransportManagement),
                        iconColor: const Color(0xFF0EA5E9),
                      ),
                    if (_hasModuleAccess(
                        AdminModulePermissionKeys.homeworkManagement))
                      DashboardCard(
                        icon: Icons.assignment_rounded,
                        title: 'Homework',
                        subtitle: 'Manage homework',
                        onTap: () => Get.toNamed(AppRoutes.adminHomework),
                        iconColor: const Color(0xFF4F46E5),
                      ),
                    if (_hasModuleAccess(
                        AdminModulePermissionKeys.examinations))
                      DashboardCard(
                        icon: Icons.assignment_rounded,
                        title: 'Examinations',
                        subtitle: 'Manage exams & timetables',
                        onTap: () => Get.toNamed(AppRoutes.adminExaminations),
                        iconColor: const Color(0xFFE11D48),
                      ),
                    if (_hasModuleAccess(AdminModulePermissionKeys.examResults))
                      DashboardCard(
                        icon: Icons.fact_check_rounded,
                        title: 'Exam Results & Marks',
                        subtitle: 'Enter and review marks',
                        onTap: () => Get.toNamed(AppRoutes.adminExamResults),
                        iconColor: const Color(0xFF7C3AED),
                      ),
                    if (_hasModuleAccess(
                        AdminModulePermissionKeys.noticesEvents))
                      DashboardCard(
                        icon: Icons.campaign_rounded,
                        title: 'Notices & Events',
                        subtitle: 'Announcements',
                        onTap: () => Get.toNamed(AppRoutes.noticeManagement),
                        iconColor: const Color(0xFF0891B2),
                      ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final stats = Map<String, dynamic>.from(_adminController.dashboardStats);
      final hasStats = stats.isNotEmpty;

      if (_adminController.isDashboardLoading && !hasStats) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 36),
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (!hasStats && _adminController.dashboardError != null) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: theme.colorScheme.error.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Could not load stats',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(_adminController.dashboardError!,
                  style: theme.textTheme.bodySmall),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: () => _adminController.fetchDashboardStats(
                    showErrorSnackbar: true),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      final overview = _asMap(stats['overview']);
      final attendance = _asMap(stats['attendance_today']);
      final upcoming = _asMap(stats['upcoming_7_days']);

      final attendanceMarked = _asInt(attendance['total_marked']);
      final attendancePresent = _asInt(attendance['present']);
      final attendanceAbsent =
          (attendanceMarked - attendancePresent).clamp(0, attendanceMarked);
      final attendanceRate = _asDouble(attendance['present_rate']);

      final upcomingExams = _asInt(upcoming['exams']);
      final upcomingHomework = _asInt(upcoming['homework_due']);
      final upcomingNotices = _asInt(upcoming['notices_expiring']);
      final upcomingTotal = upcomingExams + upcomingHomework + upcomingNotices;

      final quickStats = [
        _QuickStatData(
          label: 'Students',
          value: _formatCompact(_asInt(overview['students'])),
          icon: Icons.people_rounded,
          gradientStart: const Color(0xFF2563EB),
          gradientEnd: const Color(0xFF1D4ED8),
        ),
        _QuickStatData(
          label: 'Teachers',
          value: _formatCompact(_asInt(overview['teachers'])),
          icon: Icons.badge_rounded,
          gradientStart: const Color(0xFF059669),
          gradientEnd: const Color(0xFF047857),
        ),
        _QuickStatData(
          label: 'Notices',
          value: _formatCompact(_asInt(overview['notices'])),
          icon: Icons.campaign_rounded,
          gradientStart: const Color(0xFF0891B2),
          gradientEnd: const Color(0xFF0E7490),
        ),
        _QuickStatData(
          label: 'Present',
          value: '$attendancePresent',
          icon: Icons.check_circle_rounded,
          gradientStart: const Color(0xFF16A34A),
          gradientEnd: const Color(0xFF15803D),
        ),
        _QuickStatData(
          label: 'Attendance',
          value: '${attendanceRate.toStringAsFixed(1)}%',
          icon: Icons.how_to_reg_rounded,
          gradientStart: const Color(0xFF7C3AED),
          gradientEnd: const Color(0xFF6D28D9),
        ),
        _QuickStatData(
          label: 'Upcoming',
          value: '$upcomingTotal',
          icon: Icons.upcoming_rounded,
          gradientStart: const Color(0xFFF59E0B),
          gradientEnd: const Color(0xFFD97706),
        ),
        _QuickStatData(
          label: 'Absent',
          value: '$attendanceAbsent',
          icon: Icons.cancel_rounded,
          gradientStart: const Color(0xFFDC2626),
          gradientEnd: const Color(0xFFB91C1C),
        ),
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Quick Stats',
            subtitle: 'Compact single-row dashboard metrics',
            action: IconButton(
              tooltip: 'Refresh stats',
              onPressed: () =>
                  _adminController.fetchDashboardStats(showErrorSnackbar: true),
              icon: _adminController.isDashboardLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded),
            ),
          ),
          const SizedBox(height: 16),
          _QuickStatsRow(stats: quickStats),
        ],
      );
    });
  }

  Widget _buildTeacherTodaySection(BuildContext context) {
    final timetableController = _teacherTimetableController;
    final noticeController = _noticeController;

    if (timetableController == null || noticeController == null) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      final isLoading =
          timetableController.isLoading.value || noticeController.isLoading;
      final todaysClasses = timetableController.getTodaysClasses();
      final upcomingClasses = _getUpcomingClasses(todaysClasses);
      final noticeOfDay = _resolveNoticeOfDay(noticeController.notices);

      if (isLoading && todaysClasses.isEmpty && noticeOfDay == null) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: CircularProgressIndicator(),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Today Overview',
            subtitle: 'Notice of the day and classes for today',
            action: IconButton(
              tooltip: 'Refresh',
              onPressed: () {
                timetableController.fetchTeacherTimetable();
                noticeController.loadNotices();
              },
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded),
            ),
          ),
          const SizedBox(height: 16),
          _TeacherNoticeOfDayCard(
            notice: noticeOfDay,
            totalTodayClasses: todaysClasses.length,
            onOpenNotices: () => Get.toNamed(AppRoutes.noticeManagement),
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Upcoming Classes',
            subtitle: 'Your next classes for the day',
            action: TextButton(
              onPressed: () => Get.toNamed(AppRoutes.teacherTodayClasses),
              child: const Text('View All'),
            ),
          ),
          const SizedBox(height: 16),
          _TeacherUpcomingClassesCard(
            upcomingClasses: upcomingClasses,
            totalTodayClasses: todaysClasses.length,
            onViewAllPressed: () => Get.toNamed(AppRoutes.teacherTodayClasses),
          ),
        ],
      );
    });
  }

  List<TimeTableItem> _getUpcomingClasses(List<TimeTableItem> todaysClasses) {
    final now = DateTime.now();
    final upcoming = todaysClasses.where((classItem) {
      final startTime = _parseClassDateTime(classItem.startTime, now);
      return startTime != null && startTime.isAfter(now);
    }).toList();

    upcoming.sort((a, b) {
      final timeA = _parseClassDateTime(a.startTime, now);
      final timeB = _parseClassDateTime(b.startTime, now);
      if (timeA == null || timeB == null) {
        return a.startTime.compareTo(b.startTime);
      }
      return timeA.compareTo(timeB);
    });

    return upcoming;
  }

  DateTime? _parseClassDateTime(String rawTime, DateTime anchorDate) {
    final value = rawTime.trim().toLowerCase();
    if (value.isEmpty) return null;

    final twentyFourHour = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(value);
    if (twentyFourHour != null) {
      final hour = int.tryParse(twentyFourHour.group(1) ?? '');
      final minute = int.tryParse(twentyFourHour.group(2) ?? '');
      if (hour != null && minute != null && hour >= 0 && hour <= 23) {
        return DateTime(
          anchorDate.year,
          anchorDate.month,
          anchorDate.day,
          hour,
          minute,
        );
      }
    }

    final twelveHour =
        RegExp(r'^(\d{1,2}):(\d{2})\s*(am|pm)$').firstMatch(value);
    if (twelveHour != null) {
      final hourRaw = int.tryParse(twelveHour.group(1) ?? '');
      final minute = int.tryParse(twelveHour.group(2) ?? '');
      final meridiem = twelveHour.group(3);
      if (hourRaw != null &&
          minute != null &&
          meridiem != null &&
          hourRaw >= 1 &&
          hourRaw <= 12) {
        var hour = hourRaw % 12;
        if (meridiem == 'pm') hour += 12;

        return DateTime(
          anchorDate.year,
          anchorDate.month,
          anchorDate.day,
          hour,
          minute,
        );
      }
    }

    return null;
  }

  NoticeModel? _resolveNoticeOfDay(List<NoticeModel> notices) {
    if (notices.isEmpty) return null;

    final now = DateTime.now();
    final todayNotices = notices.where((notice) {
      return _isSameDate(notice.issuedDate, now) && !_isNoticeExpired(notice);
    }).toList()
      ..sort((a, b) => b.issuedDate.compareTo(a.issuedDate));

    if (todayNotices.isNotEmpty) {
      return todayNotices.first;
    }

    final activeNotices =
        notices.where((notice) => !_isNoticeExpired(notice)).toList()
          ..sort((a, b) => b.issuedDate.compareTo(a.issuedDate));

    if (activeNotices.isNotEmpty) {
      return activeNotices.first;
    }

    return notices.first;
  }

  bool _isNoticeExpired(NoticeModel notice) {
    final expiry = notice.expiryDate;
    if (expiry == null) return false;
    return expiry.isBefore(DateTime.now());
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return const <String, dynamic>{};
  }

  int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value.toString()) ?? 0;
  }

  double _asDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  String _formatCompact(num value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(0);
  }
}

class _QuickStatData {
  final String label;
  final String value;
  final IconData icon;
  final Color gradientStart;
  final Color gradientEnd;

  const _QuickStatData({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradientStart,
    required this.gradientEnd,
  });
}

class _QuickStatsRow extends StatelessWidget {
  final List<_QuickStatData> stats;

  const _QuickStatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        const compactCardWidth = 130.0;
        final totalWidth =
            (stats.length * compactCardWidth) + ((stats.length - 1) * spacing);
        final fitsOneRow = totalWidth <= constraints.maxWidth;

        final rowChildren = stats
            .map((stat) => _QuickStatCard(data: stat))
            .toList(growable: false);

        if (fitsOneRow) {
          return Row(
            children: [
              for (int i = 0; i < rowChildren.length; i++) ...[
                Expanded(child: rowChildren[i]),
                if (i != rowChildren.length - 1) const SizedBox(width: spacing),
              ],
            ],
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (int i = 0; i < rowChildren.length; i++) ...[
                SizedBox(width: compactCardWidth, child: rowChildren[i]),
                if (i != rowChildren.length - 1) const SizedBox(width: spacing),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final _QuickStatData data;

  const _QuickStatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [data.gradientStart, data.gradientEnd],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: data.gradientStart.withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.24),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(
                  data.icon,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            data.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              fontSize: 19,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherUpcomingClassesCard extends StatelessWidget {
  final List<TimeTableItem> upcomingClasses;
  final int totalTodayClasses;
  final VoidCallback onViewAllPressed;

  const _TeacherUpcomingClassesCard({
    required this.upcomingClasses,
    required this.totalTodayClasses,
    required this.onViewAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final classesToShow = upcomingClasses.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.upcoming_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Upcoming Classes',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Today: $totalTodayClasses',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (classesToShow.isEmpty)
            Text(
              'No more upcoming classes for today.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            )
          else
            ...classesToShow.map((classItem) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${classItem.subject} (${classItem.startTime} - ${classItem.endTime})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: onViewAllPressed,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              foregroundColor: Colors.white,
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
            icon: const Icon(Icons.today_rounded, size: 18),
            label: const Text('View All Today\'s Classes'),
          ),
        ],
      ),
    );
  }
}

class _TeacherNoticeOfDayCard extends StatelessWidget {
  final NoticeModel? notice;
  final int totalTodayClasses;
  final VoidCallback onOpenNotices;

  const _TeacherNoticeOfDayCard({
    required this.notice,
    required this.totalTodayClasses,
    required this.onOpenNotices,
  });

  String _formatDate(DateTime date) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0EA5E9), Color(0xFF0369A1)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0369A1).withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.campaign_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Notice of the Day',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Classes: $totalTodayClasses',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (notice == null)
            Text(
              'No active notices available right now.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.88),
              ),
            )
          else ...[
            Text(
              notice!.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              notice!.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.92),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Issued: ${_formatDate(notice!.issuedDate)}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 10),
          FilledButton.tonalIcon(
            onPressed: onOpenNotices,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: const Text('Open Notices'),
          ),
        ],
      ),
    );
  }
}

class _BannerGlassIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _BannerGlassIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// Welcome banner shown at top of dashboard
class _WelcomeBanner extends StatelessWidget {
  final String adminName;
  final bool isDark;
  final bool showDrawerButton;
  final bool isTeacherDashboard;

  const _WelcomeBanner({
    required this.adminName,
    required this.isDark,
    this.showDrawerButton = false,
    this.isTeacherDashboard = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authController = Get.find<AuthController>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 48, 28, 28),
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
              ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (showDrawerButton) ...[
            Builder(
              builder: (drawerContext) => _BannerGlassIconButton(
                icon: Icons.menu_rounded,
                tooltip: 'Open drawer',
                onPressed: () => Scaffold.of(drawerContext).openDrawer(),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        adminName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Here's what's happening at your school today",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Obx(() {
            final isTeacherRole =
                authController.currentRole == AppConstants.roleTeacher;
            final admin = authController.currentAdmin;
            final teacher = authController.currentTeacher;
            final displayName =
                teacher?.fullName ?? admin?.fullName ?? 'Admin';
            final profileImageUrl =
                teacher?.profileImageUrl ?? admin?.profileImageUrl;
            final profileRoute =
                isTeacherRole ? AppRoutes.teacherProfile : AppRoutes.adminProfile;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _BannerGlassIconButton(
                  icon: isTeacherDashboard
                      ? Icons.notifications_rounded
                      : (theme.brightness == Brightness.dark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded),
                  tooltip: isTeacherDashboard ? 'Notices' : 'Toggle theme',
                  onPressed: () {
                    if (isTeacherDashboard) {
                      Get.toNamed(AppRoutes.noticeManagement);
                      return;
                    }
                    if (Get.isRegistered<ThemeController>()) {
                      Get.find<ThemeController>().toggleTheme();
                    }
                  },
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  tooltip: 'Profile',
                  offset: const Offset(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  onSelected: (value) {
                    if (value == 'profile') {
                      Get.toNamed(profileRoute);
                      return;
                    }
                    if (value == 'notices') {
                      Get.toNamed(AppRoutes.noticeManagement);
                      return;
                    }
                    if (value == 'toggle_theme') {
                      if (Get.isRegistered<ThemeController>()) {
                        Get.find<ThemeController>().toggleTheme();
                      }
                      return;
                    }
                    if (value == 'logout') {
                      authController.logout();
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                    child: ClipOval(
                      child: ProfileAvatarWidget(
                        size: 36,
                        imageUrl: profileImageUrl,
                        displayName: displayName,
                        enablePreview: false,
                      ),
                    ),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      enabled: false,
                      child: Text(
                        displayName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const PopupMenuDivider(),
                    if (isTeacherDashboard)
                      const PopupMenuItem<String>(
                        value: 'notices',
                        child: Text('Notices'),
                      ),
                    if (isTeacherDashboard)
                      PopupMenuItem<String>(
                        value: 'toggle_theme',
                        child: Text(
                          theme.brightness == Brightness.dark
                              ? 'Switch to Light Theme'
                              : 'Switch to Dark Theme',
                        ),
                      ),
                    const PopupMenuItem<String>(
                      value: 'profile',
                      child: Text('My Profile'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Text('Logout'),
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
