import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/models/subject.dart';
import 'package:campus_care/services/subject_service.dart';
import 'package:campus_care/utils/app_notifier.dart';
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
      AppNotifier.error('Error', 'Failed to load subjects: $e');
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
  Future<bool> addSubject(Subject subject) async {
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
        await fetchSubjects();
        return true;
      }
      throw Exception('Failed to add subject');
    } catch (e) {
      error.value = e.toString();
      AppNotifier.error('Error', 'Failed to add subject: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update an existing subject
  Future<bool> updateSubject(Subject subject) async {
    try {
      isLoading.value = true;
      error.value = '';

      final success = await SubjectService.updateSubject(subject);

      if (success) {
        await fetchSubjects();
        return true;
      } else {
        throw Exception('Update failed');
      }
    } catch (e) {
      error.value = e.toString();
      AppNotifier.error('Error', 'Failed to update subject: $e');
      return false;
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

      await fetchSubjects();
      AppNotifier.success('Success', 'Subject deleted successfully');
    } catch (e) {
      error.value = e.toString();
      AppNotifier.error('Error', 'Failed to delete subject: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
