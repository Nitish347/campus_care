import 'package:get/get.dart';
import 'package:campus_care/models/admin/admin.dart';
import 'package:campus_care/services/admin_service.dart';

class AdminController extends GetxController {
  final _isLoading = false.obs;
  final _admins = <Admin>[].obs;
  final _searchQuery = ''.obs;

  bool get isLoading => _isLoading.value;
  List<Admin> get admins => _admins;
  List<Admin> get filteredAdmins {
    if (_searchQuery.value.isEmpty) {
      return _admins;
    }
    return _admins.where((admin) {
      final query = _searchQuery.value.toLowerCase();
      return admin.name.toLowerCase().contains(query) ||
          admin.adminId.toLowerCase().contains(query) ||
          admin.role.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadAdmins();
  }

  Future<void> loadAdmins() async {
    try {
      _isLoading.value = true;
      final data = await AdminService.getAllAdmins();
      _admins.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load admins');
    } finally {
      _isLoading.value = false;
    }
  }

  void searchAdmins(String query) {
    _searchQuery.value = query;
  }

  Future<void> addAdmin(Admin admin) async {
    try {
      _isLoading.value = true;
      await AdminService.addAdmin(admin);
      await loadAdmins();
      Get.back();
      Get.snackbar('Success', 'Admin added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add admin');
    } finally {
      _isLoading.value = false;
    }
  }
}
