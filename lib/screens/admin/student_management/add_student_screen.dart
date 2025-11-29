import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:campus_care/widgets/inputs/custom_dropdown.dart';
import 'package:campus_care/widgets/buttons/primary_button.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/common/section_header.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  final _guardianEmailController = TextEditingController();
  final _addressController = TextEditingController();
  
  String? _selectedClass;
  String? _selectedSection;
  String? _selectedGender;
  DateTime? _dateOfBirth;
  DateTime? _admissionDate;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    _guardianEmailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isBirthDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isBirthDate 
          ? (_dateOfBirth ?? DateTime(2010))
          : (_admissionDate ?? DateTime.now()),
      firstDate: isBirthDate 
          ? DateTime(2000)
          : DateTime.now().subtract(const Duration(days: 365)),
      lastDate: isBirthDate 
          ? DateTime.now()
          : DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isBirthDate) {
          _dateOfBirth = picked;
        } else {
          _admissionDate = picked;
        }
      });
    }
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClass == null || _selectedSection == null || _selectedGender == null || 
        _dateOfBirth == null || _admissionDate == null) {
      Get.snackbar('Error', 'Please fill all required fields');
      return;
    }

    Get.snackbar('Success', 'Student added successfully');
    Get.offNamed(AppRoutes.studentList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Student'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveStudent,
            tooltip: 'Save Student',
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
                Row(
                  children: [
                    Expanded(
                      child: CustomDropdown<String>(
                        value: _selectedGender,
                        labelText: 'Gender *',
                        prefixIcon: const Icon(Icons.wc),
                        items: ['Male', 'Female', 'Other']
                            .map((gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        readOnly: true,
                        labelText: 'Date of Birth *',
                        hintText: _dateOfBirth == null
                            ? 'Select Date'
                            : DateFormat('MMM dd, yyyy').format(_dateOfBirth!),
                        prefixIcon: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context, true),
                        validator: (value) {
                          if (_dateOfBirth == null) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
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

                // Academic Information
                SectionHeader(title: 'Academic Information'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomDropdown<String>(
                        value: _selectedClass,
                        labelText: 'Class *',
                        items: ['class_001', 'class_002', 'class_003']
                            .map((cls) => DropdownMenuItem(
                                  value: cls,
                                  child: Text(cls.replaceAll('_', ' ').toUpperCase()),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedClass = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomDropdown<String>(
                        value: _selectedSection,
                        labelText: 'Section *',
                        items: ['A', 'B', 'C']
                            .map((sec) => DropdownMenuItem(
                                  value: sec,
                                  child: Text(sec),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSection = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  readOnly: true,
                  labelText: 'Admission Date *',
                  hintText: _admissionDate == null
                      ? 'Select Date'
                      : DateFormat('MMM dd, yyyy').format(_admissionDate!),
                  prefixIcon: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, false),
                  validator: (value) {
                    if (_admissionDate == null) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Guardian Information
                SectionHeader(title: 'Guardian Information'),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _guardianNameController,
                  labelText: 'Guardian Name',
                  hintText: 'Enter guardian name',
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _guardianPhoneController,
                  labelText: 'Guardian Phone',
                  hintText: 'Enter guardian phone',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _guardianEmailController,
                  labelText: 'Guardian Email',
                  hintText: 'Enter guardian email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  onPressed: _saveStudent,
                  child: const Text('Add Student'),
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
