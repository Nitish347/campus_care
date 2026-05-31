import 'package:campus_care/models/class.dart';
import 'package:campus_care/services/api/class_api_service.dart';
import 'package:campus_care/utils/app_notifier.dart';
import 'package:get/get.dart';

class ClassController extends GetxController {
  final ClassApiService _classApiService = ClassApiService();

  final RxList<SchoolClass> classes = <SchoolClass>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchClasses();
  }

  Future<void> fetchClasses() async {
    try {
      isLoading.value = true;
      error.value = '';
      final data = await _classApiService.getClasses();
      classes.value = data.map((json) => SchoolClass.fromJson(json)).toList();
    } catch (e) {
      error.value = e.toString();
      AppNotifier.error('Error', 'Failed to fetch classes: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addClass(
    Map<String, dynamic> classData, {
    bool popOnSuccess = true,
    bool showSnackbar = true,
  }) async {
    try {
      isLoading.value = true;
      await _classApiService.createClass(classData);
      await fetchClasses();
      if (popOnSuccess) {
        Get.back();
      }
      if (showSnackbar) {
        AppNotifier.afterNavigation('Success', 'Class added successfully');
      }
      return true;
    } catch (e) {
      if (showSnackbar) {
        AppNotifier.error('Error', 'Failed to add class: ${e.toString()}');
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addSection(String classId, String section) async {
    try {
      isLoading.value = true;
      await _classApiService.addSection(classId, section);
      AppNotifier.success('Success', 'Section added successfully');
      await fetchClasses();
    } catch (e) {
      AppNotifier.error('Error', 'Failed to add section: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateClass(
    String id,
    Map<String, dynamic> classData, {
    bool popOnSuccess = true,
    bool showSnackbar = true,
  }) async {
    try {
      isLoading.value = true;
      await _classApiService.updateClass(id, classData);
      await fetchClasses();
      if (popOnSuccess) {
        Get.back();
      }
      if (showSnackbar) {
        AppNotifier.afterNavigation('Success', 'Class updated successfully');
      }
      return true;
    } catch (e) {
      if (showSnackbar) {
        AppNotifier.error('Error', 'Failed to update class: ${e.toString()}');
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteClass(String id) async {
    try {
      isLoading.value = true;
      await _classApiService.deleteClass(id);
      AppNotifier.success('Success', 'Class deleted successfully');
      await fetchClasses();
    } catch (e) {
      AppNotifier.error('Error', 'Failed to delete class: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
