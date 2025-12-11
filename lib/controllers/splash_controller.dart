import 'package:campus_care/controllers/admin_controller.dart';
import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/controllers/student_controller.dart';
import 'package:campus_care/controllers/teacher_controller.dart';
import 'package:campus_care/core/constants/app_constants.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/models/user.dart';
import 'package:campus_care/services/auth_service.dart';
import 'package:campus_care/services/storage_service.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {

  // final _adminController = Get.find<AdminController>();
  // final _userController = Get.find<StudentController>();
  // final _teacherController = Get.find<TeacherController>();
  final _authController = Get.put(AuthController());

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Artificial delay for splash screen visibility (optional)
    await Future.delayed(const Duration(seconds: 2));

    _authController.onInit();
  }

}
