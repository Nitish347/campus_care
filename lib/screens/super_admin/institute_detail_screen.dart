import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/models/institute/institute_model.dart';
import 'package:campus_care/controllers/institute_controller.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/services/institute_context_service.dart';

class InstituteDetailScreen extends StatelessWidget {
  const InstituteDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Institute institute = Get.arguments as Institute;
    final InstituteController controller = Get.find<InstituteController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Institute Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Get.toNamed(
              AppRoutes.addEditInstitute,
              arguments: institute,
            ),
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteDialog(context, institute, controller),
            tooltip: 'Delete',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        institute.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            institute.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            institute.code,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: institute.isActive
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  institute.isActive ? 'ACTIVE' : 'INACTIVE',
                                  style: TextStyle(
                                    color: institute.isActive
                                        ? Colors.green
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (!institute.isVerified)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'PENDING VERIFICATION',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Statistics
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    Icons.people,
                    '${institute.totalStudents}',
                    'Students',
                    theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    Icons.person,
                    '${institute.totalTeachers}',
                    'Teachers',
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    Icons.class_,
                    '${institute.totalClasses}',
                    'Classes',
                    Colors.teal,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Basic Information
            Text(
              'Basic Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(
                        context, Icons.email, 'Email', institute.email),
                    const Divider(),
                    _buildInfoRow(
                        context, Icons.phone, 'Phone', institute.phone),
                    const Divider(),
                    _buildInfoRow(context, Icons.location_on, 'Address',
                        institute.address),
                    if (institute.website != null) ...[
                      const Divider(),
                      _buildInfoRow(context, Icons.language, 'Website',
                          institute.website!),
                    ],
                    if (institute.establishedDate != null) ...[
                      const Divider(),
                      _buildInfoRow(
                        context,
                        Icons.calendar_today,
                        'Established',
                        DateFormat('MMMM dd, yyyy')
                            .format(institute.establishedDate!),
                      ),
                    ],
                    if (institute.affiliationNumber != null) ...[
                      const Divider(),
                      _buildInfoRow(
                        context,
                        Icons.verified,
                        'Affiliation',
                        institute.affiliationNumber!,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Contact Person
            Text(
              'Contact Person',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(context, Icons.person, 'Name',
                        institute.contactPersonName),
                    const Divider(),
                    _buildInfoRow(context, Icons.email, 'Email',
                        institute.contactPersonEmail),
                    const Divider(),
                    _buildInfoRow(context, Icons.phone, 'Phone',
                        institute.contactPersonPhone),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Subscription Details
            Text(
              'Subscription Details',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(
                      context,
                      Icons.workspace_premium,
                      'Plan',
                      institute.subscriptionPlan.toUpperCase(),
                    ),
                    const Divider(),
                    _buildInfoRow(
                      context,
                      Icons.info,
                      'Status',
                      institute.subscriptionStatus.toUpperCase(),
                    ),
                    const Divider(),
                    _buildInfoRow(
                      context,
                      Icons.calendar_today,
                      'Start Date',
                      DateFormat('MMMM dd, yyyy')
                          .format(institute.subscriptionStartDate),
                    ),
                    const Divider(),
                    _buildInfoRow(
                      context,
                      Icons.event,
                      'End Date',
                      DateFormat('MMMM dd, yyyy')
                          .format(institute.subscriptionEndDate),
                    ),
                    const Divider(),
                    _buildInfoRow(
                      context,
                      Icons.timer,
                      'Days Remaining',
                      institute.subscriptionDaysRemaining,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                // Access Dashboard Button (for Super Admin)
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      // Set institute context and navigate to admin dashboard
                      final contextService =
                          Get.find<InstituteContextService>();
                      await contextService.setInstituteContext(institute);
                      Get.toNamed(AppRoutes.adminDashboard);
                    },
                    icon: const Icon(Icons.dashboard),
                    label: const Text('Access Dashboard'),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Other Action Buttons
            Row(
              children: [
                if (!institute.isVerified)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        controller.verifyInstitute(institute.id);
                        Get.back();
                      },
                      icon: const Icon(Icons.verified),
                      label: const Text('Verify Institute'),
                    ),
                  ),
                if (institute.isVerified) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _showRenewDialog(context, institute, controller),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Renew Subscription'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        controller.toggleInstituteStatus(institute.id);
                        Get.back();
                      },
                      icon: Icon(institute.isActive
                          ? Icons.block
                          : Icons.check_circle),
                      label:
                          Text(institute.isActive ? 'Deactivate' : 'Activate'),
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            institute.isActive ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
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
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    Institute institute,
    InstituteController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Institute'),
        content: Text(
            'Are you sure you want to delete ${institute.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              controller.deleteInstitute(institute.id);
              Navigator.pop(context);
              Get.back();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showRenewDialog(
    BuildContext context,
    Institute institute,
    InstituteController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renew Subscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Current expiry: ${DateFormat('MMM dd, yyyy').format(institute.subscriptionEndDate)}'),
            const SizedBox(height: 16),
            const Text('Select renewal period:'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newEndDate = DateTime.now().add(const Duration(days: 365));
              controller.renewSubscription(institute.id, newEndDate);
              Navigator.pop(context);
            },
            child: const Text('1 Year'),
          ),
          TextButton(
            onPressed: () {
              final newEndDate = DateTime.now().add(const Duration(days: 180));
              controller.renewSubscription(institute.id, newEndDate);
              Navigator.pop(context);
            },
            child: const Text('6 Months'),
          ),
        ],
      ),
    );
  }
}
