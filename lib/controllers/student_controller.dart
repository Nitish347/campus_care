import 'dart:async';

import 'package:get/get.dart';
import 'package:campus_care/models/student/student.dart';
import 'package:campus_care/services/student_service.dart';
import 'package:campus_care/utils/app_notifier.dart';

class StudentController extends GetxController {
  static const int studentsPerPage = 50;

  final _isLoading = false.obs;
  final _isListLoading = false.obs;
  final _hasLoadedStudents = false.obs;
  final _students = <Student>[].obs;
  final _searchQuery = ''.obs;
  final _selectedClass = Rxn<String>();
  final _selectedSection = Rxn<String>();
  final _currentPage = 1.obs;
  final _totalStudents = 0.obs;
  final _totalPages = 1.obs;
  final _sortBy = 'name'.obs;
  final _sortOrder = 'asc'.obs;
  Timer? _searchDebounce;

  bool get isLoading => _isLoading.value;
  bool get isListLoading => _isListLoading.value;
  bool get hasLoadedStudents => _hasLoadedStudents.value;
  bool get isInitialLoading =>
      _isListLoading.value && !_hasLoadedStudents.value;
  List<Student> get students => _students;
  String? get selectedClass => _selectedClass.value;
  String? get selectedSection => _selectedSection.value;
  String get searchQuery => _searchQuery.value;
  int get currentPage => _currentPage.value;
  int get totalStudents => _totalStudents.value;
  int get totalPages => _totalPages.value;
  String get sortBy => _sortBy.value;
  String get sortOrder => _sortOrder.value;
  bool get hasPreviousPage => _currentPage.value > 1;
  bool get hasNextPage => _currentPage.value < _totalPages.value;

  // // Get available classes
  // List<String>? get availableClasses {
  //   final classes = _students
  //       .map((s) => s.class_)
  //       .where((c) => c != null)
  //       .cast<String>()
  //       .toSet()
  //       .toList();
  //   classes.sort();
  //   return classes;
  // }

  // // Get available sections for selected class
  // List<String> get availableSections {
  //   if (_selectedClass.value == null) return [];
  //   final sections = _students
  //       .where((s) => s.class_ == _selectedClass.value)
  //       .map((s) => s.section)
  //       .where((s) => s != null)
  //       .cast<String>()
  //       .toSet()
  //       .toList();
  //   sections.sort();
  //   return sections;
  // }

  // Server already applies filters for Student Management. Keep this getter for
  // existing UI callers while returning the current page.
  List<Student> get filteredStudents {
    return _students.toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadStudents();
  }

  Future<void> loadStudents({int? page}) async {
    try {
      _isListLoading.value = true;
      final requestedPage = page ?? _currentPage.value;
      final data = await StudentService.getStudentsPage(
        page: requestedPage,
        limit: studentsPerPage,
        search: _searchQuery.value,
        classId: _selectedClass.value,
        section: _selectedSection.value,
        sortBy: _sortBy.value,
        sortOrder: _sortOrder.value,
      );
      _students.assignAll(data.students);
      _currentPage.value = data.page;
      _totalStudents.value = data.total;
      _totalPages.value = data.totalPages;
      _hasLoadedStudents.value = true;
    } catch (e) {
      AppNotifier.error('Error', 'Failed to load students');
    } finally {
      _isListLoading.value = false;
    }
  }

  void searchStudents(String query) {
    _searchQuery.value = query;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      loadStudents(page: 1);
    });
  }

  void selectClass(String? classId) {
    _selectedClass.value = classId;
    _selectedSection.value = null; // Reset section when class changes
    loadStudents(page: 1);
  }

  void selectSection(String? section) {
    _selectedSection.value = section;
    loadStudents(page: 1);
  }

  void setSort(String sortBy) {
    if (_sortBy.value == sortBy) {
      _sortOrder.value = _sortOrder.value == 'asc' ? 'desc' : 'asc';
    } else {
      _sortBy.value = sortBy;
      _sortOrder.value = 'asc';
    }
    loadStudents(page: 1);
  }

  void goToPage(int page) {
    final nextPage = page.clamp(1, _totalPages.value);
    if (nextPage == _currentPage.value) return;
    loadStudents(page: nextPage);
  }

  void nextPage() {
    if (hasNextPage) {
      goToPage(_currentPage.value + 1);
    }
  }

  void previousPage() {
    if (hasPreviousPage) {
      goToPage(_currentPage.value - 1);
    }
  }

  void resetSelection() {
    _searchDebounce?.cancel();
    _selectedClass.value = null;
    _selectedSection.value = null;
    _searchQuery.value = '';
    _sortBy.value = 'name';
    _sortOrder.value = 'asc';
    loadStudents(page: 1);
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }

  Future<String?> addStudent(
    Student student, {
    bool popOnSuccess = true,
    bool showSnackbar = true,
  }) async {
    try {
      _isLoading.value = true;
      final createdId = await StudentService.addStudent(student);
      await loadStudents();
      if (popOnSuccess) {
        Get.back();
      }
      if (showSnackbar) {
        AppNotifier.success('Success', 'Student added successfully');
      }
      return createdId.isEmpty ? null : createdId;
    } catch (e) {
      if (showSnackbar) {
        AppNotifier.error('Error', 'Failed to add student');
      }
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateStudent(
    Student student, {
    bool popOnSuccess = true,
    bool showSnackbar = true,
  }) async {
    try {
      _isLoading.value = true;
      final success = await StudentService.updateStudent(student);
      if (success) {
        await loadStudents();
        if (popOnSuccess) {
          Get.back();
        }
        if (showSnackbar) {
          AppNotifier.afterNavigation(
              'Success', 'Student updated successfully');
        }
        return true;
      } else {
        throw Exception('Update failed');
      }
    } catch (e) {
      if (showSnackbar) {
        AppNotifier.afterNavigation(
          'Error',
          'Failed to update student: ${e.toString()}',
          isError: true,
        );
      }
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteStudent(String id) async {
    try {
      _isLoading.value = true;
      await StudentService.deleteStudent(id);
      await loadStudents();
      AppNotifier.afterNavigation('Success', 'Student deleted successfully');
    } catch (e) {
      AppNotifier.afterNavigation(
        'Error',
        'Failed to delete student: ${e.toString()}',
        isError: true,
      );
    } finally {
      _isLoading.value = false;
    }
  }
}
