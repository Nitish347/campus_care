import 'package:get/get.dart';
import 'package:campus_care/models/exam_result_model.dart';
import 'package:campus_care/services/api/exam_result_api_service.dart';

class ExamResultController extends GetxController {
  final ExamResultApiService _apiService = ExamResultApiService();

  final RxList<ExamResult> results = <ExamResult>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedExamId = ''.obs;
  final RxString selectedClassId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchResults();
  }

  Future<void> fetchResults({
    String? examId,
    String? classId,
    String? studentId,
    String? section,
    String? subject,
  }) async {
    try {
      isLoading.value = true;

      final data = await _apiService.getExamResults(
        examId: examId ??
            (selectedExamId.value.isNotEmpty ? selectedExamId.value : null),
        classId: classId ??
            (selectedClassId.value.isNotEmpty ? selectedClassId.value : null),
        studentId: studentId,
        section: section,
        subject: subject,
      );

      results.value = data.map((json) => ExamResult.fromJson(json)).toList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load exam results: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  ExamResult? getStudentResult(String examId, String studentId) {
    try {
      return results.firstWhere(
        (result) => result.examId == examId && result.studentId == studentId,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveMarks({
    required String examId,
    required String studentId,
    required double marks,
    required String subject,
    required double totalMarks,
    String? remarks,
    bool isAbsent = false,
  }) async {
    try {
      isLoading.value = true;

      final resultData = {
        'exam_id': examId,
        'student_id': studentId,
        'subject': subject,
        'marks': isAbsent ? 0 : marks,
        'total_marks': totalMarks,
        'is_absent': isAbsent ? 1 : 0,
        if (remarks != null && remarks.trim().isNotEmpty)
          'remarks': remarks.trim(),
      };

      await _apiService.createExamResult(resultData);
      await fetchResults(examId: examId);

      Get.snackbar(
        'Success',
        'Marks saved successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save marks: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> bulkSaveMarks({
    required List<Map<String, dynamic>> entries,
    String? examId,
    bool showSuccess = true,
  }) async {
    try {
      isLoading.value = true;

      if (entries.isEmpty) {
        throw Exception('No marks entries provided');
      }

      await _apiService.bulkUpsertExamResults(entries);

      await fetchResults(
        examId: examId ??
            (selectedExamId.value.isNotEmpty ? selectedExamId.value : null),
      );

      if (showSuccess) {
        Get.snackbar(
          'Success',
          'Marks saved successfully (${entries.length} records)',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Bulk save failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  void setExamFilter(String examId) {
    selectedExamId.value = examId;
    fetchResults();
  }

  void setClassFilter(String classId) {
    selectedClassId.value = classId;
    fetchResults();
  }

  void clearFilters() {
    selectedExamId.value = '';
    selectedClassId.value = '';
    fetchResults();
  }

  Map<String, dynamic> getExamStats(String examId) {
    final examResults = results.where((r) => r.examId == examId).toList();

    if (examResults.isEmpty) {
      return {
        'totalStudents': 0,
        'submitted': 0,
        'pending': 0,
        'averageMarks': 0.0,
        'highestMarks': 0.0,
        'lowestMarks': 0.0,
      };
    }

    final submitted = examResults.where((r) => r.marks > 0).length;
    final marksList =
        examResults.where((r) => r.marks > 0).map((r) => r.marks).toList();

    return {
      'totalStudents': examResults.length,
      'submitted': submitted,
      'pending': examResults.length - submitted,
      'averageMarks': marksList.isEmpty
          ? 0.0
          : marksList.reduce((a, b) => a + b) / marksList.length,
      'highestMarks':
          marksList.isEmpty ? 0.0 : marksList.reduce((a, b) => a > b ? a : b),
      'lowestMarks':
          marksList.isEmpty ? 0.0 : marksList.reduce((a, b) => a < b ? a : b),
    };
  }
}
