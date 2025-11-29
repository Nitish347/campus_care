import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/common/info_card.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';

class StudentFeesScreen extends StatelessWidget {
  const StudentFeesScreen({super.key});

  // Static UI data
  static final _pendingFees = [
    {
      'feeType': 'Tuition Fee',
      'amount': 5000.0,
      'dueDate': DateTime.now().add(const Duration(days: 15)),
    },
    {
      'feeType': 'Library Fee',
      'amount': 500.0,
      'dueDate': DateTime.now().add(const Duration(days: 20)),
    },
  ];

  static final _paidFees = [
    {
      'feeType': 'Sports Fee',
      'amount': 1000.0,
      'paidDate': DateTime.now().subtract(const Duration(days: 10)),
    },
  ];

  static final _totalPending = _pendingFees.fold<double>(
    0.0,
    (sum, f) => sum + (f['amount'] as num).toDouble(),
  );
  static final _totalPaid = _paidFees.fold<double>(
    0.0,
    (sum, f) => sum + (f['amount'] as num).toDouble(),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Fees & Payments'),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => Get.toNamed(AppRoutes.studentNotifications),
              tooltip: 'Notifications',
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Pending (${_pendingFees.length})'),
              Tab(text: 'Paid (${_paidFees.length})'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Summary Card
            ResponsivePadding(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'Total Pending',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${_totalPending.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Paid',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              '₹${_totalPaid.toStringAsFixed(2)}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white54,
                        ),
                        Column(
                          children: [
                            Text(
                              'Pending',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              '₹${_totalPending.toStringAsFixed(2)}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildFeesList(context, _pendingFees, true),
                  _buildFeesList(context, _paidFees, false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeesList(
      BuildContext context, List<Map<String, dynamic>> fees, bool isPending) {
    final theme = Theme.of(context);

    if (fees.isEmpty) {
      return EmptyState(
        icon: Icons.payment_outlined,
        title: isPending ? 'No pending fees' : 'No payment history',
        message: isPending
            ? 'You\'re all caught up with your payments!'
            : 'No payment records available',
      );
    }

    return ResponsivePadding(
      child: ListView.builder(
        itemCount: fees.length,
        itemBuilder: (context, index) {
          final fee = fees[index];
          final dueDate = fee['dueDate'] as DateTime?;
          final isOverdue =
              isPending && dueDate != null && dueDate.isBefore(DateTime.now());

          return InfoCard(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isOverdue
                      ? Colors.red.withValues(alpha: 0.1)
                      : theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.payment,
                  color: isOverdue
                      ? Colors.red
                      : theme.colorScheme.onPrimaryContainer,
                ),
              ),
              title: Text(
                fee['feeType'],
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'Amount: ₹${(fee['amount'] as num).toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (dueDate != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: isOverdue
                              ? Colors.red
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Due: ${DateFormat('MMM dd, yyyy').format(dueDate)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isOverdue ? Colors.red : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (!isPending && fee['paidDate'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Paid on: ${DateFormat('MMM dd, yyyy').format(fee['paidDate'] as DateTime)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                      ),
                    ),
                  ],
                ],
              ),
              trailing: isPending
                  ? ElevatedButton(
                      onPressed: () {
                        Get.toNamed(AppRoutes.payment, arguments: fee);
                      },
                      child: const Text('Pay Now'),
                    )
                  : Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
            ),
          );
        },
      ),
    );
  }
}
