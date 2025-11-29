import 'package:flutter_test/flutter_test.dart';
import 'package:campus_care/controllers/student_controller.dart';
import 'package:campus_care/controllers/teacher_controller.dart';
import 'package:campus_care/controllers/admin_controller.dart';
import 'package:campus_care/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Controller Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await StorageService.init();
    });

    test('StudentController loads data', () async {
      final controller = Get.put(StudentController());
      await controller.loadStudents();
      expect(controller.students, isNotNull);
    });

    test('TeacherController loads data', () async {
      final controller = Get.put(TeacherController());
      await controller.loadTeachers();
      expect(controller.teachers, isNotNull);
    });

    test('AdminController loads data', () async {
      final controller = Get.put(AdminController());
      await controller.loadAdmins();
      expect(controller.admins, isNotNull);
    });
  });
}
