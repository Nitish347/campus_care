import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:campus_care/widgets/inputs/custom_dropdown.dart';
import 'package:campus_care/widgets/buttons/primary_button.dart';
import 'package:campus_care/widgets/common/info_card.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/common/section_header.dart';

class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authController = Get.find<AuthController>();
    final user = authController.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Leave'),
      ),
      body: SingleChildScrollView(
        child: ResponsivePadding(
          child: Column(
            children: [
              // Profile Header
              InfoCard(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          user?.name.substring(0, 1).toUpperCase() ?? 'T',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.name ?? 'Teacher',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        onPressed: () {
                          _showEditProfileDialog(context);
                        },
                        child: const Text('Edit Profile'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Personal Information
              SectionHeader(title: 'Personal Information'),
              const SizedBox(height: 12),
              InfoCard(
                child: Column(
                  children: [
                    _buildInfoTile(context, 'Email', user?.email ?? ''),
                    const Divider(),
                    _buildInfoTile(context, 'Phone', user?.phone ?? 'Not provided'),
                    const Divider(),
                    _buildInfoTile(context, 'Role', 'Teacher'),
                    const Divider(),
                    _buildInfoTile(context, 'Department', 'Mathematics'),
                    const Divider(),
                    _buildInfoTile(context, 'Experience', '5 years'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Leave Management
              SectionHeader(title: 'Leave Management'),
              const SizedBox(height: 12),
              InfoCard(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Leave Balance'),
                      trailing: Text(
                        '15 days',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.add_circle_outline),
                      title: const Text('Apply for Leave'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showLeaveDialog(context);
                      },
                    ),
                    const Divider(),
                      ListTile(
                        leading: const Icon(Icons.history),
                        title: const Text('Leave History'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Get.toNamed(AppRoutes.leaveHistory);
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              SectionHeader(title: 'Quick Actions'),
              const SizedBox(height: 12),
              InfoCard(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.lock),
                      title: const Text('Change Password'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Get.toNamed(AppRoutes.changePassword);
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('Settings'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Get.toNamed(AppRoutes.settings);
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Logout', style: TextStyle(color: Colors.red)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => authController.logout(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      subtitle: Text(
        value,
        style: theme.textTheme.bodyLarge,
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser;
    
    final nameController = TextEditingController(text: user?.name ?? '');
    final phoneController = TextEditingController(text: user?.phone ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: nameController,
                labelText: 'Name',
                prefixIcon: const Icon(Icons.person),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: phoneController,
                labelText: 'Phone',
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            onPressed: () {
              Navigator.pop(context);
              Get.snackbar('Success', 'Profile updated successfully');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLeaveDialog(BuildContext context) {
    final fromDateController = TextEditingController();
    final toDateController = TextEditingController();
    final reasonController = TextEditingController();
    String? selectedLeaveType;
    DateTime? fromDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Apply for Leave'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomDropdown<String>(
                  value: selectedLeaveType,
                  labelText: 'Leave Type',
                  items: ['Sick Leave', 'Casual Leave', 'Earned Leave', 'Other']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedLeaveType = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  readOnly: true,
                  controller: fromDateController,
                  labelText: 'From Date',
                  prefixIcon: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        fromDate = picked;
                        fromDateController.text = DateFormat('MMM dd, yyyy').format(picked);
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  readOnly: true,
                  controller: toDateController,
                  labelText: 'To Date',
                  prefixIcon: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: fromDate ?? DateTime.now(),
                      firstDate: fromDate ?? DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        toDateController.text = DateFormat('MMM dd, yyyy').format(picked);
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: reasonController,
                  labelText: 'Reason',
                  maxLines: 3,
                  prefixIcon: const Icon(Icons.note),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            PrimaryButton(
              onPressed: () {
                Navigator.pop(context);
                Get.snackbar('Success', 'Leave application submitted');
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
