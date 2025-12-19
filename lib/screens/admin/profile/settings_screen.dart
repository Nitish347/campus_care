import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/controllers/settings_controller.dart';
import 'package:campus_care/controllers/theme_controller.dart';
import 'package:campus_care/widgets/common/info_card.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/common/section_header.dart';
import 'package:campus_care/widgets/buttons/primary_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.put(SettingsController());
    final themeController = Get.find<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          TextButton(
            onPressed: controller.saveSettings,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: ResponsivePadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(title: 'Appearance'),
              const SizedBox(height: 12),
              InfoCard(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.dark_mode),
                      title: const Text('Theme'),
                      subtitle: Obx(() => Text(
                            themeController.themeMode == ThemeMode.light
                                ? 'Light Mode'
                                : themeController.themeMode == ThemeMode.dark
                                    ? 'Dark Mode'
                                    : 'System Default',
                          )),
                      trailing: Obx(() => Switch(
                            value: theme.brightness == Brightness.dark,
                            onChanged: (value) {
                              themeController.toggleTheme();
                            },
                          )),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SectionHeader(title: 'Notifications'),
              const SizedBox(height: 12),
              InfoCard(
                child: Column(
                  children: [
                    Obx(() => SwitchListTile(
                          secondary: const Icon(Icons.notifications),
                          title: const Text('Enable Notifications'),
                          subtitle: const Text('Receive app notifications'),
                          value: controller.notificationsEnabled.value,
                          onChanged: controller.toggleNotifications,
                        )),
                    const Divider(),
                    Obx(() => SwitchListTile(
                          secondary: const Icon(Icons.email),
                          title: const Text('Email Notifications'),
                          subtitle: const Text('Receive email notifications'),
                          value: controller.emailNotifications.value,
                          onChanged: controller.notificationsEnabled.value
                              ? controller.toggleEmailNotifications
                              : null,
                        )),
                    const Divider(),
                    Obx(() => SwitchListTile(
                          secondary: const Icon(Icons.notifications_active),
                          title: const Text('Push Notifications'),
                          subtitle: const Text('Receive push notifications'),
                          value: controller.pushNotifications.value,
                          onChanged: controller.notificationsEnabled.value
                              ? controller.togglePushNotifications
                              : null,
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SectionHeader(title: 'Language'),
              const SizedBox(height: 12),
              InfoCard(
                child: Obx(() => ListTile(
                      leading: const Icon(Icons.language),
                      title: const Text('Language'),
                      subtitle: Text(controller.language.value),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showLanguageDialog(context, controller);
                      },
                    )),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                onPressed: controller.saveSettings,
                child: const Text('Save Settings'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'Spanish', 'French', 'German']
              .map((lang) => Obx(() => RadioListTile<String>(
                    title: Text(lang),
                    value: lang,
                    groupValue: controller.language.value,
                    onChanged: (value) {
                      if (value != null) {
                        controller.setLanguage(value);
                        Navigator.pop(context);
                      }
                    },
                  )))
              .toList(),
        ),
      ),
    );
  }
}

