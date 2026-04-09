import 'package:campus_care/models/admin/admin.dart';
import 'package:campus_care/services/admin_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class AdminController extends GetxController {
  final _isLoading = false.obs;
  final _isDashboardLoading = false.obs;
  final _dashboardError = RxnString();
  final _admins = <Admin>[].obs;
  final _searchQuery = ''.obs;

  bool get isLoading => _isLoading.value;
  bool get isDashboardLoading => _isDashboardLoading.value;
  String? get dashboardError => _dashboardError.value;
  List<Admin> get admins => _admins;
  List<Admin> get filteredAdmins {
    if (_searchQuery.value.isEmpty) {
      return _admins;
    }
    return _admins.where((admin) {
      final query = _searchQuery.value.toLowerCase();
      return admin.fullName.toLowerCase().contains(query) ||
          admin.email.toLowerCase().contains(query) ||
          (admin.instituteName.toLowerCase().contains(query));
    }).toList();
  }

  final _dashboardStats = <String, dynamic>{}.obs;
  Map<String, dynamic> get dashboardStats => _dashboardStats;

  @override
  void onInit() {
    super.onInit();
    loadAdmins();
  }

  Future<void> fetchDashboardStats({bool showErrorSnackbar = false}) async {
    try {
      _isDashboardLoading.value = true;
      _dashboardError.value = null;
      final stats = await AdminService.getDashboardStats();
      _dashboardStats.value = Map<String, dynamic>.from(stats);
    } catch (e) {
      _dashboardError.value = e.toString().replaceFirst('Exception: ', '');
      if (showErrorSnackbar) {
        Get.snackbar(
            'Stats Load Failed', _dashboardError.value ?? 'Unknown error');
      }
    } finally {
      _isDashboardLoading.value = false;
    }
  }

  Future<Admin?> getAdminById(String id) async {
    try {
      final admin = await AdminService.getAdminById(id);
      return admin;
    } catch (e) {
      // Fail silently or log error
      debugPrint('Error fetching dashboard stats: $e');
      return null;
    }
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
