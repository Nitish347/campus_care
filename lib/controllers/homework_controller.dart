import 'package:get/get.dart';
import 'package:campus_care/models/homework_model.dart';
import 'package:campus_care/models/homework_submission_model.dart';
import 'package:campus_care/services/api/homework_api_service.dart';
import 'package:campus_care/core/api_exception.dart';

class HomeworkController extends GetxController {
  final HomeworkApiService _apiService = HomeworkApiService();

  // Observable lists
  final RxList<HomeWorkModel> homeworkList = <HomeWorkModel>[].obs;
  final RxList<HomeworkSubmission> submissions = <HomeworkSubmission>[].obs;

  // Filters
  final RxString selectedClass = ''.obs;
  final RxString selectedSection = ''.obs;
  final RxString selectedSubject = 'All'.obs;

  // Loading state
  final RxBool isLoading = false.obs;

  // View toggle
  final RxBool _isTableView = false.obs;
  bool get isTableView => _isTableView.value;
  void toggleViewMode() => _isTableView.value = !_isTableView.value;

  @override
  void onInit() {
    super.onInit();
    fetchHomework();
  }

  // Fetch homework from backend
  Future<void> fetchHomework() async {
    try {
      isLoading.value = true;
      final data = await _apiService.getHomework(
        classId: selectedClass.value.isNotEmpty ? selectedClass.value : null,
        section:
            selectedSection.value.isNotEmpty ? selectedSection.value : null,
        subject: selectedSubject.value != 'All' ? selectedSubject.value : null,
      );

      homeworkList.value =
          data.map((json) => HomeWorkModel.fromJson(json)).toList();
    } on ApiException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load homework: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get homework filtered by class and section
  List<HomeWorkModel> getFilteredHomework() {
    var filtered = homeworkList.toList();

    if (selectedClass.value.isNotEmpty) {
      filtered =
          filtered.where((hw) => hw.classId == selectedClass.value).toList();
    }

    if (selectedSection.value.isNotEmpty) {
      filtered =
          filtered.where((hw) => hw.section == selectedSection.value).toList();
    }

    if (selectedSubject.value != 'All') {
      filtered =
          filtered.where((hw) => hw.subject == selectedSubject.value).toList();
    }

    return filtered;
  }

  // Get submissions for a specific homework
  List<HomeworkSubmission> getHomeworkSubmissions(String homeworkId) {
    return submissions.where((sub) => sub.homeworkId == homeworkId).toList();
  }

  // Get submission statistics for a homework
  Map<String, int> getSubmissionStats(String homeworkId) {
    final hwSubmissions = getHomeworkSubmissions(homeworkId);
    return {
      'total': hwSubmissions.length,
      'submitted': hwSubmissions.where((s) => s.isSubmitted).length,
      'pending': hwSubmissions.where((s) => s.isPending).length,
      'graded': hwSubmissions.where((s) => s.isGraded).length,
    };
  }

  // Add new homework
  Future<void> addHomework(HomeWorkModel homework) async {
    try {
      isLoading.value = true;

      final homeworkData = {
        'title': homework.title,
        'description': homework.description,
        'subject': homework.subject,
        'class_id': homework.classId,
        'section': homework.section,
        'due_date': homework.dueDate.millisecondsSinceEpoch ~/ 1000,
        'priority': homework.priority,
        'assigned_students': '[]',
        'attachments': '[]',
        if (homework.totalMarks != null) 'total_marks': homework.totalMarks,
      };

      final createdHomework = await _apiService.createHomework(homeworkData);
      homeworkList.add(HomeWorkModel.fromJson(createdHomework));

      Get.snackbar(
        'Success',
        'Homework created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on ApiException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create homework: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Update homework
  Future<void> updateHomework(HomeWorkModel homework) async {
    try {
      isLoading.value = true;

      final homeworkData = {
        'title': homework.title,
        'description': homework.description,
        'subject': homework.subject,
        'class_id': homework.classId,
        'section': homework.section,
        'due_date': homework.dueDate.millisecondsSinceEpoch ~/ 1000,
        'priority': homework.priority,
        if (homework.totalMarks != null) 'total_marks': homework.totalMarks,
      };

      final updatedHomework =
          await _apiService.updateHomework(homework.id, homeworkData);

      final index = homeworkList.indexWhere((hw) => hw.id == homework.id);
      if (index != -1) {
        homeworkList[index] = HomeWorkModel.fromJson(updatedHomework);
      }

      Get.snackbar(
        'Success',
        'Homework updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on ApiException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update homework: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Delete homework
  Future<void> deleteHomework(String homeworkId) async {
    try {
      isLoading.value = true;
      await _apiService.deleteHomework(homeworkId);
      homeworkList.removeWhere((hw) => hw.id == homeworkId);
      submissions.removeWhere((sub) => sub.homeworkId == homeworkId);

      Get.snackbar(
        'Success',
        'Homework deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on ApiException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete homework: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Grade a submission
  Future<void> gradeSubmission(
    String submissionId,
    double marks,
    String feedback,
  ) async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    final index = submissions.indexWhere((sub) => sub.id == submissionId);
    if (index != -1) {
      submissions[index] = submissions[index].copyWith(
        marksObtained: marks,
        feedback: feedback,
        status: 'graded',
        updatedAt: DateTime.now(),
      );
    }
    isLoading.value = false;
  }

  // Set filters
  void setClassFilter(String classId) {
    selectedClass.value = classId;
    fetchHomework(); // Refetch with new filter
  }

  void setSectionFilter(String section) {
    selectedSection.value = section;
    fetchHomework(); // Refetch with new filter
  }

  void setSubjectFilter(String subject) {
    selectedSubject.value = subject;
    // No need to refetch, just filter client-side
  }

  // Clear filters
  void clearFilters() {
    selectedClass.value = '';
    selectedSection.value = '';
    selectedSubject.value = 'All';
    fetchHomework();
  }
}
