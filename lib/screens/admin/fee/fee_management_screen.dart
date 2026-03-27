import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:campus_care/widgets/inputs/custom_dropdown.dart';
import 'package:campus_care/widgets/buttons/primary_button.dart';
import 'package:campus_care/widgets/common/info_card.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/common/section_header.dart';

import 'package:campus_care/widgets/admin/admin_page_header.dart';
class FeeManagementScreen extends StatefulWidget {
  const FeeManagementScreen({super.key});

  @override
  State<FeeManagementScreen> createState() => _FeeManagementScreenState();
}

class _FeeManagementScreenState extends State<FeeManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String? _selectedStudent;
  String? _selectedFeeType;
  DateTime? _dueDate;

  // Static UI data
  static final _students = List.generate(20, (index) {
    return {
      'id': 'student_${index + 1}',
      'name': 'Student ${index + 1}',
      'studentId': 'STU2024${(index + 1).toString().padLeft(3, '0')}',
    };
  });

  static final _pendingFees = [
    {
      'id': 'fee_001',
      'studentId': 'student_001',
      'studentName': 'Student 1',
      'feeType': 'Tuition Fee',
      'amount': 5000.0,
      'dueDate': DateTime.now().add(const Duration(days: 15)),
      'status': 'pending',
    },
    {
      'id': 'fee_002',
      'studentId': 'student_002',
      'studentName': 'Student 2',
      'feeType': 'Library Fee',
      'amount': 500.0,
      'dueDate': DateTime.now().add(const Duration(days: 20)),
      'status': 'pending',
    },
  ];

  static final _paidFees = [
    {
      'id': 'fee_003',
      'studentId': 'student_001',
      'studentName': 'Student 1',
      'feeType': 'Sports Fee',
      'amount': 1000.0,
      'paidDate': DateTime.now().subtract(const Duration(days: 10)),
      'status': 'paid',
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
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _addFee() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStudent == null || _selectedFeeType == null || _dueDate == null) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    Get.snackbar('Success', 'Fee added successfully');
    
    _formKey.currentState!.reset();
    setState(() {
      _selectedStudent = null;
      _selectedFeeType = null;
      _dueDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AdminPageHeader(
        subtitle: 'Track student fee collections',
        icon: Icons.payments,
        showBreadcrumb: true,
        breadcrumbLabel: 'Fees',
          showBackButton: true,
          title: const Text('Fee Management'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Add Fee'),
              Tab(text: 'Pending'),
              Tab(text: 'Paid'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Add Fee Tab
            SingleChildScrollView(
              child: ResponsivePadding(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SectionHeader(title: 'Add New Fee'),
                      const SizedBox(height: 16),
                      CustomDropdown<String>(
                        value: _selectedStudent,
                        labelText: 'Student',
                        prefixIcon: const Icon(Icons.person),
                        items: _students.map((student) => DropdownMenuItem(
                          value: student['id'],
                          child: Text('${student['name']} (${student['studentId']})'),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStudent = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select student';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomDropdown<String>(
                        value: _selectedFeeType,
                        labelText: 'Fee Type',
                        prefixIcon: const Icon(Icons.payment),
                        items: ['Tuition Fee', 'Library Fee', 'Sports Fee', 'Lab Fee', 'Transport Fee']
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedFeeType = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select fee type';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _amountController,
                        labelText: 'Amount',
                        hintText: 'Enter amount',
                        keyboardType: TextInputType.number,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            '₹ ',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter amount';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        readOnly: true,
                        labelText: 'Due Date',
                        hintText: _dueDate == null
                            ? 'Select Due Date'
                            : DateFormat('MMM dd, yyyy').format(_dueDate!),
                        prefixIcon: const Icon(Icons.calendar_today),
                        onTap: () => _selectDueDate(context),
                        validator: (value) {
                          if (_dueDate == null) {
                            return 'Please select due date';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        onPressed: _addFee,
                        child: const Text('Add Fee'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Pending Fees Tab
            Column(
              children: [
                ResponsivePadding(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange,
                          Colors.deepOrange,
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
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _buildFeesList(context, _pendingFees, true),
                ),
              ],
            ),

            // Paid Fees Tab
            Column(
              children: [
                ResponsivePadding(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green,
                          Colors.teal,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Total Paid',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${_totalPaid.toStringAsFixed(2)}',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _buildFeesList(context, _paidFees, false),
                ),
              ],
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
            ? 'All fees have been paid!'
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
                  Text('Student: ${fee['studentName']}'),
                  Text('Amount: ₹${(fee['amount'] as num).toStringAsFixed(2)}'),
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
                  ? (isOverdue
                      ? Chip(
                          label: const Text(
                            'Overdue',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          backgroundColor: Colors.red,
                        )
                      : ElevatedButton(
                          onPressed: () {
                            Get.snackbar('Success', 'Fee marked as paid');
                          },
                          child: const Text('Mark Paid'),
                        ))
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
