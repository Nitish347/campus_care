import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/models/subject.dart';
import 'package:campus_care/services/subject_service.dart';
import 'package:get/get.dart';

class SubjectController extends GetxController {
  final RxList<Subject> subjects = <Subject>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSubjects();
  }

  /// Fetch all subjects for the current institute
  Future<void> fetchSubjects() async {
    try {
      isLoading.value = true;
      error.value = '';
      subjects.value = await SubjectService.getAllSubjects();
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load subjects: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Get subjects for a specific class
  List<Subject> getSubjectsByClass(String classId) {
    return subjects
        .where((s) => s.classId == classId || s.classId == null)
        .toList();
  }

  /// Add a new subject
  Future<void> addSubject(Subject subject) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Get institute ID from auth controller
      final authController = Get.find<AuthController>();
      final instituteId = authController.currentAdmin?.id ?? '';

      // Create subject with institute ID
      final subjectWithInstitute = subject.copyWith(
        instituteId: instituteId,
      );

      final newId = await SubjectService.addSubject(subjectWithInstitute);

      if (newId.isNotEmpty) {
        // Refresh the list
        await fetchSubjects();
        Get.snackbar(
          'Success',
          'Subject added successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to add subject: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Update an existing subject
  Future<void> updateSubject(Subject subject) async {
    try {
      isLoading.value = true;
      error.value = '';

      final success = await SubjectService.updateSubject(subject);

      if (success) {
        // Refresh the list
        await fetchSubjects();
        Get.snackbar(
          'Success',
          'Subject updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw Exception('Update failed');
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to update subject: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete a subject
  Future<void> deleteSubject(String id) async {
    try {
      isLoading.value = true;
      error.value = '';

      await SubjectService.deleteSubject(id);

      // Refresh the list
      await fetchSubjects();
      Get.snackbar(
        'Success',
        'Subject deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to delete subject: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
