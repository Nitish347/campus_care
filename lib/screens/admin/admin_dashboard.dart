import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/controllers/theme_controller.dart';
import 'package:campus_care/core/constants/admin_module_permissions.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/widgets/cards/dashboard_card.dart';
import 'package:campus_care/widgets/common/section_header.dart';
import 'package:campus_care/widgets/common/file_display_widget.dart';
import 'package:campus_care/widgets/responsive/responsive_grid.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/admin/admin_sidebar.dart';

import '../../controllers/admin_controller.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late final AdminController _adminController;

  @override
  void initState() {
    super.initState();
    _adminController = Get.find<AdminController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _adminController.fetchDashboardStats();
    });
  }

  bool _hasModuleAccess(String moduleKey) {
    final admin = Get.find<AuthController>().currentAdmin;
    return admin?.hasModuleAccess(moduleKey) ?? true;
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
      sections.add(
        SidebarSection(
          title: 'Student Management',
          items: [
            SidebarItem(
              icon: Icons.people_rounded,
              title: 'Student List',
              onTap: () => Get.toNamed(AppRoutes.studentList),
            ),
            SidebarItem(
              icon: Icons.person_add_rounded,
              title: 'Add Student',
              onTap: () => Get.toNamed(AppRoutes.addStudent),
            ),
          ],
        ),
      );
    }

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
            final adminName =
                Get.find<AuthController>().currentAdmin?.fullName ?? 'Admin';
            return _WelcomeBanner(
              adminName: adminName,
              isDark: isDark,
              showDrawerButton: showDrawerButton,
            );
          }),
          ResponsivePadding(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 28),
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
                        AdminModulePermissionKeys.teacherManagement))
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

  const _WelcomeBanner({
    required this.adminName,
    required this.isDark,
    this.showDrawerButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authController = Get.find<AuthController>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 28, 28, 28),
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
            final admin = authController.currentAdmin;
            final displayName = admin?.fullName ?? 'Admin';
            final profileImageUrl = admin?.profileImageUrl;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _BannerGlassIconButton(
                  icon: theme.brightness == Brightness.dark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  tooltip: 'Toggle theme',
                  onPressed: () {
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
                      Get.toNamed(AppRoutes.adminProfile);
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
