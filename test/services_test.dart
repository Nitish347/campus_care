import 'package:flutter_test/flutter_test.dart';
import 'package:campus_care/services/teacher_service.dart';
import 'package:campus_care/services/admin_service.dart';
import 'package:campus_care/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Service Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await StorageService.init();
    });

    test('TeacherService initialization and retrieval', () async {
      await TeacherService.initializeSampleData();
      final teachers = await TeacherService.getAllTeachers();
      expect(teachers.isNotEmpty, true);
      expect(teachers.first.name, 'Sarah Thompson');
    });

    test('AdminService initialization and retrieval', () async {
      await AdminService.initializeSampleData();
      final admins = await AdminService.getAllAdmins();
      expect(admins.isNotEmpty, true);
      expect(admins.first.role, 'Super Admin');
    });
  });
}
