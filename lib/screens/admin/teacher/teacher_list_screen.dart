import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/controllers/teacher_controller.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:campus_care/widgets/common/info_card.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/models/teacher/teacher.dart';

class TeacherListScreen extends GetView<TeacherController> {
  const TeacherListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;

    // Ensure controller is initialized
    if (!Get.isRegistered<TeacherController>()) {
      Get.put(TeacherController());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadTeachers(),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed(AppRoutes.addTeacher),
            tooltip: 'Add Teacher',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          ResponsivePadding(
            child: CustomTextField(
              hintText: 'Search teachers...',
              prefixIcon: const Icon(Icons.search),
              onChanged: controller.searchTeachers,
            ),
          ),

          // Teacher Count
          ResponsivePadding(
            child: Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Teachers: ${controller.filteredTeachers.length}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )),
          ),

          // Teacher List
          Expanded(
            child: Obx(() {
              if (controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredTeachers.isEmpty) {
                return const EmptyState(
                  icon: Icons.person_outline,
                  title: 'No teachers found',
                  message: 'Try adjusting your search criteria',
                );
              }

              return isDesktop
                  ? _buildDesktopTable(context, controller.filteredTeachers)
                  : _buildMobileList(context, controller.filteredTeachers);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(BuildContext context, List<Teacher> teachers) {
    final theme = Theme.of(context);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: teachers.length,
      itemBuilder: (context, index) {
        final teacher = teachers[index];
        return InfoCard(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.secondaryContainer,
              child: Text(
                teacher.name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: theme.colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              teacher.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('ID: ${teacher.teacherId}'),
                Text('Dept: ${teacher.department}'),
                Text('Email: ${teacher.email}'),
              ],
            ),
            trailing: _buildActions(context, teacher),
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable(BuildContext context, List<Teacher> teachers) {
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
              DataColumn(label: Text('Teacher ID')),
              DataColumn(label: Text('Department')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Phone')),
              DataColumn(label: Text('Actions')),
            ],
            rows: teachers.map((teacher) {
              return DataRow(
                cells: [
                  DataCell(Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: theme.colorScheme.secondaryContainer,
                        child: Text(
                          teacher.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(teacher.name),
                    ],
                  )),
                  DataCell(Text(teacher.teacherId)),
                  DataCell(Text(teacher.department)),
                  DataCell(Text(teacher.email)),
                  DataCell(Text(teacher.phone)),
                  DataCell(_buildActions(context, teacher)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, Teacher teacher) {
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
          _showTeacherDetails(context, teacher);
        } else if (value == 'edit') {
          Get.snackbar('Info', 'Edit ${teacher.name}');
        } else if (value == 'delete') {
          _showDeleteDialog(context, teacher);
        }
      },
    );
  }

  void _showTeacherDetails(BuildContext context, Teacher teacher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Teacher Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Name', teacher.name),
              _buildDetailRow('Teacher ID', teacher.teacherId),
              _buildDetailRow('Email', teacher.email),
              _buildDetailRow('Phone', teacher.phone),
              _buildDetailRow('Department', teacher.department),
              _buildDetailRow('Qualification', teacher.qualification),
              _buildDetailRow('Join Date', teacher.joinDate.toString().split(' ')[0]),
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

  void _showDeleteDialog(BuildContext context, Teacher teacher) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Teacher'),
        content: Text('Are you sure you want to delete ${teacher.name}?'),
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
