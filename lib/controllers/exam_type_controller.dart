import 'package:get/get.dart';
import 'package:campus_care/models/exam_type_model.dart';
import 'package:campus_care/services/api/exam_type_api_service.dart';
import 'package:campus_care/core/api_exception.dart';

class ExamTypeController extends GetxController {
  final ExamTypeApiService _apiService = ExamTypeApiService();

  // Observable lists
  final RxList<ExamTypeModel> examTypeList = <ExamTypeModel>[].obs;

  // Filters
  final RxBool showOnlyActive = true.obs;

  // Loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchExamTypes();
  }

  // Fetch exam types from API
  Future<void> fetchExamTypes() async {
    try {
      isLoading.value = true;

      final examTypes = await _apiService.getExamTypes(
        isActive: showOnlyActive.value ? true : null,
      );

      examTypeList.value =
          examTypes.map((e) => ExamTypeModel.fromJson(e)).toList();
    } on ApiException catch (e) {
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch exam types: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Add new exam type — sends snake_case to match D1 schema
  Future<void> addExamType(ExamTypeModel examType) async {
    try {
      isLoading.value = true;

      final examTypeData = {
        'name': examType.name,
        if (examType.description != null && examType.description!.isNotEmpty)
          'description': examType.description,
        if (examType.weightage != null) 'weightage': examType.weightage,
        'is_active': examType.isActive ? 1 : 0,
      };

      final createdExamType = await _apiService.createExamType(examTypeData);
      examTypeList.add(ExamTypeModel.fromJson(createdExamType));

      Get.snackbar(
        'Success',
        'Exam schedule created successfully',
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
        'Failed to create exam schedule: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Update exam type — sends snake_case to match D1 schema
  Future<void> updateExamType(ExamTypeModel examType) async {
    try {
      isLoading.value = true;

      final examTypeData = {
        'name': examType.name,
        if (examType.description != null && examType.description!.isNotEmpty)
          'description': examType.description,
        if (examType.weightage != null) 'weightage': examType.weightage,
        'is_active': examType.isActive ? 1 : 0,
      };

      final updatedExamType =
          await _apiService.updateExamType(examType.id, examTypeData);

      final index = examTypeList.indexWhere((e) => e.id == examType.id);
      if (index != -1) {
        examTypeList[index] = ExamTypeModel.fromJson(updatedExamType);
      }

      Get.snackbar(
        'Success',
        'Exam schedule updated successfully',
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
        'Failed to update exam schedule: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Delete exam type
  Future<void> deleteExamType(String examTypeId) async {
    try {
      isLoading.value = true;
      await _apiService.deleteExamType(examTypeId);
      examTypeList.removeWhere((e) => e.id == examTypeId);

      Get.snackbar(
        'Success',
        'Exam schedule deleted successfully',
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
        'Failed to delete exam schedule: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle active filter
  void toggleActiveFilter() {
    showOnlyActive.value = !showOnlyActive.value;
    fetchExamTypes();
  }

  // Refresh
  Future<void> refresh() => fetchExamTypes();
}
