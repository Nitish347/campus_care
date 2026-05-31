import 'package:get/get.dart';
import 'package:campus_care/models/exam_type_model.dart';
import 'package:campus_care/services/api/exam_type_api_service.dart';
import 'package:campus_care/core/api_exception.dart';
import 'package:campus_care/utils/app_notifier.dart';

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
      AppNotifier.error('Error', e.message);
    } catch (e) {
      AppNotifier.error('Error', 'Failed to fetch exam types: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Add new exam type — sends snake_case to match D1 schema
  Future<bool> addExamType(ExamTypeModel examType) async {
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
      return true;
    } on ApiException catch (e) {
      AppNotifier.error('Error', e.message);
      return false;
    } catch (e) {
      AppNotifier.error('Error', 'Failed to create exam schedule: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Update exam type — sends snake_case to match D1 schema
  Future<bool> updateExamType(ExamTypeModel examType) async {
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
      return true;
    } on ApiException catch (e) {
      AppNotifier.error('Error', e.message);
      return false;
    } catch (e) {
      AppNotifier.error('Error', 'Failed to update exam schedule: $e');
      return false;
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

      AppNotifier.success('Success', 'Exam schedule deleted successfully');
    } on ApiException catch (e) {
      AppNotifier.error('Error', e.message);
      rethrow;
    } catch (e) {
      AppNotifier.error('Error', 'Failed to delete exam schedule: $e');
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
  @override
  Future<void> refresh() => fetchExamTypes();
}
