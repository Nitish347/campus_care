import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/controllers/admin_controller.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:campus_care/widgets/common/info_card.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/models/admin/admin.dart';

class AdminListScreen extends GetView<AdminController> {
  const AdminListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;

    // Ensure controller is initialized
    if (!Get.isRegistered<AdminController>()) {
      Get.put(AdminController());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadAdmins(),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed(AppRoutes.addAdmin),
            tooltip: 'Add Admin',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          ResponsivePadding(
            child: CustomTextField(
              hintText: 'Search admins...',
              prefixIcon: const Icon(Icons.search),
              onChanged: controller.searchAdmins,
            ),
          ),

          // Admin Count
          ResponsivePadding(
            child: Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Admins: ${controller.filteredAdmins.length}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )),
          ),

          // Admin List
          Expanded(
            child: Obx(() {
              if (controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredAdmins.isEmpty) {
                return const EmptyState(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'No admins found',
                  message: 'Try adjusting your search criteria',
                );
              }

              return isDesktop
                  ? _buildDesktopTable(context, controller.filteredAdmins)
                  : _buildMobileList(context, controller.filteredAdmins);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(BuildContext context, List<Admin> admins) {
    final theme = Theme.of(context);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: admins.length,
      itemBuilder: (context, index) {
        final admin = admins[index];
        return InfoCard(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.tertiaryContainer,
              child: Text(
                admin.name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: theme.colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              admin.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('ID: ${admin.adminId}'),
                Text('Role: ${admin.role}'),
                Text('Email: ${admin.email}'),
              ],
            ),
            trailing: _buildActions(context, admin),
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable(BuildContext context, List<Admin> admins) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        ),
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            ),
            columns: const [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Admin ID')),
              DataColumn(label: Text('Role')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Phone')),
              DataColumn(label: Text('Actions')),
            ],
            rows: admins.map((admin) {
              return DataRow(
                cells: [
                  DataCell(Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: theme.colorScheme.tertiaryContainer,
                        child: Text(
                          admin.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onTertiaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(admin.name),
                    ],
                  )),
                  DataCell(Text(admin.adminId)),
                  DataCell(Text(admin.role)),
                  DataCell(Text(admin.email)),
                  DataCell(Text(admin.phone)),
                  DataCell(_buildActions(context, admin)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, Admin admin) {
    return PopupMenuButton(
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.visibility),
              SizedBox(width: 8),
              Text('View Details'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'view') {
          _showAdminDetails(context, admin);
        } else if (value == 'edit') {
          Get.snackbar('Info', 'Edit ${admin.name}');
        } else if (value == 'delete') {
          _showDeleteDialog(context, admin);
        }
      },
    );
  }

  void _showAdminDetails(BuildContext context, Admin admin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Admin Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Name', admin.name),
              _buildDetailRow('Admin ID', admin.adminId),
              _buildDetailRow('Email', admin.email),
              _buildDetailRow('Phone', admin.phone),
              _buildDetailRow('Role', admin.role),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Admin admin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Admin'),
        content: Text('Are you sure you want to delete ${admin.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.snackbar('Info', 'Delete functionality coming soon');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
