import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/controllers/password_controller.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:campus_care/widgets/buttons/primary_button.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/common/section_header.dart';

import 'package:campus_care/widgets/admin/admin_page_header.dart';
class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PasswordController());

    return Scaffold(
      appBar: AdminPageHeader(
        subtitle: 'Update your security credentials',
        icon: Icons.password,
        showBreadcrumb: true,
        breadcrumbLabel: 'Security',
        showBackButton: true,
        title: const Text('Change Password'),
      ),
      body: SingleChildScrollView(
        child: ResponsivePadding(
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(title: 'Change Your Password'),
                const SizedBox(height: 24),
                Obx(() => CustomTextField(
                      controller: controller.currentPasswordController,
                      labelText: 'Current Password',
                      hintText: 'Enter current password',
                      obscureText: controller.obscureCurrentPassword.value,
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscureCurrentPassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: controller.toggleCurrentPasswordVisibility,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter current password';
                        }
                        return null;
                      },
                    )),
                const SizedBox(height: 16),
                Obx(() => CustomTextField(
                      controller: controller.newPasswordController,
                      labelText: 'New Password',
                      hintText: 'Enter new password',
                      obscureText: controller.obscureNewPassword.value,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscureNewPassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: controller.toggleNewPasswordVisibility,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter new password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    )),
                const SizedBox(height: 16),
                Obx(() => CustomTextField(
                      controller: controller.confirmPasswordController,
                      labelText: 'Confirm New Password',
                      hintText: 'Confirm new password',
                      obscureText: controller.obscureConfirmPassword.value,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscureConfirmPassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: controller.toggleConfirmPasswordVisibility,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm new password';
                        }
                        if (value != controller.newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    )),
                const SizedBox(height: 24),
                Obx(() => PrimaryButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.changePassword,
                      isLoading: controller.isLoading.value,
                      child: const Text('Change Password'),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

