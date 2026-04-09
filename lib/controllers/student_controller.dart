import 'package:get/get.dart';
import 'package:campus_care/models/student/student.dart';
import 'package:campus_care/services/student_service.dart';

class StudentController extends GetxController {
  final _isLoading = false.obs;
  final _students = <Student>[].obs;
  final _searchQuery = ''.obs;
  final _selectedClass = Rxn<String>();
  final _selectedSection = Rxn<String>();

  bool get isLoading => _isLoading.value;
  List<Student> get students => _students;
  String? get selectedClass => _selectedClass.value;
  String? get selectedSection => _selectedSection.value;

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

  // Get filtered students by class and section
  List<Student> get filteredStudents {
    var filtered = _students.toList();

    // Filter by class and section
    if (_selectedClass.value != null && _selectedSection.value != null) {
      filtered = filtered.where((student) {
        return student.class_ == _selectedClass.value &&
            student.section == _selectedSection.value;
      }).toList();
    }

    // Filter by search query
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((student) {
        return student.fullName.toLowerCase().contains(query) ||
            student.enrollmentNumber.toLowerCase().contains(query) ||
            student.email.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  void onInit() {
    super.onInit();
    loadStudents();
  }

  Future<void> loadStudents() async {
    try {
      _isLoading.value = true;
      final data = await StudentService.getAllStudents();
      _students.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load students');
    } finally {
      _isLoading.value = false;
    }
  }

  void searchStudents(String query) {
    _searchQuery.value = query;
  }

  void selectClass(String? classId) {
    _selectedClass.value = classId;
    _selectedSection.value = null; // Reset section when class changes
  }

  void selectSection(String? section) {
    _selectedSection.value = section;
  }

  void resetSelection() {
    _selectedClass.value = null;
    _selectedSection.value = null;
    _searchQuery.value = '';
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
        Get.snackbar('Success', 'Student added successfully');
      }
      return createdId.isEmpty ? null : createdId;
    } catch (e) {
      if (showSnackbar) {
        Get.snackbar('Error', 'Failed to add student');
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
          Future.delayed(const Duration(milliseconds: 300), () {
            Get.snackbar('Success', 'Student updated successfully');
          });
        }
        return true;
      } else {
        throw Exception('Update failed');
      }
    } catch (e) {
      if (showSnackbar) {
        Future.delayed(const Duration(milliseconds: 300), () {
          Get.snackbar('Error', 'Failed to update student: ${e.toString()}');
        });
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
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.snackbar('Success', 'Student deleted successfully');
      });
    } catch (e) {
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.snackbar('Error', 'Failed to delete student: ${e.toString()}');
      });
    } finally {
      _isLoading.value = false;
    }
  }
}
