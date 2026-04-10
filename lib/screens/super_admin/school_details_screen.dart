import 'package:campus_care/core/constants/admin_module_permissions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/controllers/super_admin_controller.dart';
import 'package:campus_care/models/admin/admin.dart';
import 'package:campus_care/widgets/common/empty_state.dart';

class SchoolDetailsScreen extends StatefulWidget {
  final Admin school;

  const SchoolDetailsScreen({
    super.key,
    required this.school,
  });

  @override
  State<SchoolDetailsScreen> createState() => _SchoolDetailsScreenState();
}

class _SchoolDetailsScreenState extends State<SchoolDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late SuperAdminController _controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _controller = Get.find<SuperAdminController>();

    // Load school-specific data
    Future.microtask(() {
      _controller.selectSchool(widget.school);
      _controller.loadSchoolStudents(widget.school.id);
      _controller.loadSchoolTeachers(widget.school.id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.school.instituteName),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info_outline), text: 'Overview'),
            Tab(icon: Icon(Icons.people), text: 'Students'),
            Tab(icon: Icon(Icons.person), text: 'Teachers'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(theme),
          _buildStudentsTab(theme),
          _buildTeachersTab(theme),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // School Header Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      widget.school.instituteName.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.school.instituteName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.school.email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Statistics Cards
          Obx(() {
            final schoolStudents = _controller.schoolStudents;
            final schoolTeachers = _controller.schoolTeachers;

            return Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    theme,
                    'Students',
                    '${schoolStudents.length}',
                    Icons.people,
                    theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    theme,
                    'Teachers',
                    '${schoolTeachers.length}',
                    Icons.person,
                    Colors.purple,
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 20),

          // School Information
          Text(
            'School Information',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _buildInfoCard(
            theme,
            'Contact Details',
            [
              _buildInfoRow(theme, Icons.email, 'Email', widget.school.email),
              if (widget.school.phone != null)
                _buildInfoRow(
                    theme, Icons.phone, 'Phone', widget.school.phone!),
            ],
          ),

          const SizedBox(height: 12),

          _buildInfoCard(
            theme,
            'Location',
            [
              if (widget.school.address != null)
                _buildInfoRow(theme, Icons.location_on, 'Address',
                    widget.school.address!),
              if (widget.school.city != null)
                _buildInfoRow(
                    theme, Icons.location_city, 'City', widget.school.city!),
              if (widget.school.state != null)
                _buildInfoRow(theme, Icons.map, 'State', widget.school.state!),
              if (widget.school.country != null)
                _buildInfoRow(
                    theme, Icons.public, 'Country', widget.school.country!),
              if (widget.school.pincode != null)
                _buildInfoRow(
                    theme, Icons.pin_drop, 'Pincode', widget.school.pincode!),
            ],
          ),

          const SizedBox(height: 12),

          _buildInfoCard(
            theme,
            'Admin Details',
            [
              _buildInfoRow(theme, Icons.person, 'Name',
                  '${widget.school.firstName} ${widget.school.lastName}'),
              _buildInfoRow(
                  theme, Icons.email, 'Admin Email', widget.school.email),
              if (widget.school.phone != null)
                _buildInfoRow(
                    theme, Icons.phone, 'Phone', widget.school.phone!),
              if (widget.school.website != null)
                _buildInfoRow(
                    theme, Icons.language, 'Website', widget.school.website!),
            ],
          ),

          const SizedBox(height: 20),

          _buildModulePermissionsCard(theme),

          const SizedBox(height: 24),

          // Access Admin Dashboard Button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                // Navigate to admin dashboard
                // This allows superadmin to access the school's admin dashboard
                Get.toNamed('/admin/dashboard');
              },
              icon: const Icon(Icons.dashboard, size: 24),
              label: const Text('Access Admin Dashboard'),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Management Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to student management for this school
                    Get.toNamed('/admin/students');
                  },
                  icon: const Icon(Icons.people),
                  label: const Text('Manage Students'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to teacher management for this school
                    Get.toNamed('/admin/teachers');
                  },
                  icon: const Icon(Icons.person),
                  label: const Text('Manage Teachers'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsTab(ThemeData theme) {
    return Obx(() {
      final isLoading = _controller.isLoadingSchoolStudents.value;
      final students = _controller.schoolStudents;

      if (isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (students.isEmpty) {
        return EmptyState(
          icon: Icons.people_outline,
          title: 'No Students',
          message: 'No students found in ${widget.school.instituteName}',
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  student.firstName.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                '${student.firstName} ${student.lastName}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(student.email),
                  Text(
                    'Enrollment: ${student.enrollmentNumber}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (student.class_ != null)
                    Text(
                      'Class: ${student.class_}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                ],
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildTeachersTab(ThemeData theme) {
    return Obx(() {
      final isLoading = _controller.isLoadingSchoolTeachers.value;
      final teachers = _controller.schoolTeachers;

      if (isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (teachers.isEmpty) {
        return EmptyState(
          icon: Icons.person_outline,
          title: 'No Teachers',
          message: 'No teachers found in ${widget.school.instituteName}',
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: teachers.length,
        itemBuilder: (context, index) {
          final teacher = teachers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                backgroundColor: Colors.purple.shade100,
                child: Text(
                  teacher.firstName.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: Colors.purple.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                '${teacher.firstName} ${teacher.lastName}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(teacher.email),
                  if (teacher.department != null)
                    Text(
                      'Department: ${teacher.department}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  // if (teacher. != null && teacher.subjects!.isNotEmpty)
                  //   Text(
                  //     'Subjects: ${teacher.subjects!.join(", ")}',
                  //     style: theme.textTheme.bodySmall?.copyWith(
                  //       color: Colors.purple,
                  //     ),
                  //   ),
                ],
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildModulePermissionsCard(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final isLoading = _controller.isLoadingSchoolModulePermissions.value;
          final isUpdating =
              _controller.isUpdatingSchoolModulePermissions.value;
          final permissions = {
            ...defaultAdminModulePermissions,
            ..._controller.schoolModulePermissions,
          };

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Module Access',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Control which modules this admin can access in their dashboard.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (isLoading) ...[
                const SizedBox(height: 12),
                const LinearProgressIndicator(minHeight: 3),
              ],
              const SizedBox(height: 8),
              ...AdminModulePermissionKeys.all.map((key) {
                final label = adminModulePermissionLabels[key] ?? key;
                return SwitchListTile.adaptive(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(label),
                  value: permissions[key] ?? true,
                  onChanged: isLoading || isUpdating
                      ? null
                      : (value) => _controller.toggleSchoolModulePermission(
                            widget.school.id,
                            key,
                            value,
                          ),
                );
              }),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    ThemeData theme,
    String title,
    List<Widget> children,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
