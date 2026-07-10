import 'package:campus_care/controllers/admin_controller.dart';
import 'package:campus_care/controllers/class_controller.dart';
import 'package:campus_care/controllers/student_controller.dart';
import 'package:campus_care/controllers/teacher_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:campus_care/theme.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/services/storage_service.dart';
import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/controllers/theme_controller.dart';
import 'package:campus_care/services/institute_context_service.dart';
import 'package:campus_care/controllers/institute_controller.dart';
import 'package:campus_care/utils/app_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage service
  await StorageService.init();

  runApp(const SchoolStreamApp());
}

class SchoolStreamApp extends StatelessWidget {
  const SchoolStreamApp({super.key});

  shad.ThemeMode _resolveShadcnThemeMode(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return shad.ThemeMode.light;
      case ThemeMode.dark:
        return shad.ThemeMode.dark;
      case ThemeMode.system:
        return shad.ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      init: ThemeController(),
      builder: (themeController) {
        return GetMaterialApp(
          title: 'School Stream',
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: AppNotifier.messengerKey,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeController.themeMode,
          builder: (context, child) => shad.ShadcnLayer(
            theme: const shad.ThemeData(
              colorScheme: shad.ColorSchemes.lightZinc,
              radius: 0.35,
            ),
            darkTheme: const shad.ThemeData.dark(
              colorScheme: shad.ColorSchemes.darkZinc,
              radius: 0.35,
            ),
            themeMode: _resolveShadcnThemeMode(themeController.themeMode),
            child: child ?? const SizedBox.shrink(),
          ),
          defaultTransition: Transition.cupertino,
          initialRoute: AppRoutes.splash,
          getPages: AppRoutes.getPages,
          initialBinding: BindingsBuilder(() {
            Get.put(AuthController());
            Get.lazyPut(() => AdminController(), fenix: true);
            Get.lazyPut(() => TeacherController(), fenix: true);
            Get.lazyPut(() => StudentController(), fenix: true);
            Get.lazyPut(() => ClassController(), fenix: true);

            Get.put(ThemeController());
            Get.put(InstituteContextService());
            Get.put(InstituteController());
          }),
        );
      },
    );
  }
}
