import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/services/api/fee_api_service.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/common/info_card.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/student/student_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StudentFeesScreen extends StatefulWidget {
  const StudentFeesScreen({super.key});

  @override
  State<StudentFeesScreen> createState() => _StudentFeesScreenState();
}

class _StudentFeesScreenState extends State<StudentFeesScreen> {
  final FeeApiService _feeApi = FeeApiService();
  final AuthController _authController = Get.find<AuthController>();

  bool _isLoading = true;
  List<Map<String, dynamic>> _pendingFees = [];
  List<Map<String, dynamic>> _paidFees = [];

  @override
  void initState() {
    super.initState();
    _loadFees();
  }

  DateTime _parseDate(dynamic raw) {
    if (raw is int) {
      final ms = raw > 10000000000 ? raw : raw * 1000;
      return DateTime.fromMillisecondsSinceEpoch(ms);
    }
    if (raw is String) {
      final asInt = int.tryParse(raw);
      if (asInt != null) {
        final ms = asInt > 10000000000 ? asInt : asInt * 1000;
        return DateTime.fromMillisecondsSinceEpoch(ms);
      }
      return DateTime.tryParse(raw) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Future<void> _loadFees() async {
    final student = _authController.currentStudent;
    if (student == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      setState(() => _isLoading = true);
      final data = await _feeApi.getFees(studentId: student.id);
      final fees = data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();

      final pending = <Map<String, dynamic>>[];
      final paid = <Map<String, dynamic>>[];

      for (final fee in fees) {
        final status = (fee['status'] ?? '').toString().toLowerCase();
        final amount = (fee['amount'] as num?)?.toDouble() ?? 0;
        final paidAmount = (fee['paid_amount'] as num?)?.toDouble() ?? 0;
        final dueAmount = (amount - paidAmount).clamp(0, amount).toDouble();

        final mapped = <String, dynamic>{
          ...fee,
          'feeType': (fee['fee_type'] ?? fee['feeType'] ?? 'Fee').toString(),
          'amount': dueAmount > 0 ? dueAmount : amount,
          'dueDate': _parseDate(fee['due_date'] ?? fee['dueDate']),
          'paidDate': fee['payment_date'] != null ? _parseDate(fee['payment_date']) : null,
        };

        if (status == 'paid' || dueAmount == 0) {
          paid.add(mapped);
        } else {
          pending.add(mapped);
        }
      }

      pending.sort((a, b) => (a['dueDate'] as DateTime).compareTo(b['dueDate'] as DateTime));
      paid.sort((a, b) {
        final aDate = a['paidDate'] as DateTime? ?? DateTime(1970);
        final bDate = b['paidDate'] as DateTime? ?? DateTime(1970);
        return bDate.compareTo(aDate);
      });

      if (!mounted) return;
      setState(() {
        _pendingFees = pending;
        _paidFees = paid;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double get _totalPending =>
      _pendingFees.fold(0, (sum, fee) => sum + ((fee['amount'] as num?)?.toDouble() ?? 0));
  double get _totalPaid =>
      _paidFees.fold(0, (sum, fee) => sum + ((fee['amount'] as num?)?.toDouble() ?? 0));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: StudentAppBar(
          title: 'Fees & Payments',
          bottom: TabBar(
            tabs: [
              Tab(text: 'Pending (${_pendingFees.length})'),
              Tab(text: 'Paid (${_paidFees.length})'),
            ],
          ),
          extraActions: [
            const SizedBox(width: 6),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: _loadFees,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.refresh, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
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
                            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\u20b9${_totalPending.toStringAsFixed(2)}',
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
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(color: Colors.white70),
                                  ),
                                  Text(
                                    '\u20b9${_totalPaid.toStringAsFixed(2)}',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Container(width: 1, height: 40, color: Colors.white54),
                              Column(
                                children: [
                                  Text(
                                    'Pending',
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(color: Colors.white70),
                                  ),
                                  Text(
                                    '\u20b9${_totalPending.toStringAsFixed(2)}',
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
    BuildContext context,
    List<Map<String, dynamic>> fees,
    bool isPending,
  ) {
    final theme = Theme.of(context);

    if (fees.isEmpty) {
      return EmptyState(
        icon: Icons.payment_outlined,
        title: isPending ? 'No pending fees' : 'No payment history',
        message: isPending ? 'You are all caught up with your payments' : 'No payment records available',
      );
    }

    return ResponsivePadding(
      child: ListView.builder(
        itemCount: fees.length,
        itemBuilder: (context, index) {
          final fee = fees[index];
          final dueDate = fee['dueDate'] as DateTime?;
          final isOverdue = isPending && dueDate != null && dueDate.isBefore(DateTime.now());

          return InfoCard(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isOverdue
                      ? Colors.red.withOpacity(0.1)
                      : theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.payment,
                  color: isOverdue ? Colors.red : theme.colorScheme.onPrimaryContainer,
                ),
              ),
              title: Text(
                fee['feeType'].toString(),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'Amount: \u20b9${((fee['amount'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (dueDate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Due: ${DateFormat('MMM dd, yyyy').format(dueDate)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isOverdue ? Colors.red : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (!isPending && fee['paidDate'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Paid on: ${DateFormat('MMM dd, yyyy').format(fee['paidDate'] as DateTime)}',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.green),
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
                  : const Icon(Icons.check_circle, color: Colors.green),
            ),
          );
        },
      ),
    );
  }
}
