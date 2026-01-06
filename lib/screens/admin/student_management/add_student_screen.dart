import 'package:campus_care/widgets/inputs/class_section_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/models/student/student.dart';
import 'package:campus_care/controllers/student_controller.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:campus_care/widgets/inputs/custom_dropdown.dart';
import 'package:campus_care/widgets/buttons/primary_button.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/common/section_header.dart';

class AddStudentScreen extends StatefulWidget {
  final Student? student;

  const AddStudentScreen({super.key, this.student});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _enrollmentController = TextEditingController();
  final _rollNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  final _guardianEmailController = TextEditingController();
  final _addressController = TextEditingController();

  final StudentController _studentController = Get.find<StudentController>();

  String? _selectedClass;
  String? _selectedSection;
  String? _selectedGender;
  DateTime? _dateOfBirth;
  DateTime? _admissionDate;

  bool get isEditMode => widget.student != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _populateFields();
    }
  }

  void _populateFields() {
    final student = widget.student!;
    _nameController.text = student.fullName;
    _enrollmentController.text = student.enrollmentNumber;
    _rollNumberController.text = student.rollNumber;
    _emailController.text = student.email;
    _phoneController.text = student.phone ?? '';
    _addressController.text = student.address ?? '';
    _guardianNameController.text = student.guardian?.name ?? '';
    _guardianPhoneController.text = student.guardian?.phone ?? '';
    _guardianEmailController.text = student.guardian?.email ?? '';
    _selectedClass = student.class_;
    _selectedSection = student.section;
    _selectedGender = student.gender;
    _dateOfBirth = student.dateOfBirth;
    _admissionDate = student.admissionDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _enrollmentController.dispose();
    _rollNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
      lastDate: isBirthDate ? DateTime.now() : DateTime.now(),
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
    if (_selectedClass == null ||
        _selectedSection == null ||
        _selectedGender == null ||
        _dateOfBirth == null ||
        _admissionDate == null) {
      Get.snackbar('Error', 'Please fill all required fields');
      return;
    }

    // Split name
    final nameParts = _nameController.text.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '-';

    final guardian = Guardian(
      name: _guardianNameController.text,
      phone: _guardianPhoneController.text,
      email: _guardianEmailController.text.isNotEmpty
          ? _guardianEmailController.text
          : null,
      relation: 'Guardian', // Default or add field
    );

    final student = Student(
      id: isEditMode ? widget.student!.id : '', // Use existing ID in edit mode
      firstName: firstName,
      lastName: lastName,
      enrollmentNumber: _enrollmentController.text,
      rollNumber: _rollNumberController.text,
      email: _emailController.text,
      password:
          _passwordController.text.isNotEmpty ? _passwordController.text : null,
      phone: _phoneController.text,
      class_: _selectedClass,
      section: _selectedSection,
      gender: _selectedGender,
      address: _addressController.text,
      dateOfBirth: _dateOfBirth,
      admissionDate: _admissionDate,
      institute:
          isEditMode ? widget.student!.institute : '', // Preserve institute
      createdAt: isEditMode ? widget.student!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
      guardian: guardian,
    );

    if (isEditMode) {
      await _studentController.updateStudent(student);
    } else {
      await _studentController.addStudent(student);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Student' : 'Add Student'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveStudent,
            tooltip: isEditMode ? 'Update Student' : 'Save Student',
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
                  controller: _enrollmentController,
                  labelText: 'Enrollment Number *',
                  hintText: 'Enter enrollment number',
                  prefixIcon: const Icon(Icons.confirmation_number),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter enrollment number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _rollNumberController,
                  labelText: 'Roll Number *',
                  hintText: 'Enter roll number',
                  prefixIcon: const Icon(Icons.confirmation_number),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter roll number';
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
                  controller: _passwordController,
                  labelText: isEditMode
                      ? 'Password (leave blank to keep current)'
                      : 'Password *',
                  hintText: isEditMode
                      ? 'Enter new password to change'
                      : 'Enter password',
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock),
                  validator: (value) {
                    if (!isEditMode && (value == null || value.isEmpty)) {
                      return 'Please enter password';
                    }
                    if (value != null && value.isNotEmpty && value.length < 6) {
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

                // Academic Information
                SectionHeader(title: 'Academic Information'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: ClassSectionDropDown(
                            padding: 0,
                            onChangedClass: (val) {
                              _selectedClass = val;
                            },
                            onChangedSection: (val) {
                              _selectedSection = val;
                            }))
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
                  child: Text(isEditMode ? 'Update Student' : 'Add Student'),
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
