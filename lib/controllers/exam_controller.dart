import 'package:get/get.dart';
import 'package:campus_care/models/exam_model.dart';
import 'package:campus_care/models/exam_result_model.dart';
import 'package:campus_care/services/api/exam_api_service.dart';
import 'package:campus_care/core/api_exception.dart';

class ExamController extends GetxController {
  final ExamApiService _apiService = ExamApiService();

  // Observable lists
  final RxList<ExamModel> examList = <ExamModel>[].obs;
  final RxList<ExamResult> examResults = <ExamResult>[].obs;

  // Filters
  final RxString selectedClass = ''.obs;
  final RxString selectedSection = ''.obs;
  final RxString selectedSubject = 'All'.obs;

  // Loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchExams();
  }

  // Fetch exams from API
  Future<void> fetchExams() async {
    try {
      isLoading.value = true;

      final exams = await _apiService.getExams(
        classId: selectedClass.value.isNotEmpty ? selectedClass.value : null,
        section:
            selectedSection.value.isNotEmpty ? selectedSection.value : null,
      );

      examList.value = exams.map((e) => ExamModel.fromJson(e)).toList();
    } on ApiException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch exams: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get exams filtered by class and section
  List<ExamModel> getFilteredExams() {
    var filtered = examList.toList();

    if (selectedClass.value.isNotEmpty) {
      filtered = filtered
          .where((exam) => exam.classId == selectedClass.value)
          .toList();
    }

    if (selectedSection.value.isNotEmpty) {
      filtered = filtered
          .where((exam) => exam.section == selectedSection.value)
          .toList();
    }

    if (selectedSubject.value != 'All') {
      filtered = filtered
          .where((exam) => exam.subject == selectedSubject.value)
          .toList();
    }

    return filtered;
  }

  // Get results for a specific exam
  List<ExamResult> getExamResults(String examId) {
    return examResults.where((result) => result.examId == examId).toList();
  }

  // Get exam statistics
  Map<String, dynamic> getExamStats(String examId) {
    final results = getExamResults(examId).where((r) => r.isPresent).toList();

    if (results.isEmpty) {
      return {
        'average': 0.0,
        'highest': 0.0,
        'lowest': 0.0,
        'totalStudents': 0,
        'present': 0,
        'absent': 0,
      };
    }

    final marks = results.map((r) => r.marks).toList();
    final average = marks.reduce((a, b) => a + b) / marks.length;
    final highest = marks.reduce((a, b) => a > b ? a : b);
    final lowest = marks.reduce((a, b) => a < b ? a : b);
    final allResults = getExamResults(examId);

    return {
      'average': average,
      'highest': highest,
      'lowest': lowest,
      'totalStudents': allResults.length,
      'present': allResults.where((r) => r.isPresent).length,
      'absent': allResults.where((r) => !r.isPresent).length,
    };
  }

  // Add new exam — sends snake_case to match D1 schema
  Future<void> addExam(ExamModel exam) async {
    try {
      isLoading.value = true;

      final examData = {
        'exam_type_id': exam.examTypeId,
        'name': exam.name,
        'type': exam.type,
        'subject': exam.subject,
        'class_id': exam.classId,
        'section': exam.section,
        'total_marks': exam.totalMarks.toInt(),
        'exam_date': exam.examDate.millisecondsSinceEpoch ~/ 1000,
        if (exam.durationMinutes != null)
          'duration_minutes': exam.durationMinutes,
        if (exam.instructions != null) 'instructions': exam.instructions,
        if (exam.syllabus != null) 'syllabus': exam.syllabus,
      };

      final createdExam = await _apiService.createExam(examData);
      examList.add(ExamModel.fromJson(createdExam));

      Get.snackbar(
        'Success',
        'Exam created successfully',
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
        'Failed to create exam: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Update exam — sends snake_case to match D1 schema
  Future<void> updateExam(ExamModel exam) async {
    try {
      isLoading.value = true;

      final examData = {
        'exam_type_id': exam.examTypeId,
        'name': exam.name,
        'type': exam.type,
        'subject': exam.subject,
        'class_id': exam.classId,
        'section': exam.section,
        'total_marks': exam.totalMarks.toInt(),
        'exam_date': exam.examDate.millisecondsSinceEpoch ~/ 1000,
        if (exam.durationMinutes != null)
          'duration_minutes': exam.durationMinutes,
        if (exam.instructions != null) 'instructions': exam.instructions,
        if (exam.syllabus != null) 'syllabus': exam.syllabus,
      };

      final updatedExam = await _apiService.updateExam(exam.id, examData);

      final index = examList.indexWhere((e) => e.id == exam.id);
      if (index != -1) {
        examList[index] = ExamModel.fromJson(updatedExam);
      }

      Get.snackbar(
        'Success',
        'Exam updated successfully',
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
        'Failed to update exam: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Delete exam
  Future<void> deleteExam(String examId) async {
    try {
      isLoading.value = true;
      await _apiService.deleteExam(examId);
      examList.removeWhere((e) => e.id == examId);
      examResults.removeWhere((r) => r.examId == examId);

      Get.snackbar(
        'Success',
        'Exam deleted successfully',
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
        'Failed to delete exam: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Save exam results (bulk entry)
  Future<void> saveExamResults(List<ExamResult> results) async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));

    for (var result in results) {
      final index = examResults.indexWhere((r) => r.id == result.id);
      if (index != -1) {
        examResults[index] = result;
      } else {
        examResults.add(result);
      }
    }

    isLoading.value = false;
  }

  // Update single exam result
  Future<void> updateExamResult(ExamResult result) async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    final index = examResults.indexWhere((r) => r.id == result.id);
    if (index != -1) {
      examResults[index] = result;
    } else {
      examResults.add(result);
    }
    isLoading.value = false;
  }

  // Get student's all exam results
  List<ExamResult> getStudentResults(String studentId) {
    return examResults.where((r) => r.studentId == studentId).toList();
  }

  // Set filters
  void setClassFilter(String classId) {
    selectedClass.value = classId;
    fetchExams();
  }

  void setSectionFilter(String section) {
    selectedSection.value = section;
    fetchExams();
  }

  void setSubjectFilter(String subject) {
    selectedSubject.value = subject;
  }

  // Clear filters
  void clearFilters() {
    selectedClass.value = '';
    selectedSection.value = '';
    selectedSubject.value = 'All';
    fetchExams();
  }
}
