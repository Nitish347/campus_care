import 'package:campus_care/controllers/auth_controller.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Artificial delay for splash screen visibility (optional)
    await Future.delayed(const Duration(seconds: 2));

    await _authController.checkLoginStatus();
  }
}
