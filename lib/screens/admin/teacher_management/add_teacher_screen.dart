import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/models/teacher/teacher.dart';
import 'package:campus_care/controllers/teacher_controller.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:campus_care/widgets/buttons/primary_button.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/common/section_header.dart';

class AddTeacherScreen extends StatefulWidget {
  const AddTeacherScreen({super.key});

  @override
  State<AddTeacherScreen> createState() => _AddTeacherScreenState();
}

class _AddTeacherScreenState extends State<AddTeacherScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _departmentController = TextEditingController();

  final TeacherController _teacherController = Get.find<TeacherController>();

  DateTime? _hireDate;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _selectHireDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _hireDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _hireDate = picked;
      });
    }
  }

  Future<void> _saveTeacher() async {
    if (!_formKey.currentState!.validate()) return;

    // Split name
    final nameParts = _nameController.text.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '-';

    final teacher = Teacher(
      id: '', // Backend generates this
      firstName: firstName,
      lastName: lastName,
      email: _emailController.text,
      password: _passwordController.text, // Include password for creation
      phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      address:
          _addressController.text.isNotEmpty ? _addressController.text : null,
      department: _departmentController.text.isNotEmpty
          ? _departmentController.text
          : null,
      hireDate: _hireDate,
      institute: '', // Backend handles this
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _teacherController.addTeacher(teacher);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Teacher'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTeacher,
            tooltip: 'Save Teacher',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: ResponsivePadding(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Personal Information
                SectionHeader(title: 'Personal Information'),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Full Name *',
                  hintText: 'Enter full name',
                  prefixIcon: const Icon(Icons.person),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email *',
                  hintText: 'Enter email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password *',
                  hintText: 'Enter password',
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _phoneController,
                  labelText: 'Phone',
                  hintText: 'Enter phone number',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _addressController,
                  labelText: 'Address',
                  hintText: 'Enter address',
                  maxLines: 2,
                  prefixIcon: const Icon(Icons.location_on),
                ),
                const SizedBox(height: 24),

                // Professional Information
                SectionHeader(title: 'Professional Information'),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _departmentController,
                  labelText: 'Department',
                  hintText: 'Enter department (e.g., Mathematics, Science)',
                  prefixIcon: const Icon(Icons.business),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  readOnly: true,
                  labelText: 'Hire Date',
                  hintText: _hireDate == null
                      ? 'Select Date'
                      : DateFormat('MMM dd, yyyy').format(_hireDate!),
                  prefixIcon: const Icon(Icons.calendar_today),
                  onTap: () => _selectHireDate(context),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  onPressed: _saveTeacher,
                  child: const Text('Add Teacher'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
