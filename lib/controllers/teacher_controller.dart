import 'package:get/get.dart';
import 'package:campus_care/models/teacher/teacher.dart';
import 'package:campus_care/services/teacher_service.dart';

class TeacherController extends GetxController {
  final _isLoading = false.obs;
  final _teachers = <Teacher>[].obs;
  final _searchQuery = ''.obs;

  bool get isLoading => _isLoading.value;
  List<Teacher> get teachers => _teachers;
  List<Teacher> get filteredTeachers {
    if (_searchQuery.value.isEmpty) {
      return _teachers;
    }
    return _teachers.where((teacher) {
      final query = _searchQuery.value.toLowerCase();
      return teacher.fullName.toLowerCase().contains(query)
      // ||
          // teacher.teacherId.toLowerCase().contains(query) ||
          // teacher.department.toLowerCase().contains(query)

      ;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadTeachers();
  }

  Future<void> loadTeachers() async {
    try {
      _isLoading.value = true;
      final data = await TeacherService.getAllTeachers();
      _teachers.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load teachers');
    } finally {
      _isLoading.value = false;
    }
  }

  void searchTeachers(String query) {
    _searchQuery.value = query;
  }

  Future<void> addTeacher(Teacher teacher) async {
    try {
      _isLoading.value = true;
      await TeacherService.addTeacher(teacher);
      await loadTeachers();
      Get.back();
      Get.snackbar('Success', 'Teacher added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add teacher');
    } finally {
      _isLoading.value = false;
    }
  }
}
