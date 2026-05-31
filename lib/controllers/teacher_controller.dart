import 'package:get/get.dart';
import 'package:campus_care/models/teacher/teacher.dart';
import 'package:campus_care/services/teacher_service.dart';
import 'package:campus_care/utils/app_notifier.dart';

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
      AppNotifier.error('Error', 'Failed to load teachers');
    } finally {
      _isLoading.value = false;
    }
  }

  void searchTeachers(String query) {
    _searchQuery.value = query;
  }

  Future<String?> addTeacher(
    Teacher teacher, {
    bool popOnSuccess = true,
    bool showSnackbar = true,
  }) async {
    try {
      _isLoading.value = true;
      final createdId = await TeacherService.addTeacher(teacher);
      await loadTeachers();
      _isLoading.value = false;
      if (popOnSuccess) {
        Get.back();
      }
      if (showSnackbar) {
        AppNotifier.afterNavigation('Success', 'Teacher added successfully');
      }
      return createdId.isEmpty ? null : createdId;
    } catch (e) {
      _isLoading.value = false;
      if (showSnackbar) {
        AppNotifier.afterNavigation(
          'Error',
          'Failed to add teacher: ${e.toString()}',
          isError: true,
        );
      }
      return null;
    }
  }

  Future<bool> updateTeacher(
    Teacher teacher, {
    bool popOnSuccess = true,
    bool showSnackbar = true,
  }) async {
    try {
      _isLoading.value = true;
      final success = await TeacherService.updateTeacher(teacher);
      if (success) {
        await loadTeachers();
        if (popOnSuccess) {
          Get.back();
        }
        if (showSnackbar) {
          AppNotifier.afterNavigation(
              'Success', 'Teacher updated successfully');
        }
        return true;
      } else {
        throw Exception('Update failed');
      }
    } catch (e) {
      if (showSnackbar) {
        AppNotifier.afterNavigation(
          'Error',
          'Failed to update teacher: ${e.toString()}',
          isError: true,
        );
      }
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteTeacher(String id) async {
    try {
      _isLoading.value = true;
      await TeacherService.deleteTeacher(id);
      await loadTeachers();
      AppNotifier.afterNavigation('Success', 'Teacher deleted successfully');
    } catch (e) {
      AppNotifier.afterNavigation(
        'Error',
        'Failed to delete teacher: ${e.toString()}',
        isError: true,
      );
    } finally {
      _isLoading.value = false;
    }
  }
}
