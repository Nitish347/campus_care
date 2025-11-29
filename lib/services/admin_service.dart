import 'package:campus_care/models/admin/admin.dart';
import 'package:campus_care/services/storage_service.dart';
import 'package:campus_care/core/constants/app_constants.dart';

class AdminService {
  static final List<Map<String, dynamic>> _sampleAdmins = [
    {
      'id': 'admin_001',
      'adminId': 'ADM2024001',
      'name': 'Principal Anderson',
      'email': 'principal@school.com',
      'phone': '+1234567999',
      'role': 'Super Admin',
      'permissions': ['all'],
      'createdAt': DateTime.now().subtract(const Duration(days: 2000)).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'isActive': true,
    },
    {
      'id': 'admin_002',
      'adminId': 'ADM2024002',
      'name': 'Vice Principal Smith',
      'email': 'vp.smith@school.com',
      'phone': '+1234567998',
      'role': 'Admin',
      'permissions': ['manage_students', 'manage_teachers', 'view_reports'],
      'createdAt': DateTime.now().subtract(const Duration(days: 1800)).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'isActive': true,
    },
  ];

  static Future<void> initializeSampleData() async {
    if (!StorageService.hasData(AppConstants.keyAdmins)) {
      await StorageService.saveData(AppConstants.keyAdmins, _sampleAdmins);
    }
  }

  static Future<List<Admin>> getAllAdmins() async {
    await initializeSampleData();
    final adminsData = StorageService.getData(AppConstants.keyAdmins);
    return adminsData.map((data) => Admin.fromJson(data)).toList();
  }

  static Future<Admin?> getAdminById(String id) async {
    final admins = await getAllAdmins();
    try {
      return admins.firstWhere((admin) => admin.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<String> addAdmin(Admin admin) async {
    await initializeSampleData();
    final adminsData = StorageService.getData(AppConstants.keyAdmins);

    String id = admin.id;
    if (id.isEmpty) {
      id = 'admin_${DateTime.now().millisecondsSinceEpoch}';
    }

    final newAdmin = admin.copyWith(
      id: id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    adminsData.add(newAdmin.toJson());
    await StorageService.saveData(AppConstants.keyAdmins, adminsData);
    return id;
  }

  static Future<bool> updateAdmin(Admin admin) async {
    try {
      final adminsData = StorageService.getData(AppConstants.keyAdmins);
      final index = adminsData.indexWhere((data) => data['id'] == admin.id);

      if (index != -1) {
        final updatedAdmin = admin.copyWith(updatedAt: DateTime.now());
        adminsData[index] = updatedAdmin.toJson();
        await StorageService.saveData(AppConstants.keyAdmins, adminsData);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<String> generateAdminId() async {
    final admins = await getAllAdmins();
    final year = DateTime.now().year;
    int maxNumber = 0;

    for (final admin in admins) {
      final adminId = admin.adminId;
      if (adminId.startsWith('ADM$year')) {
        final numberStr = adminId.substring(7);
        final number = int.tryParse(numberStr) ?? 0;
        if (number > maxNumber) {
          maxNumber = number;
        }
      }
    }

    return 'ADM$year${(maxNumber + 1).toString().padLeft(3, '0')}';
  }
}
