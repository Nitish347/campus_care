import 'package:get/get.dart';
import 'package:campus_care/models/homework_submission_model.dart';
import 'package:campus_care/services/api/homework_submission_api_service.dart';

class HomeworkSubmissionController extends GetxController {
  final HomeworkSubmissionApiService _apiService =
      HomeworkSubmissionApiService();

  final RxList<HomeworkSubmission> submissions = <HomeworkSubmission>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedHomeworkId = ''.obs;

  /// Fetch submissions for a specific homework
  Future<void> fetchSubmissions(String homeworkId) async {
    try {
      isLoading.value = true;
      selectedHomeworkId.value = homeworkId;

      final data =
          await _apiService.getHomeworkSubmissions(homeworkId: homeworkId);
      submissions.value =
          data.map((json) => HomeworkSubmission.fromJson(json)).toList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load submissions: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Get submission for a specific student
  HomeworkSubmission? getStudentSubmission(String studentId) {
    try {
      return submissions.firstWhere((sub) => sub.studentId == studentId);
    } catch (e) {
      return null;
    }
  }

  /// Grade a submission
  Future<void> gradeSubmission({
    required String submissionId,
    required double marksObtained,
    String? feedback,
  }) async {
    try {
      isLoading.value = true;

      final updateData = {
        'marksObtained': marksObtained,
        'status': 'graded',
        if (feedback != null && feedback.isNotEmpty) 'feedback': feedback,
      };

      await _apiService.updateHomeworkSubmission(submissionId, updateData);

      // Refresh submissions
      if (selectedHomeworkId.value.isNotEmpty) {
        await fetchSubmissions(selectedHomeworkId.value);
      }

      Get.snackbar(
        'Success',
        'Submission graded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to grade submission: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Bulk grade multiple submissions
  Future<void> bulkGradeSubmissions(List<Map<String, dynamic>> grades) async {
    try {
      isLoading.value = true;

      int successCount = 0;
      int failureCount = 0;
      List<String> errors = [];

      for (var grade in grades) {
        try {
          await gradeSubmission(
            submissionId: grade['submissionId'],
            marksObtained: grade['marksObtained'],
            feedback: grade['feedback'],
          );
          successCount++;
        } catch (e) {
          failureCount++;
          errors.add(e.toString());
        }
      }

      if (failureCount > 0) {
        Get.snackbar(
          'Partial Success',
          '$successCount graded, $failureCount failed',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Success',
          'All submissions graded successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
      }

      // Refresh submissions
      if (selectedHomeworkId.value.isNotEmpty) {
        await fetchSubmissions(selectedHomeworkId.value);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Bulk grading failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Get submission statistics
  Map<String, int> getSubmissionStats() {
    return {
      'total': submissions.length,
      'submitted': submissions.where((s) => s.isSubmitted).length,
      'pending': submissions.where((s) => s.isPending).length,
      'graded': submissions.where((s) => s.isGraded).length,
    };
  }
}
