import 'package:campus_care/controllers/class_controller.dart';
import 'package:campus_care/models/teacher/teacher.dart';
import 'package:campus_care/screens/admin/teacher_management/add_teacher_screen.dart';
import 'package:campus_care/services/api/timetable_api_service.dart';
import 'package:campus_care/services/teacher_service.dart';
import 'package:campus_care/utils/upload_url_utils.dart';
import 'package:campus_care/widgets/admin/admin_page_header.dart';
import 'package:campus_care/widgets/common/file_display_widget.dart';
import 'package:campus_care/widgets/common/section_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

enum _TeacherDetailsTab {
  details,
  assignedClasses,
}

class TeacherDetailsScreen extends StatefulWidget {
  final Teacher teacher;

  const TeacherDetailsScreen({super.key, required this.teacher});

  @override
  State<TeacherDetailsScreen> createState() => _TeacherDetailsScreenState();
}

class _TeacherDetailsScreenState extends State<TeacherDetailsScreen> {
  final TimetableApiService _timetableApi = TimetableApiService();
  late final ClassController _classController;
  late Teacher _teacher;

  bool _isLoading = true;
  String? _error;
  List<_Slot> _slots = const [];
  _TeacherDetailsTab _activeTab = _TeacherDetailsTab.details;

  @override
  void initState() {
    super.initState();
    _teacher = widget.teacher;
    _classController = Get.isRegistered<ClassController>()
        ? Get.find<ClassController>()
        : Get.put(ClassController());
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      if (_classController.classes.isEmpty) {
        await _classController.fetchClasses();
      }
      _teacher = (await TeacherService.getTeacherById(_teacher.id)) ?? _teacher;
      final rows = await _timetableApi.getTimetables(teacherId: _teacher.id);
      _slots = rows
          .whereType<Map<String, dynamic>>()
          .map(_Slot.fromMap)
          .where((e) =>
              e.classId.isNotEmpty && e.section.isNotEmpty && e.day.isNotEmpty)
          .toList()
        ..sort((a, b) => a.sortKey.compareTo(b.sortKey));
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Map<String, List<_Slot>> get _byClassSection {
    final map = <String, List<_Slot>>{};
    for (final slot in _slots) {
      final key = '${slot.classId}|${slot.section}';
      map.putIfAbsent(key, () => <_Slot>[]).add(slot);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          AdminPageHeader(
            title: 'Teacher Details',
            subtitle: 'Complete profile and assigned classes details',
            icon: Icons.badge_rounded,
            showBreadcrumb: true,
            breadcrumbLabel: 'Teachers',
            showBackButton: true,
            actions: [
              HeaderActionButton(
                  icon: Icons.refresh_rounded,
                  label: 'Refresh',
                  onPressed: _load),
              const SizedBox(width: 8),
              HeaderActionButton(
                icon: Icons.edit_rounded,
                label: 'Edit',
                onPressed: () =>
                    Get.to(() => AddTeacherScreen(teacher: _teacher)),
              ),
            ],
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (_error != null)
                          _card(
                            context,
                            child: Text(
                                'Some details failed to load. Refresh to retry.'),
                          ),
                        _hero(context),
                        const SizedBox(height: 12),
                        _buildSectionTabs(context),
                        const SizedBox(height: 12),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: _activeTab == _TeacherDetailsTab.details
                              ? _profileCard(context)
                              : _assignedClassesCard(context),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTabs(BuildContext context) {
    final theme = Theme.of(context);
    final tabs = <_TeacherDetailsTab, String>{
      _TeacherDetailsTab.details: 'Details',
      _TeacherDetailsTab.assignedClasses: 'Assigned Classes',
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

  Widget _hero(BuildContext context) {
    final theme = Theme.of(context);
    final profileImageUrls =
        UploadUrlUtils.buildCandidateUrls(_teacher.profileImageUrl);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(colors: [
          theme.colorScheme.primary,
          theme.colorScheme.primary.withValues(alpha: 0.75)
        ]),
      ),
      child: Row(children: [
        ProfileAvatarWidget(
          size: 60,
          imageUrls: profileImageUrls,
          displayName: _teacher.fullName,
          enablePreview: true,
          backgroundColor: Colors.white24,
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_teacher.fullName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            Text('ID: ${_teacher.id}',
                style: const TextStyle(color: Colors.white70)),
            Text(
                '${_byClassSection.length} assigned class sections | ${_slots.length} periods/week',
                style: const TextStyle(color: Colors.white70)),
          ]),
        ),
      ]),
    );
  }

  Widget _profileCard(BuildContext context) {
    return _card(
      key: const ValueKey('teacher_details_tab'),
      context,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionHeader(
            title: 'Teacher Profile',
            subtitle: 'Personal and professional information'),
        const SizedBox(height: 8),
        _row(Icons.person_rounded, 'Full Name', _teacher.fullName),
        _row(Icons.email_rounded, 'Email', _teacher.email),
        _row(
            Icons.phone_rounded,
            'Phone',
            _teacher.phone?.trim().isNotEmpty == true
                ? _teacher.phone!
                : 'N/A'),
        _row(
            Icons.location_on_rounded,
            'Address',
            _teacher.address?.trim().isNotEmpty == true
                ? _teacher.address!
                : 'N/A'),
        _row(
            Icons.business_rounded,
            'Department',
            _teacher.department?.trim().isNotEmpty == true
                ? _teacher.department!
                : 'N/A'),
        _row(
            Icons.calendar_today_rounded,
            'Hire Date',
            _teacher.hireDate != null
                ? DateFormat('dd MMM yyyy').format(_teacher.hireDate!)
                : 'N/A'),
        _row(Icons.verified_rounded, 'Email Verified',
            _teacher.isEmailVerified ? 'Yes' : 'No'),
      ]),
    );
  }

  Widget _assignedClassesCard(BuildContext context) {
    final groups = _byClassSection.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return _card(
      key: const ValueKey('teacher_assigned_classes_tab'),
      context,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionHeader(
            title: 'Assigned Classes',
            subtitle: 'Class and section-wise teaching details'),
        const SizedBox(height: 8),
        if (groups.isEmpty) const Text('No classes assigned yet.'),
        ...groups.map((entry) {
          final parts = entry.key.split('|');
          final className = _className(parts[0]);
          final section = parts.length > 1 ? parts[1] : 'N/A';
          final slots = entry.value;
          final subjects = slots
              .map((e) => e.subject)
              .toSet()
              .where((e) => e.isNotEmpty)
              .join(', ');
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ExpansionTile(
              title: Text('$className - Section $section'),
              subtitle: Text(
                  '${slots.length} periods/week${subjects.isEmpty ? '' : ' | $subjects'}'),
              children: slots
                  .map((slot) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.schedule_rounded),
                        title: Text(slot.subject.isEmpty
                            ? 'Subject Not Set'
                            : slot.subject),
                        subtitle: Text(
                            '${slot.day} | ${slot.timeRange}${slot.room.isNotEmpty ? ' | Room ${slot.room}' : ''}'),
                      ))
                  .toList(),
            ),
          );
        }),
      ]),
    );
  }

  Widget _card(BuildContext context, {required Widget child, Key? key}) {
    final theme = Theme.of(context);
    return Container(
      key: key,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: child,
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 16),
        const SizedBox(width: 8),
        SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600))),
        Expanded(child: Text(value)),
      ]),
    );
  }

  String _className(String id) {
    if (id.isEmpty) {
      return 'Unknown Class';
    }
    try {
      return _classController.classes.firstWhere((e) => e.id == id).name;
    } catch (_) {
      return id;
    }
  }
}

class _Slot {
  final String classId;
  final String section;
  final String day;
  final String start;
  final String end;
  final String subject;
  final String room;

  const _Slot({
    required this.classId,
    required this.section,
    required this.day,
    required this.start,
    required this.end,
    required this.subject,
    required this.room,
  });

  String get sortKey => '${_dayOrder(day)}|$start';
  String get timeRange => '${_fmt(start)} - ${_fmt(end)}';

  factory _Slot.fromMap(Map<String, dynamic> json) {
    String s(dynamic v) => v == null ? '' : v.toString().trim();
    String id(dynamic v) {
      if (v is Map<String, dynamic>) {
        return s(v['_id'] ?? v['id'] ?? v['value']);
      }
      return s(v);
    }

    return _Slot(
      classId: id(json['class'] ?? json['class_id'] ?? json['classId']),
      section: s(json['section']),
      day: s(json['dayOfWeek'] ?? json['day_of_week'] ?? json['day']),
      start: s(json['startTime'] ?? json['start_time']),
      end: s(json['endTime'] ?? json['end_time']),
      subject:
          s(json['subject'] ?? json['subject_name'] ?? json['subjectName']),
      room: s(json['room']),
    );
  }

  static String _dayOrder(String day) {
    const map = {
      'monday': '1',
      'tuesday': '2',
      'wednesday': '3',
      'thursday': '4',
      'friday': '5',
      'saturday': '6',
      'sunday': '7'
    };
    return map[day.toLowerCase()] ?? '9';
  }

  static String _fmt(String value) {
    if (value.isEmpty) {
      return '--';
    }
    for (final p in const ['HH:mm', 'H:mm', 'HH:mm:ss', 'H:mm:ss', 'h:mm a']) {
      try {
        return DateFormat('hh:mm a').format(DateFormat(p).parseLoose(value));
      } catch (_) {}
    }
    return value;
  }
}
