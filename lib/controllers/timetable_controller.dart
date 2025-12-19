import 'package:get/get.dart';
import 'package:campus_care/models/timetable_model.dart';
import 'package:campus_care/services/storage_service.dart';
import 'package:campus_care/core/constants/app_constants.dart';
import 'package:campus_care/services/student_service.dart';

class TimetableController extends GetxController {
  final _isLoading = false.obs;
  final _timetables = <TimeTableModel>[].obs;
  final _selectedClass = Rxn<String>();
  final _selectedSection = Rxn<String>();
  final _currentTimetable = Rxn<TimeTableModel>();
  final _availableClasses = <String>[].obs;
  final _availableSections = <String>[].obs;

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
      final classes = students.map((s) => s.class_??"").toSet().toList();
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
          .map((s) => s.section??"")
          .toSet()
          .toList();
      sections.sort();
      _availableSections.value = sections;
    } catch (e) {
      _availableSections.value = [];
    }
  }

  Future<void> loadTimetables() async {
    try {
      _isLoading.value = true;
      final data = StorageService.getData(AppConstants.keyTimetables);
      _timetables.value = data
          .map((json) => TimeTableModel.fromJson(json))
          .toList();
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
    _loadAvailableSections();
    _updateCurrentTimetable();
  }

  void selectSection(String? section) {
    _selectedSection.value = section;
    _updateCurrentTimetable();
  }

  void resetSelection() {
    _selectedClass.value = null;
    _selectedSection.value = null;
    _currentTimetable.value = null;
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
      
      // Remove existing timetable for same class and section
      _timetables.removeWhere(
        (tt) =>
            tt.classId == timetable.classId &&
            tt.section == timetable.section,
      );
      
      // Add new timetable
      _timetables.add(timetable);
      
      // Save to storage
      final data = _timetables.map((tt) => tt.toJson()).toList();
      await StorageService.saveData(AppConstants.keyTimetables, data);
      
      _updateCurrentTimetable();
      Get.snackbar('Success', 'Timetable saved successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save timetable: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteTimetable(String id) async {
    try {
      _isLoading.value = true;
      _timetables.removeWhere((tt) => tt.id == id);
      
      final data = _timetables.map((tt) => tt.toJson()).toList();
      await StorageService.saveData(AppConstants.keyTimetables, data);
      
      _updateCurrentTimetable();
      Get.snackbar('Success', 'Timetable deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete timetable: $e');
    } finally {
      _isLoading.value = false;
    }
  }
}

