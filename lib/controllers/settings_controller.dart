import 'package:get/get.dart';
import 'package:campus_care/controllers/theme_controller.dart';

class SettingsController extends GetxController {
  final notificationsEnabled = true.obs;
  final emailNotifications = true.obs;
  final pushNotifications = true.obs;
  final language = 'English'.obs;
  final themeController = Get.find<ThemeController>();

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
  }

  void toggleEmailNotifications(bool value) {
    emailNotifications.value = value;
  }

  void togglePushNotifications(bool value) {
    pushNotifications.value = value;
  }

  void setLanguage(String lang) {
    language.value = lang;
  }

  void saveSettings() {
    Get.snackbar('Success', 'Settings saved successfully');
  }
}

