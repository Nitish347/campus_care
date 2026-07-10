import 'package:campus_care/controllers/teacher_attendance_controller.dart';
import 'package:campus_care/controllers/teacher_controller.dart';
import 'package:campus_care/models/teacher/teacher.dart';
import 'package:campus_care/models/teacher_attendance_model.dart';
import 'package:campus_care/widgets/admin/admin_page_header.dart';
import 'package:campus_care/widgets/admin/confirm_dialog.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/common/section_header.dart';
import 'package:campus_care/widgets/inputs/custom_dropdown.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' as latlng;

class TeacherAttendanceManagementScreen extends StatefulWidget {
  const TeacherAttendanceManagementScreen({super.key});

  @override
  State<TeacherAttendanceManagementScreen> createState() =>
      _TeacherAttendanceManagementScreenState();
}

class _TeacherAttendanceManagementScreenState
    extends State<TeacherAttendanceManagementScreen>
    with SingleTickerProviderStateMixin {
  static const _mapInteractionOptions = InteractionOptions(
    flags: InteractiveFlag.all & ~InteractiveFlag.scrollWheelZoom,
  );

  late final TeacherAttendanceController _controller;
  late final TeacherController _teacherController;
  late final TabController _tabController;
  int _currentTabIndex = 0;

  DateTime _logStartDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _logEndDate = DateTime.now();
  String _selectedStatus = 'all';
  String _selectedDatePreset = '30d';

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<TeacherAttendanceController>()
        ? Get.find<TeacherAttendanceController>()
        : Get.put(TeacherAttendanceController());
    _teacherController = Get.isRegistered<TeacherController>()
        ? Get.find<TeacherController>()
        : Get.put(TeacherController());
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging &&
          _currentTabIndex != _tabController.index) {
        setState(() => _currentTabIndex = _tabController.index);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAdminData();
      _teacherController.loadTeachers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showGeofenceForm({TeacherGeofence? existing}) async {
    final formKey = GlobalKey<FormState>();
    final mapController = MapController();
    final name = TextEditingController(text: existing?.name ?? '');
    final latitude =
        TextEditingController(text: existing?.latitude.toString() ?? '');
    final longitude =
        TextEditingController(text: existing?.longitude.toString() ?? '');
    final radius =
        TextEditingController(text: existing?.radiusMeters.toString() ?? '150');
    bool isActive = existing?.isActive ?? true;
    bool isSubmitting = false;
    bool isFetchingLocation = false;
    bool useCurrentLocation = existing == null;

    latlng.LatLng? previewPoint() {
      final lat = double.tryParse(latitude.text.trim());
      final lng = double.tryParse(longitude.text.trim());
      if (lat == null || lng == null) return null;
      if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return null;
      return latlng.LatLng(lat, lng);
    }

    double previewRadius() {
      final parsed = double.tryParse(radius.text.trim());
      return parsed == null || parsed <= 0 ? 150 : parsed;
    }

    Future<void> fillCurrentLocation(
      void Function(void Function()) setState,
    ) async {
      try {
        setState(() => isFetchingLocation = true);
        final position = await _controller.getCurrentPositionForGeofence();
        latitude.text = position.latitude.toStringAsFixed(7);
        longitude.text = position.longitude.toStringAsFixed(7);
        final point = latlng.LatLng(position.latitude, position.longitude);
        mapController.move(point, 17);
        setState(() => useCurrentLocation = true);
      } catch (e) {
        Get.snackbar(
          'Location unavailable',
          e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        setState(() => isFetchingLocation = false);
      }
    }

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? 'Add Geofence' : 'Edit Geofence'),
          content: SizedBox(
            width: 680,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      controller: name,
                      labelText: 'Name',
                      hintText: 'Main campus',
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Required'
                              : null,
                    ),
                    const SizedBox(height: 10),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: false,
                          icon: Icon(Icons.edit_location_alt_rounded),
                          label: Text('Manual'),
                        ),
                        ButtonSegment(
                          value: true,
                          icon: Icon(Icons.my_location_rounded),
                          label: Text('Current GPS'),
                        ),
                      ],
                      selected: {useCurrentLocation},
                      onSelectionChanged: isSubmitting || isFetchingLocation
                          ? null
                          : (selection) async {
                              final selected = selection.first;
                              setState(() => useCurrentLocation = selected);
                              if (selected) {
                                await fillCurrentLocation(setState);
                              }
                            },
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: isSubmitting || isFetchingLocation
                            ? null
                            : () => fillCurrentLocation(setState),
                        icon: isFetchingLocation
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.gps_fixed_rounded),
                        label: Text(isFetchingLocation
                            ? 'Locating'
                            : 'Use my current location'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: latitude,
                      labelText: 'Latitude',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) => double.tryParse(value ?? '') == null
                          ? 'Enter valid latitude'
                          : null,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: longitude,
                      labelText: 'Longitude',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) => double.tryParse(value ?? '') == null
                          ? 'Enter valid longitude'
                          : null,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: radius,
                      labelText: 'Radius in meters',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        final parsed = double.tryParse(value ?? '');
                        return parsed == null || parsed <= 0
                            ? 'Enter a radius above 0'
                            : null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    _buildMapPreview(
                      mapController: mapController,
                      point: previewPoint(),
                      radiusMeters: previewRadius(),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Active'),
                      value: isActive,
                      onChanged: isSubmitting
                          ? null
                          : (value) => setState(() => isActive = value),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setState(() => isSubmitting = true);
                      final geofence = TeacherGeofence(
                        id: existing?.id ?? '',
                        name: name.text.trim(),
                        latitude: double.parse(latitude.text.trim()),
                        longitude: double.parse(longitude.text.trim()),
                        radiusMeters: double.parse(radius.text.trim()),
                        isActive: isActive,
                        instituteId: existing?.instituteId ?? '',
                        createdAt: existing?.createdAt ?? DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      final ok = await _controller.saveGeofence(geofence);
                      if (!ok) {
                        setState(() => isSubmitting = false);
                        return;
                      }
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(existing == null ? 'Create' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showManualAttendanceForm() async {
    final formKey = GlobalKey<FormState>();
    final remarksController = TextEditingController();
    String? selectedTeacherId;
    DateTime selectedDate = DateTime.now();
    TimeOfDay checkInTime = TimeOfDay.now();
    TimeOfDay? checkOutTime;
    bool isSubmitting = false;

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Manual Teacher Attendance'),
          content: SizedBox(
            width: 560,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(() {
                      final teachers = _teacherController.teachers;
                      return CustomDropdown<String>(
                        labelText: 'Teacher *',
                        hintText: teachers.isEmpty
                            ? 'No teachers found'
                            : 'Select teacher',
                        value: selectedTeacherId,
                        prefixIcon: const Icon(Icons.person_rounded),
                        enabled: teachers.isNotEmpty && !isSubmitting,
                        items: teachers
                            .map(
                              (teacher) => DropdownMenuItem<String>(
                                value: teacher.id,
                                child: Text(_teacherLabel(teacher)),
                              ),
                            )
                            .toList(),
                        validator: (value) =>
                            value == null ? 'Select a teacher' : null,
                        onChanged: (value) =>
                            setState(() => selectedTeacherId = value),
                      );
                    }),
                    const SizedBox(height: 12),
                    _dialogPickerTile(
                      icon: Icons.event_rounded,
                      label: 'Date',
                      value: _fmtDate(selectedDate),
                      onTap: isSubmitting
                          ? null
                          : () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now()
                                    .subtract(const Duration(days: 365 * 3)),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                              );
                              if (picked == null) return;
                              setState(() => selectedDate = picked);
                            },
                    ),
                    const SizedBox(height: 12),
                    _dialogPickerTile(
                      icon: Icons.login_rounded,
                      label: 'Check in time',
                      value: _fmtTimeOfDay(checkInTime),
                      onTap: isSubmitting
                          ? null
                          : () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: checkInTime,
                              );
                              if (picked == null) return;
                              setState(() => checkInTime = picked);
                            },
                    ),
                    const SizedBox(height: 12),
                    _dialogPickerTile(
                      icon: Icons.logout_rounded,
                      label: 'Check out time',
                      value: checkOutTime == null
                          ? 'Optional'
                          : _fmtTimeOfDay(checkOutTime!),
                      trailing: checkOutTime == null
                          ? null
                          : IconButton(
                              tooltip: 'Clear check out',
                              icon: const Icon(Icons.close_rounded),
                              onPressed: isSubmitting
                                  ? null
                                  : () => setState(() => checkOutTime = null),
                            ),
                      onTap: isSubmitting
                          ? null
                          : () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: checkOutTime ?? checkInTime,
                              );
                              if (picked == null) return;
                              setState(() => checkOutTime = picked);
                            },
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: remarksController,
                      labelText: 'Remarks',
                      hintText: 'Manual entry reason',
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      final checkInAt =
                          _combineDateAndTime(selectedDate, checkInTime);
                      final checkOutAt = checkOutTime == null
                          ? null
                          : _combineDateAndTime(selectedDate, checkOutTime!);
                      if (checkOutAt != null &&
                          checkOutAt.isBefore(checkInAt)) {
                        Get.snackbar(
                          'Invalid time',
                          'Check out time must be after check in time',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }

                      setState(() => isSubmitting = true);
                      final ok = await _controller.createManualRecord(
                        teacherId: selectedTeacherId!,
                        date: selectedDate,
                        checkInAt: checkInAt,
                        checkOutAt: checkOutAt,
                        remarks: remarksController.text,
                        filterStartDate: _logStartDate,
                        filterEndDate: _endOfDay(_logEndDate),
                        filterStatus: _selectedStatus,
                      );
                      if (!ok) {
                        setState(() => isSubmitting = false);
                        return;
                      }
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showManualCheckOutForm(TeacherAttendanceLog record) async {
    final remarksController = TextEditingController();
    final initial = record.checkInAt?.toLocal() ?? DateTime.now();
    DateTime selectedDate = DateTime(
      initial.year,
      initial.month,
      initial.day,
    );
    TimeOfDay checkOutTime = TimeOfDay.fromDateTime(DateTime.now());
    if (_combineDateAndTime(selectedDate, checkOutTime).isBefore(initial)) {
      checkOutTime =
          TimeOfDay.fromDateTime(initial.add(const Duration(hours: 1)));
    }
    bool isSubmitting = false;

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add Checkout - ${record.teacherName}'),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogPickerTile(
                  icon: Icons.login_rounded,
                  label: 'Check in',
                  value:
                      '${_fmtDate(record.date)} at ${_fmtTime(record.checkInAt)}',
                  onTap: null,
                ),
                const SizedBox(height: 12),
                _dialogPickerTile(
                  icon: Icons.event_rounded,
                  label: 'Checkout date',
                  value: _fmtDate(selectedDate),
                  onTap: isSubmitting
                      ? null
                      : () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(
                              record.date.year,
                              record.date.month,
                              record.date.day,
                            ),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked == null) return;
                          setState(() => selectedDate = picked);
                        },
                ),
                const SizedBox(height: 12),
                _dialogPickerTile(
                  icon: Icons.logout_rounded,
                  label: 'Checkout time',
                  value: _fmtTimeOfDay(checkOutTime),
                  onTap: isSubmitting
                      ? null
                      : () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: checkOutTime,
                          );
                          if (picked == null) return;
                          setState(() => checkOutTime = picked);
                        },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: remarksController,
                  labelText: 'Remarks',
                  hintText: 'Teacher forgot to check out',
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final checkOutAt =
                          _combineDateAndTime(selectedDate, checkOutTime);
                      if (record.checkInAt != null &&
                          checkOutAt.isBefore(record.checkInAt!.toLocal())) {
                        Get.snackbar(
                          'Invalid time',
                          'Checkout must be after check in time',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }
                      setState(() => isSubmitting = true);
                      final ok = await _controller.addManualCheckOut(
                        recordId: record.id,
                        checkOutAt: checkOutAt,
                        remarks: remarksController.text,
                        filterStartDate: _logStartDate,
                        filterEndDate: _endOfDay(_logEndDate),
                        filterStatus: _selectedStatus,
                      );
                      if (!ok) {
                        setState(() => isSubmitting = false);
                        return;
                      }
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Add Checkout'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteGeofence(TeacherGeofence geofence) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Delete Geofence',
      message: 'Delete ${geofence.name}?',
      confirmLabel: 'Delete',
      isDanger: true,
      icon: Icons.delete_forever_rounded,
    );
    if (ok) {
      await _controller.deleteGeofence(geofence.id);
    }
  }

  DateTime _endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59);

  Future<void> _refreshAdminData() {
    return _controller.loadAdminData(
      startDate: DateTime(
        _logStartDate.year,
        _logStartDate.month,
        _logStartDate.day,
      ),
      endDate: _endOfDay(_logEndDate),
      status: _selectedStatus,
    );
  }

  String _fmtDate(DateTime date) => DateFormat('dd MMM yyyy').format(date);
  String _fmtTime(DateTime? date) =>
      date == null ? '-' : DateFormat('hh:mm a').format(date.toLocal());
  String _fmtTimeOfDay(TimeOfDay time) {
    final date = DateTime(2024, 1, 1, time.hour, time.minute);
    return DateFormat('hh:mm a').format(date);
  }

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String _teacherLabel(Teacher teacher) {
    final name = teacher.fullName.trim();
    return name.isEmpty ? teacher.email : '$name - ${teacher.email}';
  }

  Widget _dialogPickerTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback? onTap,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color:
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            trailing ?? const Icon(Icons.keyboard_arrow_down_rounded),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          AdminPageHeader(
            title: const Text('Teacher Attendance'),
            subtitle: 'Set campus geofences and review teacher check-ins',
            icon: Icons.location_on_rounded,
            showBackButton: true,
            showBreadcrumb: true,
            breadcrumbLabel: 'Teacher Attendance',
            actions: [
              HeaderActionButton(
                icon: Icons.refresh_rounded,
                label: 'Refresh',
                onPressed: _refreshAdminData,
              ),
              const SizedBox(width: 8),
              HeaderActionButton(
                icon: Icons.add_location_alt_rounded,
                label: 'Geofence',
                onPressed: () => _showGeofenceForm(),
              ),
              const SizedBox(width: 8),
              HeaderActionButton(
                icon: Icons.edit_calendar_rounded,
                label: 'Manual',
                onPressed: _showManualAttendanceForm,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.22),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildAnimatedTab(
                      title: 'Geofences',
                      icon: Icons.location_on_rounded,
                      index: 0,
                      accent: const Color(0xFF2563EB),
                    ),
                  ),
                  Expanded(
                    child: _buildAnimatedTab(
                      title: 'Attendance Logs',
                      icon: Icons.fact_check_rounded,
                      index: 1,
                      accent: const Color(0xFF059669),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ResponsivePadding(
              child: Obx(() {
                if (_controller.isLoading.value &&
                    _controller.geofences.isEmpty &&
                    _controller.records.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGeofenceList(context),
                    _buildRecordList(context),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTab({
    required String title,
    required IconData icon,
    required int index,
    required Color accent,
  }) {
    final selected = _currentTabIndex == index;
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
        setState(() => _currentTabIndex = index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: selected ? Colors.white : Colors.transparent,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selected ? accent : Colors.black54),
            const SizedBox(width: 7),
            Flexible(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? accent : Colors.black54,
                  fontSize: 13.5,
                ),
                child: Text(title, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeofenceList(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        SectionHeader(
          title: 'Campus Geofences',
          subtitle:
              'Add manual coordinates or capture the campus point from GPS',
          action: FilledButton.icon(
            onPressed: () => _showGeofenceForm(),
            icon: const Icon(Icons.add_location_alt_rounded, size: 18),
            label: const Text('Add Geofence'),
          ),
        ),
        const SizedBox(height: 12),
        _buildGeofenceSummary(theme),
        const SizedBox(height: 12),
        Expanded(
          child: _controller.geofences.isEmpty
              ? const EmptyState(
                  icon: Icons.location_off_outlined,
                  title: 'No geofence yet',
                  message: 'Add your campus location and allowed radius.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: _controller.geofences.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final geofence = _controller.geofences[index];
                    return _buildGeofenceCard(theme, geofence);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildGeofenceSummary(ThemeData theme) {
    final total = _controller.geofences.length;
    final active = _controller.geofences.where((item) => item.isActive).length;
    final inactive = total - active;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 760;
        final cards = [
          _buildMetricTile(
            theme,
            icon: Icons.public_rounded,
            label: 'Total zones',
            value: '$total',
            color: const Color(0xFF2563EB),
          ),
          _buildMetricTile(
            theme,
            icon: Icons.my_location_rounded,
            label: 'Active zones',
            value: '$active',
            color: const Color(0xFF059669),
          ),
          _buildMetricTile(
            theme,
            icon: Icons.location_disabled_rounded,
            label: 'Inactive zones',
            value: '$inactive',
            color: const Color(0xFF64748B),
          ),
        ];

        if (isWide) {
          return Row(
            children: cards
                .map(
                  (card) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: card == cards.last ? 0 : 10,
                      ),
                      child: card,
                    ),
                  ),
                )
                .toList(),
          );
        }

        return Column(
          children: cards
              .map(
                (card) => Padding(
                  padding: EdgeInsets.only(bottom: card == cards.last ? 0 : 10),
                  child: card,
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildMetricTile(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeofenceCard(ThemeData theme, TeacherGeofence geofence) {
    final activeColor =
        geofence.isActive ? const Color(0xFF059669) : const Color(0xFF64748B);

    return InkWell(
      onTap: () => _showGeofenceDetails(geofence),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: activeColor.withValues(alpha: 0.14),
              child: Icon(
                geofence.isActive
                    ? Icons.my_location_rounded
                    : Icons.location_disabled_rounded,
                color: activeColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    geofence.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildStatusPill(
                        theme,
                        geofence.isActive ? 'Active' : 'Inactive',
                        activeColor,
                      ),
                      _buildInfoPill(
                        theme,
                        Icons.radio_button_checked_rounded,
                        '${geofence.radiusMeters.toStringAsFixed(0)} m radius',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showGeofenceDetails(TeacherGeofence geofence) async {
    final theme = Theme.of(context);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(20, 18, 12, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        actionsPadding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        title: Row(
          children: [
            Expanded(
              child: Text(
                geofence.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              tooltip: 'Close',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
        content: SizedBox(
          width: 720,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSingleGeofenceMap(theme, geofence),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildStatusPill(
                      theme,
                      geofence.isActive ? 'Active' : 'Inactive',
                      geofence.isActive
                          ? const Color(0xFF059669)
                          : const Color(0xFF64748B),
                    ),
                    _buildInfoPill(
                      theme,
                      Icons.pin_drop_rounded,
                      '${geofence.latitude.toStringAsFixed(7)}, ${geofence.longitude.toStringAsFixed(7)}',
                    ),
                    _buildInfoPill(
                      theme,
                      Icons.radio_button_checked_rounded,
                      '${geofence.radiusMeters.toStringAsFixed(0)} m radius',
                    ),
                    _buildInfoPill(
                      theme,
                      Icons.update_rounded,
                      'Updated ${_fmtDate(geofence.updatedAt)}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await _confirmDeleteGeofence(geofence);
            },
            icon: const Icon(Icons.delete_rounded),
            label: const Text('Delete'),
          ),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showGeofenceForm(existing: geofence);
            },
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleGeofenceMap(
    ThemeData theme,
    TeacherGeofence geofence,
  ) {
    final mapController = MapController();
    final point = latlng.LatLng(geofence.latitude, geofence.longitude);
    final color =
        geofence.isActive ? const Color(0xFF059669) : const Color(0xFF64748B);

    return Container(
      height: 340,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: point,
              initialZoom: 17,
              interactionOptions: _mapInteractionOptions,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.campuscare.app',
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: point,
                    radius: geofence.radiusMeters,
                    useRadiusInMeter: true,
                    color: color.withValues(alpha: 0.16),
                    borderColor: color,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: point,
                    width: 44,
                    height: 44,
                    child: const Icon(
                      Icons.location_pin,
                      color: Color(0xFFDC2626),
                      size: 42,
                    ),
                  ),
                ],
              ),
            ],
          ),
          _buildMapZoomControls(mapController),
        ],
      ),
    );
  }

  Widget _buildMapZoomControls(MapController mapController) {
    return Positioned(
      top: 10,
      right: 10,
      child: Material(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        elevation: 3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Zoom in',
              icon: const Icon(Icons.add_rounded),
              onPressed: () => _zoomMap(mapController, 1),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            IconButton(
              tooltip: 'Zoom out',
              icon: const Icon(Icons.remove_rounded),
              onPressed: () => _zoomMap(mapController, -1),
            ),
          ],
        ),
      ),
    );
  }

  void _zoomMap(MapController mapController, double delta) {
    final camera = mapController.camera;
    final zoom = (camera.zoom + delta).clamp(3.0, 19.0).toDouble();
    mapController.move(camera.center, zoom);
  }

  Widget _buildMapPreview({
    required MapController mapController,
    required latlng.LatLng? point,
    required double radiusMeters,
  }) {
    final theme = Theme.of(context);
    final center = point ?? const latlng.LatLng(20.5937, 78.9629);

    return Container(
      height: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.18),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: point == null ? 4.5 : 17,
              interactionOptions: _mapInteractionOptions,
              onTap: (_, tappedPoint) {
                // The dialog preview is read-only for map taps; use Manual fields
                // or Current GPS so the chosen source stays explicit.
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.campuscare.app',
              ),
              if (point != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: point,
                      radius: radiusMeters,
                      useRadiusInMeter: true,
                      color: const Color(0xFF2563EB).withValues(alpha: 0.18),
                      borderColor: const Color(0xFF2563EB),
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
              if (point != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: point,
                      width: 44,
                      height: 44,
                      child: const Icon(
                        Icons.location_pin,
                        color: Color(0xFFDC2626),
                        size: 42,
                      ),
                    ),
                  ],
                ),
              if (point == null)
                Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Enter coordinates or use current GPS'),
                  ),
                ),
            ],
          ),
          _buildMapZoomControls(mapController),
        ],
      ),
    );
  }

  Widget _buildRecordList(BuildContext context) {
    final theme = Theme.of(context);
    final groupedRecords = _groupRecordsByDate(_controller.records);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        SectionHeader(
          title: 'Attendance Logs',
          subtitle: 'Filter records by date and check-in status',
          action: _controller.isLoading.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  tooltip: 'Refresh',
                  onPressed: _refreshAdminData,
                  icon: const Icon(Icons.refresh_rounded),
                ),
        ),
        const SizedBox(height: 12),
        _buildLogFilterCard(theme),
        const SizedBox(height: 12),
        Expanded(
          child: _controller.records.isEmpty
              ? const EmptyState(
                  icon: Icons.fact_check_outlined,
                  title: 'No teacher logs',
                  message: 'Try a different date range or status filter.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: groupedRecords.length,
                  itemBuilder: (context, groupIndex) {
                    final group = groupedRecords[groupIndex];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom:
                            groupIndex == groupedRecords.length - 1 ? 0 : 14,
                      ),
                      child: _buildDateGroup(theme, group.key, group.value),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildLogFilterCard(ThemeData theme) {
    final subtitle = '${_fmtDate(_logStartDate)} to ${_fmtDate(_logEndDate)}';
    final checkedOut =
        _controller.records.where((record) => record.isCheckedOut).length;
    final pending = _controller.records.length - checkedOut;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildDatePresetChip('today', 'Today'),
              _buildDatePresetChip('7d', 'Last 7 days'),
              _buildDatePresetChip('30d', 'Last 30 days'),
              _buildDatePresetChip('custom', 'Custom'),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 720;
              final dateControls = [
                _buildDateButton(
                  theme,
                  label: 'From',
                  value: _fmtDate(_logStartDate),
                  onTap: () => _pickLogDate(isStart: true),
                ),
                _buildDateButton(
                  theme,
                  label: 'To',
                  value: _fmtDate(_logEndDate),
                  onTap: () => _pickLogDate(isStart: false),
                ),
              ];

              if (wide) {
                return Row(
                  children: [
                    Expanded(child: dateControls[0]),
                    const SizedBox(width: 10),
                    Expanded(child: dateControls[1]),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatusDropdown(theme)),
                  ],
                );
              }

              return Column(
                children: [
                  dateControls[0],
                  const SizedBox(height: 10),
                  dateControls[1],
                  const SizedBox(height: 10),
                  _buildStatusDropdown(theme),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildInfoPill(
                theme,
                Icons.date_range_rounded,
                subtitle,
              ),
              _buildInfoPill(
                theme,
                Icons.receipt_long_rounded,
                '${_controller.records.length} records',
              ),
              _buildInfoPill(
                theme,
                Icons.done_all_rounded,
                '$checkedOut completed',
              ),
              _buildInfoPill(
                theme,
                Icons.login_rounded,
                '$pending checked in',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePresetChip(String value, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedDatePreset == value,
      onSelected: (_) => _applyDatePreset(value),
      avatar: Icon(
        value == 'custom' ? Icons.tune_rounded : Icons.calendar_today_rounded,
        size: 16,
      ),
    );
  }

  Widget _buildDateButton(
    ThemeData theme, {
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color:
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(Icons.event_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(ThemeData theme) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedStatus,
      decoration: InputDecoration(
        labelText: 'Status',
        prefixIcon: const Icon(Icons.fact_check_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: const [
        DropdownMenuItem(value: 'all', child: Text('All records')),
        DropdownMenuItem(value: 'checked_in', child: Text('Checked in')),
        DropdownMenuItem(value: 'checked_out', child: Text('Checked out')),
      ],
      onChanged: (value) async {
        if (value == null) return;
        setState(() => _selectedStatus = value);
        await _refreshAdminData();
      },
    );
  }

  Future<void> _applyDatePreset(String value) async {
    final now = DateTime.now();
    setState(() {
      _selectedDatePreset = value;
      if (value == 'today') {
        _logStartDate = now;
        _logEndDate = now;
      } else if (value == '7d') {
        _logStartDate = now.subtract(const Duration(days: 6));
        _logEndDate = now;
      } else if (value == '30d') {
        _logStartDate = now.subtract(const Duration(days: 30));
        _logEndDate = now;
      }
    });

    if (value != 'custom') {
      await _refreshAdminData();
    }
  }

  Future<void> _pickLogDate({required bool isStart}) async {
    final initialDate = isStart ? _logStartDate : _logEndDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked == null || !mounted) return;

    setState(() {
      _selectedDatePreset = 'custom';
      if (isStart) {
        _logStartDate = picked;
        if (_logEndDate.isBefore(_logStartDate)) {
          _logEndDate = _logStartDate;
        }
      } else {
        _logEndDate = picked;
        if (_logStartDate.isAfter(_logEndDate)) {
          _logStartDate = _logEndDate;
        }
      }
    });
    await _refreshAdminData();
  }

  List<MapEntry<DateTime, List<TeacherAttendanceLog>>> _groupRecordsByDate(
    List<TeacherAttendanceLog> records,
  ) {
    final groups = <DateTime, List<TeacherAttendanceLog>>{};
    for (final record in records) {
      final localDate = record.date.toLocal();
      final day = DateTime(localDate.year, localDate.month, localDate.day);
      groups.putIfAbsent(day, () => []).add(record);
    }

    final entries = groups.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    for (final entry in entries) {
      entry.value.sort((a, b) {
        final aTime = a.checkInAt ?? a.date;
        final bTime = b.checkInAt ?? b.date;
        return bTime.compareTo(aTime);
      });
    }
    return entries;
  }

  Widget _buildDateGroup(
    ThemeData theme,
    DateTime date,
    List<TeacherAttendanceLog> records,
  ) {
    final checkedOut = records.where((record) => record.isCheckedOut).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_month_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _fmtDate(date),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '$checkedOut/${records.length} completed',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...records.map(
          (record) => Padding(
            padding: EdgeInsets.only(bottom: record == records.last ? 0 : 10),
            child: _buildRecordCard(theme, record),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordCard(ThemeData theme, TeacherAttendanceLog record) {
    final checkedOut = record.isCheckedOut;
    final statusColor =
        checkedOut ? const Color(0xFF2563EB) : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: statusColor.withValues(alpha: 0.14),
            child: Icon(
              checkedOut ? Icons.done_all_rounded : Icons.login_rounded,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        record.teacherName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildStatusPill(
                      theme,
                      checkedOut ? 'Checked out' : 'Checked in',
                      statusColor,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoPill(
                      theme,
                      Icons.login_rounded,
                      'In ${_fmtTime(record.checkInAt)}',
                    ),
                    _buildInfoPill(
                      theme,
                      Icons.logout_rounded,
                      'Out ${_fmtTime(record.checkOutAt)}',
                    ),
                    _buildInfoPill(
                      theme,
                      Icons.near_me_rounded,
                      'In ${record.checkInDistanceMeters?.toStringAsFixed(1) ?? '-'} m',
                    ),
                    _buildInfoPill(
                      theme,
                      Icons.social_distance_rounded,
                      'Out ${record.checkOutDistanceMeters?.toStringAsFixed(1) ?? '-'} m',
                    ),
                    if (!checkedOut)
                      OutlinedButton.icon(
                        onPressed: () => _showManualCheckOutForm(record),
                        icon: const Icon(Icons.edit_calendar_rounded, size: 16),
                        label: const Text('Add checkout'),
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                        ),
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

  Widget _buildInfoPill(ThemeData theme, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(ThemeData theme, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
