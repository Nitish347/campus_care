import 'package:campus_care/models/class.dart';
import 'package:campus_care/services/api/class_api_service.dart';
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
      Get.snackbar('Error', 'Failed to fetch classes: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addClass(Map<String, dynamic> classData) async {
    try {
      isLoading.value = true;
      await _classApiService.createClass(classData);
      Get.snackbar('Success', 'Class added successfully');
      fetchClasses();
      Get.back(); // Go back to previous screen
    } catch (e) {
      Get.snackbar('Error', 'Failed to add class: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addSection(String classId, String section) async {
    try {
      isLoading.value = true;
      await _classApiService.addSection(classId, section);
      Get.snackbar('Success', 'Section added successfully');
      fetchClasses(); // Refresh list to show new section
    } catch (e) {
      Get.snackbar('Error', 'Failed to add section: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateClass(String id, Map<String, dynamic> classData) async {
    try {
      isLoading.value = true;
      await _classApiService.updateClass(id, classData);
      Get.snackbar('Success', 'Class updated successfully');
      fetchClasses(); // Refresh list
      Get.back(); // Close edit screen/dialog
    } catch (e) {
      Get.snackbar('Error', 'Failed to update class: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteClass(String id) async {
    try {
      isLoading.value = true;
      await _classApiService.deleteClass(id);
      Get.snackbar('Success', 'Class deleted successfully');
      fetchClasses(); // Refresh list
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete class: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
