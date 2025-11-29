import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:campus_care/widgets/buttons/primary_button.dart';
import 'package:campus_care/widgets/common/info_card.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/common/section_header.dart';

class PaymentScreen extends StatelessWidget {
  final Map<String, dynamic> fee;

  const PaymentScreen({
    super.key,
    required this.fee,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardNumberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();
    final cardNameController = TextEditingController();
    final isLoading = false.obs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
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
                        fee['feeType'] as String,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text('Amount: ₹${(fee['amount'] as num).toStringAsFixed(2)}'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SectionHeader(title: 'Payment Information'),
              const SizedBox(height: 16),
              CustomTextField(
                controller: cardNameController,
                labelText: 'Card Holder Name',
                hintText: 'Enter name on card',
                prefixIcon: const Icon(Icons.person),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: cardNumberController,
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
                      controller: expiryController,
                      labelText: 'Expiry Date',
                      hintText: 'MM/YY',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: cvvController,
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
              Obx(() => PrimaryButton(
                    onPressed: isLoading.value
                        ? null
                        : () async {
                            if (cardNumberController.text.isEmpty ||
                                expiryController.text.isEmpty ||
                                cvvController.text.isEmpty) {
                              Get.snackbar('Error', 'Please fill all payment details');
                              return;
                            }
                            isLoading.value = true;
                            await Future.delayed(const Duration(seconds: 2));
                            isLoading.value = false;
                            Get.snackbar('Success', 'Payment successful!');
                            Get.offNamed(AppRoutes.studentFees);
                          },
                    isLoading: isLoading.value,
                    child: Text('Pay ₹${(fee['amount'] as num).toStringAsFixed(2)}'),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

