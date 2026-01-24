import 'package:flutter/material.dart';
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

  /// Fetch exam results with optional filters
  Future<void> fetchResults({
    String? examId,
    String? classId,
    String? studentId,
  }) async {
    try {
      isLoading.value = true;
      final data = await _apiService.getExamResults(
        examId: examId ??
            (selectedExamId.value.isNotEmpty ? selectedExamId.value : null),
        classId: classId ??
            (selectedClassId.value.isNotEmpty ? selectedClassId.value : null),
        studentId: studentId,
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

  /// Get result for specific student in an exam
  ExamResult? getStudentResult(String examId, String studentId) {
    try {
      return results.firstWhere(
        (result) => result.examId == examId && result.studentId == studentId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Save marks for a single student
  Future<void> saveMarks({
    required String examId,
    required String studentId,
    required double marks,
    String? remarks,
  }) async {
    try {
      isLoading.value = true;

      final existingResult = getStudentResult(examId, studentId);

      final resultData = {
        'examId': examId,
        'studentId': studentId,
        'marks': marks,
        if (remarks != null) 'remarks': remarks,
      };

      if (existingResult != null) {
        // Update existing result
        await _apiService.updateExamResult(existingResult.id, resultData);
      } else {
        // Create new result
        await _apiService.createExamResult(resultData);
      }

      // Refresh results
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

  /// Bulk save marks for multiple students
  Future<void> bulkSaveMarks({
    required String examId,
    required List<Map<String, dynamic>> entries,
  }) async {
    try {
      isLoading.value = true;

      int successCount = 0;
      int failureCount = 0;
      List<String> errors = [];

      for (var entry in entries) {
        try {
          await saveMarks(
            examId: examId,
            studentId: entry['studentId'],
            marks: entry['marks'],
            remarks: entry['remarks'],
          );
          successCount++;
        } catch (e) {
          failureCount++;
          errors.add('${entry['studentId']}: ${e.toString()}');
        }
      }

      if (failureCount > 0) {
        Get.dialog(
          AlertDialog(
            title: const Text('Bulk Save Results'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$successCount records saved successfully.'),
                  Text('$failureCount records failed.'),
                  if (errors.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text('Errors:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    ...errors.take(5).map((e) =>
                        Text('• $e', style: const TextStyle(fontSize: 12))),
                    if (errors.length > 5)
                      Text('...and ${errors.length - 5} more'),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        Get.snackbar(
          'Success',
          'All marks saved successfully ($successCount records)',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
      }

      // Refresh results
      await fetchResults(examId: examId);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Bulk save failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Set filter for exam
  void setExamFilter(String examId) {
    selectedExamId.value = examId;
    fetchResults();
  }

  /// Set filter for class
  void setClassFilter(String classId) {
    selectedClassId.value = classId;
    fetchResults();
  }

  /// Clear all filters
  void clearFilters() {
    selectedExamId.value = '';
    selectedClassId.value = '';
    fetchResults();
  }

  /// Get statistics for an exam
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
