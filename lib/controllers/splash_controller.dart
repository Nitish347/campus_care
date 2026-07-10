import 'dart:async';

import 'package:campus_care/controllers/auth_controller.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  Timer? _loginStatusTimer;

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    // Artificial delay for splash screen visibility (optional)
    _loginStatusTimer = Timer(const Duration(seconds: 2), () async {
      if (isClosed) return;
      await _authController.checkLoginStatus();
    });
  }

  @override
  void onClose() {
    _loginStatusTimer?.cancel();
    super.onClose();
  }
}
