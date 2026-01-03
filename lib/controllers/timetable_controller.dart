import 'package:get/get.dart';
import 'package:campus_care/models/timetable_model.dart';
import 'package:campus_care/services/api/timetable_api_service.dart';
import 'package:campus_care/services/student_service.dart';

class TimetableController extends GetxController {
  final _isLoading = false.obs;
  final _timetables = <TimeTableModel>[].obs;
  final _selectedClass = Rxn<String>();
  final _selectedSection = Rxn<String>();
  final _currentTimetable = Rxn<TimeTableModel>();
  final _availableClasses = <String>[].obs;
  final _availableSections = <String>[].obs;

  final TimetableApiService _apiService = TimetableApiService();

  bool get isLoading => _isLoading.value;
  List<TimeTableModel> get timetables => _timetables;
  String? get selectedClass => _selectedClass.value;
  String? get selectedSection => _selectedSection.value;
  TimeTableModel? get currentTimetable => _currentTimetable.value;
  List<String> get availableClasses => _availableClasses;
  List<String> get availableSections => _availableSections;

  @override
  void onInit() {
    super.onInit();
    loadTimetables();
    _loadAvailableClasses();
  }

  Future<void> _loadAvailableClasses() async {
    try {
      final students = await StudentService.getAllStudents();
      final classes = students.map((s) => s.class_ ?? "").toSet().toList();
      classes.sort();
      _availableClasses.value = classes;
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadAvailableSections() async {
    if (_selectedClass.value == null) {
      _availableSections.value = [];
      return;
    }
    try {
      final students = await StudentService.getAllStudents();
      final sections = students
          .where((s) => s.class_ == _selectedClass.value)
          .map((s) => s.section ?? "")
          .toSet()
          .toList();
      sections.sort();
      _availableSections.value = sections;
    } catch (e) {
      _availableSections.value = [];
    }
  }

  Future<void> loadTimetables({String? classId, String? section}) async {
    try {
      _isLoading.value = true;
      final data = await _apiService.getTimetables(
        classId: classId,
        section: section,
      );

      // Group timetable entries by class and section
      final Map<String, Map<String, List<TimeTableItem>>> groupedByClass = {};

      for (var entry in data) {
        final classKey = '${entry['class'] ?? ''}_${entry['section'] ?? ''}';
        final day = entry['dayOfWeek'] as String;

        if (!groupedByClass.containsKey(classKey)) {
          groupedByClass[classKey] = {};
        }

        if (!groupedByClass[classKey]!.containsKey(day)) {
          groupedByClass[classKey]![day] = [];
        }

        // Extract teacherId - handle both string and object (populated) formats
        String teacherId = '';
        if (entry['teacherId'] is String) {
          teacherId = entry['teacherId'];
        } else if (entry['teacherId'] is Map) {
          teacherId = entry['teacherId']['_id'] ?? '';
        }

        groupedByClass[classKey]![day]!.add(TimeTableItem(
          period: 'P${groupedByClass[classKey]![day]!.length + 1}',
          subject: entry['subject'] ?? '',
          teacherId: teacherId,
          room: entry['room'],
          startTime: entry['startTime'] ?? '',
          endTime: entry['endTime'] ?? '',
          type: 'class',
        ));
      }

      // Convert grouped data to TimeTableModel list
      _timetables.value = groupedByClass.entries.map((entry) {
        final parts = entry.key.split('_');
        return TimeTableModel(
          id: entry.key,
          classId: parts[0],
          section: parts[1],
          weeklySchedule: entry.value,
        );
      }).toList();

      _updateCurrentTimetable();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load timetables: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void selectClass(String? classId) {
    _selectedClass.value = classId;
    _selectedSection.value = null;
    if (classId != null) {
      _loadAvailableSections();
      loadTimetables(classId: classId);
    } else {
      _availableSections.value = [];
      _currentTimetable.value = null;
    }
  }

  void selectSection(String? section) {
    _selectedSection.value = section;
    if (_selectedClass.value != null && section != null) {
      loadTimetables(classId: _selectedClass.value, section: section);
    } else {
      _updateCurrentTimetable();
    }
  }

  void resetSelection() {
    _selectedClass.value = null;
    _selectedSection.value = null;
    _currentTimetable.value = null;
    loadTimetables();
  }

  void _updateCurrentTimetable() {
    if (_selectedClass.value != null && _selectedSection.value != null) {
      _currentTimetable.value = _timetables.firstWhereOrNull(
        (tt) =>
            tt.classId == _selectedClass.value &&
            tt.section == _selectedSection.value,
      );
    } else {
      _currentTimetable.value = null;
    }
  }

  Future<void> saveTimetable(TimeTableModel timetable) async {
    try {
      _isLoading.value = true;

      // Transform the weekly schedule into individual timetable entries
      final List<Map<String, dynamic>> timetableEntries = [];

      timetable.weeklySchedule.forEach((day, periods) {
        for (var period in periods) {
          timetableEntries.add({
            'teacherId': period.teacherId,
            'subject': period.subject,
            'dayOfWeek': day,
            'startTime': period.startTime,
            'endTime': period.endTime,
            'room': period.room,
            'class': timetable.classId,
            'section': timetable.section,
            'isActive': true,
          });
        }
      });

      // Create each timetable entry individually
      for (var entry in timetableEntries) {
        await _apiService.createTimetable(entry);
      }

      // Reload from API to get fresh data
      await loadTimetables();

      Get.snackbar('Success', 'Timetable saved successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save timetable: $e');
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteTimetable(String id) async {
    try {
      _isLoading.value = true;
      await _apiService.deleteTimetable(id);

      // Reload from API
      await loadTimetables();

      Get.snackbar('Success', 'Timetable deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete timetable: $e');
    } finally {
      _isLoading.value = false;
    }
  }
}
