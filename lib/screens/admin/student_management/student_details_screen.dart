import 'package:campus_care/controllers/class_controller.dart';
import 'package:campus_care/models/exam_model.dart';
import 'package:campus_care/models/exam_result_model.dart';
import 'package:campus_care/models/student/student.dart';
import 'package:campus_care/models/transport/transport_assignment.dart';
import 'package:campus_care/models/transport/transport_route.dart';
import 'package:campus_care/models/transport/transport_stop.dart';
import 'package:campus_care/services/api/attendance_api_service.dart';
import 'package:campus_care/services/api/exam_api_service.dart';
import 'package:campus_care/services/api/exam_result_api_service.dart';
import 'package:campus_care/services/api/lunch_api_service.dart';
import 'package:campus_care/services/student_service.dart';
import 'package:campus_care/services/transport_service.dart';
import 'package:campus_care/utils/upload_url_utils.dart';
import 'package:campus_care/widgets/admin/admin_page_header.dart';
import 'package:campus_care/widgets/common/file_display_widget.dart';
import 'package:campus_care/widgets/common/section_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'add_student_screen.dart';

enum _DetailsTab {
  profile,
  attendance,
  transport,
  lunch,
  results,
}

class AdminStudentDetailsScreen extends StatefulWidget {
  final Student student;

  const AdminStudentDetailsScreen({
    super.key,
    required this.student,
  });

  @override
  State<AdminStudentDetailsScreen> createState() =>
      _AdminStudentDetailsScreenState();
}

class _AdminStudentDetailsScreenState extends State<AdminStudentDetailsScreen> {
  final AttendanceApiService _attendanceApi = AttendanceApiService();
  final LunchApiService _lunchApi = LunchApiService();
  final ExamResultApiService _examResultApi = ExamResultApiService();
  final ExamApiService _examApi = ExamApiService();

  late final ClassController _classController;
  final ScrollController _scrollController = ScrollController();

  late Student _student;
  List<_AttendanceRecord> _attendanceRecords = const [];
  List<_LunchRecord> _lunchRecords = const [];
  List<ExamResult> _examResults = const [];
  Map<String, ExamModel> _examById = const {};
  TransportRoute? _route;
  TransportAssignment? _assignment;
  List<TransportStop> _stops = const [];

  bool _isLoading = true;
  String? _loadError;
  _DetailsTab _activeTab = _DetailsTab.profile;

  DateTime _selectedAttendanceMonth = _monthStart(DateTime.now());
  DateTime _selectedLunchMonth = _monthStart(DateTime.now());
  DateTime? _selectedAttendanceDate;
  DateTime? _selectedLunchDate;

  @override
  void initState() {
    super.initState();
    _student = widget.student;
    _classController = Get.isRegistered<ClassController>()
        ? Get.find<ClassController>()
        : Get.put(ClassController());
    _loadDetails();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      if (_classController.classes.isEmpty) {
        await _classController.fetchClasses();
      }

      final refreshedStudent = await StudentService.getStudentById(_student.id);
      final student = refreshedStudent ?? _student;

      final attendanceFuture = _fetchAttendance(student);
      final lunchFuture = _fetchLunch(student);
      final resultsFuture = _fetchExamResults(student);
      final transportFuture = _fetchTransport(student.routeId);
      final examsFuture = (student.class_ != null &&
              student.section != null &&
              student.section!.isNotEmpty)
          ? _examApi.getExams(
              classId: student.class_,
              section: student.section,
            )
          : Future.value(<dynamic>[]);

      final resolvedAttendance = await attendanceFuture;
      final resolvedLunch = await lunchFuture;
      final resolvedResults = await resultsFuture;
      final resolvedTransport = await transportFuture;
      final resolvedExamsRaw = await examsFuture;

      final examList = resolvedExamsRaw
          .map((item) => ExamModel.fromJson(item as Map<String, dynamic>))
          .toList();
      final examById = <String, ExamModel>{};
      for (final exam in examList) {
        examById[exam.id] = exam;
      }

      resolvedResults.sort((a, b) {
        final aDate = examById[a.examId]?.examDate ?? a.updatedAt;
        final bDate = examById[b.examId]?.examDate ?? b.updatedAt;
        return bDate.compareTo(aDate);
      });

      if (!mounted) return;
      setState(() {
        _student = student;
        _attendanceRecords = resolvedAttendance;
        _lunchRecords = resolvedLunch;
        _examResults = resolvedResults;
        _examById = examById;
        _route = resolvedTransport.route;
        _assignment = resolvedTransport.assignment;
        _stops = resolvedTransport.stops;
        _selectedAttendanceDate ??= _todayDate();
        _selectedLunchDate ??= _todayDate();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<List<_AttendanceRecord>> _fetchAttendance(Student student) async {
    List<dynamic> rows = await _attendanceApi.getAttendance(
      classId: student.class_,
      section: student.section,
      studentId: student.id,
    );
    var parsed = _parseAttendanceRows(rows, student.id);

    if (parsed.isEmpty && student.class_ != null && student.section != null) {
      rows = await _attendanceApi.getAttendance(
        classId: student.class_,
        section: student.section,
      );
      parsed = _parseAttendanceRows(rows, student.id);
    }

    parsed.sort((a, b) => b.date.compareTo(a.date));
    return parsed;
  }

  List<_AttendanceRecord> _parseAttendanceRows(
    List<dynamic> rows,
    String studentId,
  ) {
    final records = <_AttendanceRecord>[];
    for (final row in rows) {
      if (row is! Map<String, dynamic>) continue;
      final rowStudentId = _extractId(row['student_id'] ?? row['studentId']);
      if (rowStudentId != studentId) continue;

      final date = _parseDate(
        row['date'] ??
            row['attendance_date'] ??
            row['created_at'] ??
            row['createdAt'],
      );
      if (date == null) continue;

      final status =
          (row['status'] ?? 'absent').toString().trim().toLowerCase();
      records.add(
        _AttendanceRecord(
          date: DateTime(date.year, date.month, date.day),
          status: status,
          remarks: (row['remarks'] ?? row['remark'])?.toString(),
        ),
      );
    }
    return records;
  }

  Future<List<_LunchRecord>> _fetchLunch(Student student) async {
    List<dynamic> rows = await _lunchApi.getLunch(
      classId: student.class_,
      section: student.section,
      studentId: student.id,
    );
    var parsed = _parseLunchRows(rows, student.id);

    if (parsed.isEmpty && student.class_ != null && student.section != null) {
      rows = await _lunchApi.getLunch(
        classId: student.class_,
        section: student.section,
      );
      parsed = _parseLunchRows(rows, student.id);
    }

    parsed.sort((a, b) => b.date.compareTo(a.date));
    return parsed;
  }

  List<_LunchRecord> _parseLunchRows(List<dynamic> rows, String studentId) {
    final records = <_LunchRecord>[];
    for (final row in rows) {
      if (row is! Map<String, dynamic>) continue;
      final rowStudentId = _extractId(row['student_id'] ?? row['studentId']);
      if (rowStudentId != studentId) continue;

      final date =
          _parseDate(row['date'] ?? row['created_at'] ?? row['createdAt']);
      if (date == null) continue;

      records.add(
        _LunchRecord(
          date: DateTime(date.year, date.month, date.day),
          status: (row['status'] ?? 'Not Taken').toString().trim(),
          remarks: (row['remarks'] ?? row['remark'])?.toString(),
        ),
      );
    }
    return records;
  }

  Future<List<ExamResult>> _fetchExamResults(Student student) async {
    final rows = await _examResultApi.getExamResults(studentId: student.id);
    return rows
        .whereType<Map<String, dynamic>>()
        .map(ExamResult.fromJson)
        .toList();
  }

  Future<_TransportBundle> _fetchTransport(String? routeId) async {
    if (routeId == null || routeId.isEmpty) return const _TransportBundle();

    final routesFuture = TransportService.getRoutes();
    final assignmentsFuture = TransportService.getAssignments();
    final stopsFuture = TransportService.getRouteStops(routeId);

    final routes = await routesFuture;
    final assignments = await assignmentsFuture;
    final stops = await stopsFuture;

    TransportRoute? route;
    for (final item in routes) {
      if (item.id == routeId) {
        route = item;
        break;
      }
    }

    final assignmentCandidates = assignments
        .where((item) => item.routeId == routeId)
        .toList()
      ..sort((a, b) => b.effectiveFrom.compareTo(a.effectiveFrom));
    final active =
        assignmentCandidates.where((item) => item.status == 'active').toList();
    final assignment = active.isNotEmpty
        ? active.first
        : (assignmentCandidates.isNotEmpty ? assignmentCandidates.first : null);

    final sortedStops = List<TransportStop>.from(stops)
      ..sort((a, b) => a.sequenceNumber.compareTo(b.sequenceNumber));

    return _TransportBundle(
      route: route,
      assignment: assignment,
      stops: sortedStops,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          AdminPageHeader(
            title: 'Student Details',
            subtitle: 'Complete profile and progress insights',
            icon: Icons.person_pin_rounded,
            showBreadcrumb: true,
            breadcrumbLabel: 'Students',
            showBackButton: true,
            actions: [
              HeaderActionButton(
                icon: Icons.refresh_rounded,
                label: 'Refresh',
                onPressed: _loadDetails,
              ),
              const SizedBox(width: 8),
              HeaderActionButton(
                icon: Icons.edit_rounded,
                label: 'Edit',
                onPressed: () =>
                    Get.to(() => AddStudentScreen(student: _student)),
              ),
            ],
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadDetails,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_loadError != null) _buildLoadErrorCard(theme),
                          _buildProfileHero(theme),
                          const SizedBox(height: 14),
                          _buildSectionTabs(theme),
                          const SizedBox(height: 14),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: _buildActiveSection(theme),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSection(ThemeData theme) {
    switch (_activeTab) {
      case _DetailsTab.profile:
        return _buildProfileSection(theme);
      case _DetailsTab.attendance:
        return _buildAttendanceSection(theme);
      case _DetailsTab.transport:
        return _buildTransportSection(theme);
      case _DetailsTab.lunch:
        return _buildLunchSection(theme);
      case _DetailsTab.results:
        return _buildResultsSection(theme);
    }
  }

  Widget _buildLoadErrorCard(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Some details could not be loaded. Pull down or tap Refresh.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHero(ThemeData theme) {
    final classText =
        '${_className(_student.class_)} ${_student.section?.isNotEmpty == true ? '| ${_student.section}' : ''}';
    final routeText = (_student.routeId != null && _student.routeId!.isNotEmpty)
        ? 'Transport Assigned'
        : 'No Transport';
    final profileImageUrls =
        UploadUrlUtils.buildCandidateUrls(_student.profileImageUrl);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Wrap(
        spacing: 16,
        runSpacing: 14,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
            ),
            child: Center(
              child: ProfileAvatarWidget(
                size: 60,
                imageUrls: profileImageUrls,
                displayName: _student.fullName.isNotEmpty
                    ? _student.fullName
                    : 'Student',
                enablePreview: true,
                backgroundColor: Colors.white24,
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 380,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _student.fullName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enrollment: ${_student.enrollmentNumber}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _heroPill(Icons.class_rounded, classText),
                    _heroPill(Icons.route_rounded, routeText),
                    _heroPill(
                      Icons.confirmation_number_rounded,
                      'Roll ${_student.rollNumber}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.17),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTabs(ThemeData theme) {
    final tabs = <_DetailsTab, String>{
      _DetailsTab.profile: 'Profile',
      _DetailsTab.attendance: 'Attendance',
      _DetailsTab.transport: 'Transport',
      _DetailsTab.lunch: 'Lunch',
      _DetailsTab.results: 'Exam Marks',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.entries.map((entry) {
          final selected = _activeTab == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(entry.value),
              selected: selected,
              onSelected: (_) => setState(() => _activeTab = entry.key),
              selectedColor:
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
              checkmarkColor: theme.colorScheme.primary,
              labelStyle: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
                side: BorderSide(
                  color: selected
                      ? theme.colorScheme.primary.withValues(alpha: 0.35)
                      : theme.colorScheme.outline.withValues(alpha: 0.25),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProfileSection(ThemeData theme) {
    return _sectionCard(
      key: const ValueKey('profile'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Student and Guardian Details',
            subtitle: 'Identity, contact and admission information',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _segmentBadge(theme, Icons.person_rounded, 'Personal'),
              _segmentBadge(theme, Icons.school_rounded, 'Academic'),
              _segmentBadge(theme, Icons.family_restroom_rounded, 'Guardian'),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 860;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildStudentInfo(theme)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildGuardianInfo(theme)),
                  ],
                );
              }
              return Column(
                children: [
                  _buildStudentInfo(theme),
                  const SizedBox(height: 12),
                  _buildGuardianInfo(theme),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStudentInfo(ThemeData theme) {
    return Column(
      children: [
        _segmentBlock(
          theme,
          title: 'Personal Info',
          icon: Icons.person_rounded,
          child: Column(
            children: [
              _infoRow(theme, Icons.person_rounded, 'Name', _student.fullName),
              _infoRow(theme, Icons.badge_rounded, 'Enrollment',
                  _student.enrollmentNumber),
              _infoRow(theme, Icons.confirmation_number_rounded, 'Roll No.',
                  _student.rollNumber),
              _infoRow(theme, Icons.email_rounded, 'Email', _student.email),
              _infoRow(
                  theme, Icons.phone_rounded, 'Phone', _student.phone ?? 'N/A'),
              _infoRow(
                  theme, Icons.wc_rounded, 'Gender', _student.gender ?? 'N/A'),
              _infoRow(theme, Icons.home_rounded, 'Address',
                  _student.address ?? 'N/A'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _segmentBlock(
          theme,
          title: 'Academic Info',
          icon: Icons.school_rounded,
          child: Column(
            children: [
              _infoRow(
                theme,
                Icons.class_rounded,
                'Class',
                '${_className(_student.class_)} ${_student.section?.isNotEmpty == true ? '| ${_student.section}' : ''}',
              ),
              _infoRow(
                theme,
                Icons.cake_rounded,
                'Date of Birth',
                _student.dateOfBirth != null
                    ? DateFormat('dd MMM yyyy').format(_student.dateOfBirth!)
                    : 'N/A',
              ),
              _infoRow(
                theme,
                Icons.event_available_rounded,
                'Admission Date',
                _student.admissionDate != null
                    ? DateFormat('dd MMM yyyy').format(_student.admissionDate!)
                    : 'N/A',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGuardianInfo(ThemeData theme) {
    final guardian = _student.guardian;
    return _segmentBlock(
      theme,
      title: 'Guardian Contact',
      icon: Icons.family_restroom_rounded,
      child: Column(
        children: [
          _infoRow(theme, Icons.family_restroom_rounded, 'Guardian Name',
              guardian?.name ?? 'N/A'),
          _infoRow(theme, Icons.phone_rounded, 'Guardian Phone',
              guardian?.phone ?? 'N/A'),
          _infoRow(theme, Icons.email_rounded, 'Guardian Email',
              guardian?.email ?? 'N/A'),
          _infoRow(theme, Icons.people_outline_rounded, 'Relation',
              guardian?.relation ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildAttendanceSection(ThemeData theme) {
    final map = _attendanceByDateMap();
    final monthStats = _attendanceMonthStats(_selectedAttendanceMonth, map);

    return _sectionCard(
      key: const ValueKey('attendance'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Attendance Calendar',
            subtitle: 'Missing past dates are treated as absent',
          ),
          const SizedBox(height: 14),
          _buildMonthNavigator(
            theme: theme,
            month: _selectedAttendanceMonth,
            onPrevious: () {
              setState(() {
                _selectedAttendanceMonth = _monthStart(DateTime(
                    _selectedAttendanceMonth.year,
                    _selectedAttendanceMonth.month - 1));
              });
            },
            onNext: () {
              setState(() {
                _selectedAttendanceMonth = _monthStart(DateTime(
                    _selectedAttendanceMonth.year,
                    _selectedAttendanceMonth.month + 1));
              });
            },
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _metricCard(theme, 'Days', '${monthStats.totalDays}',
                  Icons.calendar_today_rounded, theme.colorScheme.primary),
              _metricCard(theme, 'Present', '${monthStats.present}',
                  Icons.check_circle_rounded, Colors.green),
              _metricCard(theme, 'Absent', '${monthStats.absent}',
                  Icons.cancel_rounded, Colors.red),
              _metricCard(theme, 'Late', '${monthStats.late}',
                  Icons.schedule_rounded, Colors.orange),
              _metricCard(theme, 'Rate', '${monthStats.percentage}%',
                  Icons.percent_rounded, theme.colorScheme.secondary),
            ],
          ),
          const SizedBox(height: 12),
          _buildAttendanceLegend(theme),
          const SizedBox(height: 10),
          _buildMonthCalendar(
            theme: theme,
            month: _selectedAttendanceMonth,
            selectedDate: _selectedAttendanceDate,
            statusForDay: (date) => _attendanceStatusForDate(date, map),
            colorForStatus: _statusColor,
            onTapDay: (day) => setState(() => _selectedAttendanceDate = day),
          ),
          const SizedBox(height: 12),
          _buildAttendanceSelectedDay(theme, map),
        ],
      ),
    );
  }

  Widget _buildAttendanceLegend(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _legendPill(theme, 'Present', Colors.green),
        _legendPill(theme, 'Late', Colors.orange),
        _legendPill(theme, 'Excused', Colors.blue),
        _legendPill(theme, 'Absent', Colors.red),
        _legendPill(theme, 'Future', theme.colorScheme.outline),
      ],
    );
  }

  Widget _buildAttendanceSelectedDay(
    ThemeData theme,
    Map<String, _AttendanceRecord> map,
  ) {
    final selected = _selectedAttendanceDate;
    if (selected == null) {
      return _emptyHint(
        theme,
        icon: Icons.info_outline_rounded,
        title: 'Select a date',
        subtitle: 'Tap any day to see attendance status and remarks.',
      );
    }

    final status = _attendanceStatusForDate(selected, map);
    if (status == 'future') {
      return _emptyHint(
        theme,
        icon: Icons.schedule_rounded,
        title: DateFormat('dd MMM yyyy').format(selected),
        subtitle: 'Future date',
      );
    }

    final record = map[_dayKey(selected)];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: _statusColor(status).withValues(alpha: 0.1),
        border: Border.all(color: _statusColor(status).withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEE, dd MMM yyyy').format(selected),
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Status: ${_statusLabel(status)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: _statusColor(status),
              fontWeight: FontWeight.w700,
            ),
          ),
          if ((record?.remarks ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Remarks: ${record!.remarks}',
                style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }

  Widget _buildTransportSection(ThemeData theme) {
    return _sectionCard(
      key: const ValueKey('transport'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Transport Details',
            subtitle: 'Route, assignment and stop sequence',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _segmentBadge(theme, Icons.alt_route_rounded, 'Route'),
              _segmentBadge(
                  theme, Icons.directions_bus_rounded, 'Vehicle & Crew'),
              _segmentBadge(theme, Icons.place_rounded, 'Stops'),
            ],
          ),
          const SizedBox(height: 14),
          if (_student.routeId == null || _student.routeId!.isEmpty)
            _emptyHint(
              theme,
              icon: Icons.route_rounded,
              title: 'No route assigned',
              subtitle: 'Assign a transport route to show transport details.',
            )
          else ...[
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 880;
                final routeCard = _segmentBlock(
                  theme,
                  title: _route?.routeName ?? 'Route ${_student.routeId}',
                  icon: Icons.alt_route_rounded,
                  child: Column(
                    children: [
                      _infoRow(
                        theme,
                        Icons.confirmation_number_rounded,
                        'Route Number',
                        _route?.routeNumber.isNotEmpty == true
                            ? _route!.routeNumber
                            : 'N/A',
                      ),
                      _infoRow(
                        theme,
                        Icons.route_rounded,
                        'Path',
                        _route != null
                            ? '${_route!.startLocation} to ${_route!.endLocation}'
                            : 'N/A',
                      ),
                      _infoRow(
                        theme,
                        Icons.straighten_rounded,
                        'Distance',
                        _route?.distanceKm != null
                            ? '${_route!.distanceKm} km'
                            : 'N/A',
                      ),
                      _infoRow(
                        theme,
                        Icons.schedule_rounded,
                        'Duration',
                        _route?.estimatedDurationMinutes != null
                            ? '${_route!.estimatedDurationMinutes} min'
                            : 'N/A',
                      ),
                    ],
                  ),
                );

                final vehicleCard = _segmentBlock(
                  theme,
                  title: 'Vehicle and Crew',
                  icon: Icons.directions_bus_rounded,
                  child: Column(
                    children: [
                      _infoRow(
                        theme,
                        Icons.directions_bus_filled_rounded,
                        'Vehicle',
                        _assignment == null
                            ? 'N/A'
                            : (_assignment!.vehicleNumber?.isNotEmpty == true
                                ? '${_assignment!.vehicleNumber} (${_assignment!.vehicleType ?? 'N/A'})'
                                : _assignment!.vehicleId),
                      ),
                      _infoRow(
                        theme,
                        Icons.person_rounded,
                        'Driver',
                        _assignment == null
                            ? 'N/A'
                            : (_assignment!.driverName.isNotEmpty
                                ? _assignment!.driverName
                                : _assignment!.driverId),
                      ),
                      _infoRow(
                        theme,
                        Icons.phone_rounded,
                        'Driver Phone',
                        _assignment?.driverPhone ?? 'N/A',
                      ),
                      _infoRow(
                        theme,
                        Icons.support_agent_rounded,
                        'Attendant',
                        _assignment?.attendantName ?? 'N/A',
                      ),
                    ],
                  ),
                );

                if (!isWide) {
                  return Column(
                    children: [
                      routeCard,
                      const SizedBox(height: 10),
                      vehicleCard,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: routeCard),
                    const SizedBox(width: 10),
                    Expanded(child: vehicleCard),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Stops',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (_stops.isEmpty)
              _emptyHint(
                theme,
                icon: Icons.location_off_rounded,
                title: 'No stops available',
                subtitle: 'Stops for this route are not configured yet.',
              )
            else
              ..._stops.map(
                (stop) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.22),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${stop.sequenceNumber}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '#${stop.sequenceNumber} ${stop.stopName}',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          stop.pickupTime ?? stop.dropTime ?? '',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildLunchSection(ThemeData theme) {
    final map = _lunchByDateMap();
    final stats = _lunchMonthStats(_selectedLunchMonth, map);

    return _sectionCard(
      key: const ValueKey('lunch'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Lunch Calendar',
            subtitle: 'View current and previous month lunch data',
          ),
          const SizedBox(height: 14),
          _buildMonthNavigator(
            theme: theme,
            month: _selectedLunchMonth,
            onPrevious: () {
              setState(() {
                _selectedLunchMonth = _monthStart(DateTime(
                    _selectedLunchMonth.year, _selectedLunchMonth.month - 1));
              });
            },
            onNext: () {
              setState(() {
                _selectedLunchMonth = _monthStart(DateTime(
                    _selectedLunchMonth.year, _selectedLunchMonth.month + 1));
              });
            },
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _metricCard(theme, 'Days', '${stats.totalDays}',
                  Icons.calendar_today_rounded, theme.colorScheme.primary),
              _metricCard(theme, 'Full', '${stats.fullMeal}',
                  Icons.restaurant_rounded, Colors.green),
              _metricCard(theme, 'Half', '${stats.halfMeal}',
                  Icons.lunch_dining_rounded, Colors.orange),
              _metricCard(theme, 'Absent', '${stats.absent}',
                  Icons.person_off_rounded, Colors.red),
              _metricCard(theme, 'Marked', '${stats.markedRate}%',
                  Icons.percent_rounded, theme.colorScheme.secondary),
            ],
          ),
          const SizedBox(height: 12),
          _buildLunchLegend(theme),
          const SizedBox(height: 10),
          _buildMonthCalendar(
            theme: theme,
            month: _selectedLunchMonth,
            selectedDate: _selectedLunchDate,
            statusForDay: (date) => _lunchStatusForDate(date, map),
            colorForStatus: _lunchStatusColor,
            onTapDay: (day) => setState(() => _selectedLunchDate = day),
          ),
          const SizedBox(height: 12),
          _buildLunchSelectedDay(theme, map),
        ],
      ),
    );
  }

  Widget _buildLunchLegend(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _legendPill(theme, 'Full Meal', Colors.green),
        _legendPill(theme, 'Half Meal', Colors.orange),
        _legendPill(theme, 'Not Taken', Colors.blueGrey),
        _legendPill(theme, 'Absent', Colors.red),
        _legendPill(theme, 'Not Marked', theme.colorScheme.outline),
      ],
    );
  }

  Widget _buildLunchSelectedDay(
    ThemeData theme,
    Map<String, _LunchRecord> map,
  ) {
    final selected = _selectedLunchDate;
    if (selected == null) {
      return _emptyHint(
        theme,
        icon: Icons.info_outline_rounded,
        title: 'Select a date',
        subtitle: 'Tap any day to see lunch status and remarks.',
      );
    }

    final status = _lunchStatusForDate(selected, map);
    if (status == 'future') {
      return _emptyHint(
        theme,
        icon: Icons.schedule_rounded,
        title: DateFormat('dd MMM yyyy').format(selected),
        subtitle: 'Future date',
      );
    }

    final record = map[_dayKey(selected)];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: _lunchStatusColor(status).withValues(alpha: 0.1),
        border: Border.all(
            color: _lunchStatusColor(status).withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEE, dd MMM yyyy').format(selected),
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Status: ${_lunchStatusLabel(status)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: _lunchStatusColor(status),
              fontWeight: FontWeight.w700,
            ),
          ),
          if ((record?.remarks ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Remarks: ${record!.remarks}',
                style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }

  Widget _buildResultsSection(ThemeData theme) {
    final grouped = <String, List<ExamResult>>{};
    for (final result in _examResults) {
      grouped.putIfAbsent(result.examId, () => <ExamResult>[]).add(result);
    }

    final examIds = grouped.keys.toList()
      ..sort((a, b) {
        final aDate = _examById[a]?.examDate ??
            grouped[a]!
                .map((e) => e.updatedAt)
                .reduce((x, y) => x.isAfter(y) ? x : y);
        final bDate = _examById[b]?.examDate ??
            grouped[b]!
                .map((e) => e.updatedAt)
                .reduce((x, y) => x.isAfter(y) ? x : y);
        return bDate.compareTo(aDate);
      });

    final present = _examResults.where((e) => e.isPresent).toList();
    final avg = present.isEmpty
        ? 0
        : (present.map((e) => e.percentage).reduce((a, b) => a + b) /
                present.length)
            .round();

    return _sectionCard(
      key: const ValueKey('results'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Exam Wise Marks',
            subtitle: 'Grouped by exam with subject-level marks',
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _metricCard(theme, 'Exams', '${examIds.length}',
                  Icons.event_note_rounded, theme.colorScheme.primary),
              _metricCard(theme, 'Entries', '${_examResults.length}',
                  Icons.assignment_rounded, theme.colorScheme.primary),
              _metricCard(theme, 'Average', '$avg%', Icons.trending_up_rounded,
                  Colors.green),
              _metricCard(
                theme,
                'Absent',
                '${_examResults.where((e) => !e.isPresent).length}',
                Icons.person_off_rounded,
                Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (examIds.isEmpty)
            _emptyHint(
              theme,
              icon: Icons.sticky_note_2_outlined,
              title: 'No exam results',
              subtitle: 'Exam marks will appear once records are saved.',
            )
          else
            ...examIds.map((examId) {
              final rows = grouped[examId]!
                ..sort((a, b) => a.subject.compareTo(b.subject));
              final exam = _examById[examId];
              final date = exam?.examDate ?? rows.first.updatedAt;
              final name = exam?.name ??
                  'Exam ${examId.length > 6 ? examId.substring(0, 6) : examId}';
              final presentRows = rows.where((e) => e.isPresent).toList();
              final examAvg = presentRows.isEmpty
                  ? 0
                  : (presentRows
                              .map((e) => e.percentage)
                              .reduce((a, b) => a + b) /
                          presentRows.length)
                      .round();

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                ),
                child: ExpansionTile(
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  title: Text(
                    name,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${DateFormat('dd MMM yyyy').format(date)} | Avg: $examAvg%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  children: rows
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.25),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.subject,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  item.isPresent
                                      ? '${item.marks.toStringAsFixed(item.marks == item.marks.roundToDouble() ? 0 : 1)} / ${item.totalMarks.toStringAsFixed(item.totalMarks == item.totalMarks.roundToDouble() ? 0 : 1)}'
                                      : 'Absent',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: item.isPresent ? null : Colors.red,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  item.isPresent
                                      ? '${item.percentage.toStringAsFixed(1)}%'
                                      : '--',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: item.isPresent
                                        ? _scoreColor(item.percentage)
                                        : Colors.red,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildMonthNavigator({
    required ThemeData theme,
    required DateTime month,
    required VoidCallback onPrevious,
    required VoidCallback onNext,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left_rounded),
            tooltip: 'Previous Month',
          ),
          Expanded(
            child: Text(
              DateFormat('MMMM yyyy').format(month),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded),
            tooltip: 'Next Month',
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCalendar({
    required ThemeData theme,
    required DateTime month,
    required DateTime? selectedDate,
    required String Function(DateTime day) statusForDay,
    required Color Function(String status) colorForStatus,
    required ValueChanged<DateTime> onTapDay,
  }) {
    final first = _monthStart(month);
    final leading = first.weekday % 7;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 1000;
        final maxCalendarWidth = isDesktop ? 1100.0 : constraints.maxWidth;
        final usableWidth = maxCalendarWidth - (6 * 6);
        final dayCellWidth = usableWidth / 7;
        final dayCellHeight = isDesktop ? 88.0 : 72.0;
        final ratio = dayCellWidth / dayCellHeight;

        return Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxCalendarWidth),
            child: Column(
              children: [
                Row(
                  children: weekDays
                      .map(
                        (day) => Expanded(
                          child: Center(
                            child: Text(
                              day,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: leading + daysInMonth,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                    childAspectRatio: ratio,
                  ),
                  itemBuilder: (context, index) {
                    if (index < leading) return const SizedBox.shrink();
                    final day = index - leading + 1;
                    final date = DateTime(month.year, month.month, day);
                    final status = statusForDay(date);
                    final color = colorForStatus(status);
                    final isSelected =
                        selectedDate != null && _isSameDate(date, selectedDate);
                    final isFuture = status == 'future';

                    return InkWell(
                      onTap: () => onTapDay(date),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: isFuture
                              ? theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.2)
                              : color.withValues(alpha: 0.15),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : (isFuture
                                    ? theme.colorScheme.outline
                                        .withValues(alpha: 0.25)
                                    : color.withValues(alpha: 0.45)),
                            width: isSelected ? 1.6 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$day',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isFuture
                                    ? theme.colorScheme.onSurfaceVariant
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (!isFuture)
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _AttendanceMonthStats _attendanceMonthStats(
    DateTime month,
    Map<String, _AttendanceRecord> map,
  ) {
    final today = _todayDate();
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    var totalDays = 0;
    var present = 0;
    var absent = 0;
    var late = 0;
    var excused = 0;

    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(month.year, month.month, d);
      if (date.isAfter(today)) continue;

      totalDays++;
      final status = _attendanceStatusForDate(date, map);
      switch (status) {
        case 'present':
          present++;
          break;
        case 'late':
          late++;
          break;
        case 'excused':
          excused++;
          break;
        default:
          absent++;
      }
    }

    final percentage =
        totalDays == 0 ? 0 : ((present / totalDays) * 100).round();
    return _AttendanceMonthStats(
      totalDays: totalDays,
      present: present,
      absent: absent,
      late: late,
      excused: excused,
      percentage: percentage,
    );
  }

  _LunchMonthStats _lunchMonthStats(
    DateTime month,
    Map<String, _LunchRecord> map,
  ) {
    final today = _todayDate();
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    var totalDays = 0;
    var fullMeal = 0;
    var halfMeal = 0;
    var absent = 0;
    var notTaken = 0;
    var notMarked = 0;

    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(month.year, month.month, d);
      if (date.isAfter(today)) continue;
      totalDays++;

      final status = _lunchStatusForDate(date, map);
      switch (status) {
        case 'full meal':
          fullMeal++;
          break;
        case 'half meal':
          halfMeal++;
          break;
        case 'absent':
          absent++;
          break;
        case 'not taken':
          notTaken++;
          break;
        default:
          notMarked++;
      }
    }

    final markedRate = totalDays == 0
        ? 0
        : (((totalDays - notMarked) / totalDays) * 100).round();

    return _LunchMonthStats(
      totalDays: totalDays,
      fullMeal: fullMeal,
      halfMeal: halfMeal,
      absent: absent,
      notTaken: notTaken,
      notMarked: notMarked,
      markedRate: markedRate,
    );
  }

  Map<String, _AttendanceRecord> _attendanceByDateMap() {
    final map = <String, _AttendanceRecord>{};
    for (final item in _attendanceRecords) {
      map[_dayKey(item.date)] = item;
    }
    return map;
  }

  Map<String, _LunchRecord> _lunchByDateMap() {
    final map = <String, _LunchRecord>{};
    for (final item in _lunchRecords) {
      map[_dayKey(item.date)] = item;
    }
    return map;
  }

  String _attendanceStatusForDate(
    DateTime date,
    Map<String, _AttendanceRecord> map,
  ) {
    if (date.isAfter(_todayDate())) return 'future';
    final record = map[_dayKey(date)];
    return (record?.status ?? 'absent').toLowerCase();
  }

  String _lunchStatusForDate(
    DateTime date,
    Map<String, _LunchRecord> map,
  ) {
    if (date.isAfter(_todayDate())) return 'future';
    final record = map[_dayKey(date)];
    return (record?.status ?? 'not_marked').toLowerCase();
  }

  Widget _metricCard(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    Color accent,
  ) {
    return Container(
      constraints: const BoxConstraints(minWidth: 112),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                title,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendPill(ThemeData theme, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _segmentBadge(ThemeData theme, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _segmentBlock(
    ThemeData theme, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
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
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(icon, size: 15, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _sectionCard({
    required Widget child,
    Key? key,
  }) {
    final theme = Theme.of(context);
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _infoRow(ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          SizedBox(
            width: 102,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyHint(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _className(String? classId) {
    if (classId == null || classId.isEmpty) return 'N/A';
    try {
      final schoolClass =
          _classController.classes.firstWhere((item) => item.id == classId);
      return schoolClass.name;
    } catch (_) {
      return classId;
    }
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) {
      final milliseconds = value > 10000000000 ? value : value * 1000;
      return DateTime.fromMillisecondsSinceEpoch(milliseconds);
    }
    if (value is String) {
      final asNumber = int.tryParse(value);
      if (asNumber != null) {
        final milliseconds =
            asNumber > 10000000000 ? asNumber : asNumber * 1000;
        return DateTime.fromMillisecondsSinceEpoch(milliseconds);
      }
      return DateTime.tryParse(value);
    }
    return null;
  }

  String? _extractId(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) return raw;
    if (raw is int || raw is double) return raw.toString();
    if (raw is Map<String, dynamic>) {
      final id =
          raw['id'] ?? raw['_id'] ?? raw['student_id'] ?? raw['studentId'];
      return id?.toString();
    }
    return null;
  }

  static DateTime _monthStart(DateTime date) =>
      DateTime(date.year, date.month, 1);

  static DateTime _todayDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static String _dayKey(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
  }

  static bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'present':
        return 'Present';
      case 'late':
        return 'Late';
      case 'excused':
        return 'Excused';
      default:
        return 'Absent';
    }
  }

  String _lunchStatusLabel(String status) {
    switch (status) {
      case 'full meal':
        return 'Full Meal';
      case 'half meal':
        return 'Half Meal';
      case 'not taken':
        return 'Not Taken';
      case 'absent':
        return 'Absent';
      case 'not_marked':
        return 'Not Marked';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'present':
        return Colors.green;
      case 'late':
        return Colors.orange;
      case 'excused':
        return Colors.blue;
      case 'future':
        return Theme.of(context).colorScheme.outline;
      default:
        return Colors.red;
    }
  }

  Color _lunchStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'full meal':
        return Colors.green;
      case 'half meal':
        return Colors.orange;
      case 'not taken':
        return Colors.blueGrey;
      case 'absent':
        return Colors.red;
      case 'future':
      case 'not_marked':
        return Theme.of(context).colorScheme.outline;
      default:
        return Colors.blueGrey;
    }
  }

  Color _scoreColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.blue;
    if (percentage >= 40) return Colors.orange;
    return Colors.red;
  }
}

class _AttendanceRecord {
  final DateTime date;
  final String status;
  final String? remarks;

  const _AttendanceRecord({
    required this.date,
    required this.status,
    this.remarks,
  });
}

class _LunchRecord {
  final DateTime date;
  final String status;
  final String? remarks;

  const _LunchRecord({
    required this.date,
    required this.status,
    this.remarks,
  });
}

class _TransportBundle {
  final TransportRoute? route;
  final TransportAssignment? assignment;
  final List<TransportStop> stops;

  const _TransportBundle({
    this.route,
    this.assignment,
    this.stops = const [],
  });
}

class _AttendanceMonthStats {
  final int totalDays;
  final int present;
  final int absent;
  final int late;
  final int excused;
  final int percentage;

  const _AttendanceMonthStats({
    required this.totalDays,
    required this.present,
    required this.absent,
    required this.late,
    required this.excused,
    required this.percentage,
  });
}

class _LunchMonthStats {
  final int totalDays;
  final int fullMeal;
  final int halfMeal;
  final int absent;
  final int notTaken;
  final int notMarked;
  final int markedRate;

  const _LunchMonthStats({
    required this.totalDays,
    required this.fullMeal,
    required this.halfMeal,
    required this.absent,
    required this.notTaken,
    required this.notMarked,
    required this.markedRate,
  });
}
