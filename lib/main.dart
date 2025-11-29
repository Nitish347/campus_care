import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/theme.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/services/storage_service.dart';
import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/controllers/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage service
  await StorageService.init();

  runApp(const SchoolStreamApp());
}

class SchoolStreamApp extends StatelessWidget {
  const SchoolStreamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      init: ThemeController(),
      builder: (themeController) {
        return GetMaterialApp(
          title: 'School Stream',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeController.themeMode,
          initialRoute: AppRoutes.login,
          getPages: AppRoutes.getPages,
          initialBinding: BindingsBuilder(() {
            Get.put(AuthController());
            Get.put(ThemeController());
          }),
        );
      },
    );
  }
}
