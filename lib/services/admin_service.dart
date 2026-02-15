import 'package:campus_care/models/admin/admin.dart';
import 'package:campus_care/services/api/admin_api_service.dart';

class AdminService {
  static final AdminApiService _apiService = AdminApiService();

  static Future<List<Admin>> getAllAdmins() async {
    try {
      final List<dynamic> data = await _apiService.getAllAdmins();
      return data.map((json) => Admin.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load admins: $e');
    }
  }

  static Future<Admin?> getAdminById(String id) async {
    try {
      final data = await _apiService.getAdminById(id);
      return Admin.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  static Future<String> addAdmin(Admin admin) async {
    try {
      final response = await _apiService.createAdmin(admin.toJson());
      return response['_id'] ?? '';
    } catch (e) {
      throw Exception('Failed to create admin: $e');
    }
  }

  static Future<bool> updateAdmin(Admin admin) async {
    try {
      await _apiService.updateAdmin(admin.id, admin.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> deleteAdmin(String id) async {
    await _apiService.deleteAdmin(id);
  }

  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      return await _apiService.getDashboardStats();
    } catch (e) {
      throw Exception('Failed to load dashboard stats: $e');
    }
  }
}
