import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:campus_care/widgets/buttons/primary_button.dart';
import 'package:campus_care/widgets/common/info_card.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/common/section_header.dart';
import 'package:campus_care/widgets/student/student_app_bar.dart';
import 'package:campus_care/utils/app_notifier.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> fee;

  const PaymentScreen({
    super.key,
    required this.fee,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _isLoading = false.obs;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardNameController.dispose();
    super.dispose();
  }

  Future<void> _submitPayment() async {
    if (_cardNameController.text.trim().isEmpty ||
        _cardNumberController.text.trim().isEmpty ||
        _expiryController.text.trim().isEmpty ||
        _cvvController.text.trim().isEmpty) {
      AppNotifier.error('Error', 'Please fill all payment details');
      return;
    }

    _isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));
    _isLoading.value = false;

    if (!mounted) return;
    Get.offNamed(AppRoutes.studentFees);
    AppNotifier.afterNavigation('Success', 'Payment successful!');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final feeType = widget.fee['feeType']?.toString() ?? 'Fee';
    final amount =
        widget.fee['amount'] is num ? widget.fee['amount'] as num : 0;

    return Scaffold(
      appBar: const StudentAppBar(title: 'Payment'),
      body: SingleChildScrollView(
        child: ResponsivePadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(title: 'Fee Details'),
              const SizedBox(height: 12),
              InfoCard(
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        feeType,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle:
                          Text('Amount: Rs. ${amount.toStringAsFixed(2)}'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SectionHeader(title: 'Payment Information'),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _cardNameController,
                labelText: 'Card Holder Name',
                hintText: 'Enter name on card',
                prefixIcon: const Icon(Icons.person),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _cardNumberController,
                labelText: 'Card Number',
                hintText: '1234 5678 9012 3456',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.credit_card),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _expiryController,
                      labelText: 'Expiry Date',
                      hintText: 'MM/YY',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _cvvController,
                      labelText: 'CVV',
                      hintText: '123',
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      prefixIcon: const Icon(Icons.lock),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Obx(
                () => PrimaryButton(
                  onPressed: _isLoading.value ? null : _submitPayment,
                  isLoading: _isLoading.value,
                  child: Text('Pay Rs. ${amount.toStringAsFixed(2)}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
