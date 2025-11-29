import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:campus_care/widgets/inputs/custom_dropdown.dart';
import 'package:campus_care/widgets/buttons/primary_button.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/common/section_header.dart';

class NewMessageScreen extends StatelessWidget {
  const NewMessageScreen({super.key});

  // Static UI data
  static final _parents = List.generate(20, (index) {
    return {
      'id': 'parent_${index + 1}',
      'name': 'Parent ${index + 1}',
      'studentName': 'Student ${index + 1}',
      'studentId': 'STU2024${(index + 1).toString().padLeft(3, '0')}',
    };
  });

  @override
  Widget build(BuildContext context) {
    final messageController = TextEditingController();
    String? selectedParent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Message'),
      ),
      body: SingleChildScrollView(
        child: ResponsivePadding(
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(title: 'Compose Message'),
                const SizedBox(height: 16),
                CustomDropdown<String>(
                  value: selectedParent,
                  labelText: 'Select Parent',
                  hintText: 'Choose a parent',
                  prefixIcon: const Icon(Icons.person),
                  items: _parents.map((parent) => DropdownMenuItem(
                    value: parent['id'],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(parent['name'] as String),
                        Text(
                          'Student: ${parent['studentName']}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  )).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedParent = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: messageController,
                  labelText: 'Message',
                  hintText: 'Type your message here...',
                  maxLines: 6,
                  prefixIcon: const Icon(Icons.message),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  onPressed: () {
                    if (selectedParent == null) {
                      Get.snackbar('Error', 'Please select a parent');
                      return;
                    }
                    if (messageController.text.trim().isEmpty) {
                      Get.snackbar('Error', 'Please enter a message');
                      return;
                    }
                    Get.snackbar('Success', 'Message sent successfully');
                    Get.back();
                  },
                  child: const Text('Send Message'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

