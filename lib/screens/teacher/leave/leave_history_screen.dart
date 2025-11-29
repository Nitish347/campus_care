import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/controllers/leave_controller.dart';
import 'package:campus_care/widgets/common/info_card.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';

class LeaveHistoryScreen extends StatelessWidget {
  const LeaveHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.put(LeaveController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave History'),
      ),
      body: Obx(() {
        if (controller.leaves.isEmpty) {
          return EmptyState(
            icon: Icons.history_outlined,
            title: 'No leave history',
            message: 'You haven\'t applied for any leaves yet',
          );
        }

        return ResponsivePadding(
          child: ListView.builder(
            itemCount: controller.leaves.length,
            itemBuilder: (context, index) {
              final leave = controller.leaves[index];
              final status = leave['status'] as String;
              final statusColor = controller.getStatusColor(status);

              return InfoCard(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getStatusColor(statusColor).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getStatusIcon(status),
                      color: _getStatusColor(statusColor),
                    ),
                  ),
                  title: Text(
                    leave['type'],
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '${controller.formatDate(leave['fromDate'] as DateTime)} - ${controller.formatDate(leave['toDate'] as DateTime)}',
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Reason: ${leave['reason']}',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Applied: ${controller.formatDate(leave['appliedDate'] as DateTime)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(
                      status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: _getStatusColor(statusColor),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Color _getStatusColor(String color) {
    switch (color) {
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }
}

