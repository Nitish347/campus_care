import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/models/institute/institute_model.dart';
import 'package:campus_care/controllers/institute_controller.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';

class InstituteManagementScreen extends StatelessWidget {
  const InstituteManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final InstituteController controller = Get.find<InstituteController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Institute Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_outlined),
            onPressed: () => _showFilterDialog(context, controller),
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context, controller),
            tooltip: 'Search',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.addEditInstitute),
        icon: const Icon(Icons.add),
        label: const Text('Add Institute'),
      ),
      body: Column(
        children: [
          // Summary Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.secondaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Obx(() {
              final stats = controller.getInstituteStats();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    context,
                    Icons.business,
                    '${stats['total']}',
                    'Total',
                    theme.colorScheme.primary,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                  _buildSummaryItem(
                    context,
                    Icons.check_circle,
                    '${stats['active']}',
                    'Active',
                    Colors.green,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                  _buildSummaryItem(
                    context,
                    Icons.pending,
                    '${stats['pending']}',
                    'Pending',
                    Colors.orange,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                  _buildSummaryItem(
                    context,
                    Icons.warning,
                    '${stats['expired']}',
                    'Expired',
                    Colors.red,
                  ),
                ],
              );
            }),
          ),

          // Institute List
          Expanded(
            child: Obx(() {
              final institutes = controller.filteredInstitutes;

              if (institutes.isEmpty) {
                return EmptyState(
                  icon: Icons.business_outlined,
                  title: 'No institutes found',
                  message: controller.searchQuery.value.isNotEmpty
                      ? 'No institutes match your search'
                      : 'No institutes have been added yet',
                );
              }

              return ResponsivePadding(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: institutes.length,
                  itemBuilder: (context, index) {
                    final institute = institutes[index];
                    return _buildInstituteCard(context, institute, controller);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
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
    );
  }

  Widget _buildInstituteCard(
    BuildContext context,
    Institute institute,
    InstituteController controller,
  ) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(institute);
    final planColor = _getPlanColor(institute.subscriptionPlan);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Get.toNamed(
          AppRoutes.instituteDetail,
          arguments: institute,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Logo/Icon
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      institute.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name and Code
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          institute.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          institute.code,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getStatusText(institute),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Info Row
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      institute.address.split(',').take(2).join(','),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Stats Row
              Row(
                children: [
                  _buildStatBadge(
                    context,
                    Icons.people,
                    '${institute.totalStudents} Students',
                    theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  _buildStatBadge(
                    context,
                    Icons.person,
                    '${institute.totalTeachers} Teachers',
                    Colors.purple,
                  ),
                  const SizedBox(width: 8),
                  _buildStatBadge(
                    context,
                    Icons.class_,
                    '${institute.totalClasses} Classes',
                    Colors.teal,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Subscription Row
              Row(
                children: [
                  // Plan Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: planColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.workspace_premium,
                          size: 16,
                          color: planColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          institute.subscriptionPlan.toUpperCase(),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: planColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Expiry Info
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Expires: ${DateFormat('MMM dd, yyyy').format(institute.subscriptionEndDate)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  // Action Buttons
                  IconButton(
                    icon: const Icon(Icons.visibility_outlined),
                    iconSize: 20,
                    onPressed: () => Get.toNamed(
                      AppRoutes.instituteDetail,
                      arguments: institute,
                    ),
                    tooltip: 'View Details',
                    color: theme.colorScheme.primary,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    iconSize: 20,
                    onPressed: () => Get.toNamed(
                      AppRoutes.addEditInstitute,
                      arguments: institute,
                    ),
                    tooltip: 'Edit',
                    color: theme.colorScheme.primary,
                  ),
                  IconButton(
                    icon: Icon(
                      institute.isActive
                          ? Icons.toggle_on
                          : Icons.toggle_off_outlined,
                    ),
                    iconSize: 24,
                    onPressed: () => _showToggleDialog(
                      context,
                      institute,
                      controller,
                    ),
                    tooltip: institute.isActive ? 'Deactivate' : 'Activate',
                    color: institute.isActive ? Colors.green : Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(Institute institute) {
    if (!institute.isVerified) return Colors.orange;
    if (!institute.isActive) return Colors.grey;
    if (institute.subscriptionStatus == 'expired') return Colors.red;
    if (institute.isSubscriptionExpiringSoon) return Colors.orange;
    return Colors.green;
  }

  String _getStatusText(Institute institute) {
    if (!institute.isVerified) return 'PENDING';
    if (!institute.isActive) return 'INACTIVE';
    if (institute.subscriptionStatus == 'expired') return 'EXPIRED';
    if (institute.subscriptionStatus == 'trial') return 'TRIAL';
    return 'ACTIVE';
  }

  Color _getPlanColor(String plan) {
    switch (plan.toLowerCase()) {
      case 'premium':
        return Colors.purple;
      case 'standard':
        return Colors.blue;
      case 'basic':
        return Colors.green;
      case 'trial':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showFilterDialog(BuildContext context, InstituteController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Institutes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Status'),
            const SizedBox(height: 8),
            Obx(() => Wrap(
                  spacing: 8,
                  children: ['All', 'Active', 'Inactive', 'Pending', 'Expired']
                      .map((status) => ChoiceChip(
                            label: Text(status),
                            selected:
                                controller.selectedStatusFilter.value == status,
                            onSelected: (selected) {
                              if (selected) {
                                controller.setStatusFilter(status);
                              }
                            },
                          ))
                      .toList(),
                )),
            const SizedBox(height: 16),
            const Text('Subscription Plan'),
            const SizedBox(height: 8),
            Obx(() => Wrap(
                  spacing: 8,
                  children: ['All', 'Premium', 'Standard', 'Basic', 'Trial']
                      .map((plan) => ChoiceChip(
                            label: Text(plan),
                            selected:
                                controller.selectedPlanFilter.value == plan,
                            onSelected: (selected) {
                              if (selected) {
                                controller.setPlanFilter(plan);
                              }
                            },
                          ))
                      .toList(),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clearFilters();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context, InstituteController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Institutes'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter institute name, code, or email',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) => controller.setSearchQuery(value),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.setSearchQuery('');
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showToggleDialog(
    BuildContext context,
    Institute institute,
    InstituteController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text('${institute.isActive ? 'Deactivate' : 'Activate'} Institute'),
        content: Text(
          'Are you sure you want to ${institute.isActive ? 'deactivate' : 'activate'} ${institute.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              controller.toggleInstituteStatus(institute.id);
              Navigator.pop(context);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
