import 'package:campus_care/widgets/admin/admin_page_header.dart';
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
    if (isEditMode) _populateFields();
  }

  void _populateFields() {
    final s = widget.student!;
    _nameController.text = s.fullName;
    _enrollmentController.text = s.enrollmentNumber;
    _rollNumberController.text = s.rollNumber;
    _emailController.text = s.email;
    _phoneController.text = s.phone ?? '';
    _addressController.text = s.address ?? '';
    _guardianNameController.text = s.guardian?.name ?? '';
    _guardianPhoneController.text = s.guardian?.phone ?? '';
    _guardianEmailController.text = s.guardian?.email ?? '';
    _selectedClass = s.class_;
    _selectedSection = s.section;
    _selectedGender = s.gender;
    _dateOfBirth = s.dateOfBirth;
    _admissionDate = s.admissionDate;
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
      Get.snackbar('Error', 'Please fill all required fields',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

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
      relation: 'Guardian',
    );

    final student = Student(
      id: isEditMode ? widget.student!.id : '',
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
      institute: isEditMode ? widget.student!.institute : '',
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Column(
        children: [
          // Gradient header
          AdminPageHeader(
            title: isEditMode ? 'Edit Student' : 'Add New Student',
            subtitle: isEditMode
                ? 'Update student information below'
                : 'Fill in the details to add a new student',
            icon:
                isEditMode ? Icons.edit_rounded : Icons.person_add_rounded,
            showBreadcrumb: true,
            breadcrumbLabel: isEditMode ? 'Edit Student' : 'Add Student',
            actions: [
              HeaderActionButton(
                icon: Icons.save_rounded,
                label: isEditMode ? 'Update' : 'Save',
                onPressed: _saveStudent,
              ),
            ],
          ),

          // Scrollable form
          Expanded(
            child: SingleChildScrollView(
              child: ResponsivePadding(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Personal Information ──────────────────────────────
                        _FormCard(
                          title: 'Personal Information',
                          icon: Icons.person_rounded,
                          accentColor: theme.colorScheme.primary,
                          children: [
                            CustomTextField(
                              controller: _nameController,
                              labelText: 'Full Name *',
                              hintText: 'Enter student full name',
                              prefixIcon: const Icon(Icons.person_outline_rounded),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    controller: _enrollmentController,
                                    labelText: 'Enrollment No. *',
                                    hintText: 'e.g. 2024001',
                                    prefixIcon: const Icon(
                                        Icons.confirmation_number_outlined),
                                    validator: (v) =>
                                        v == null || v.isEmpty ? 'Required' : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CustomTextField(
                                    controller: _rollNumberController,
                                    labelText: 'Roll Number *',
                                    hintText: 'e.g. 01',
                                    prefixIcon: const Icon(Icons.tag_rounded),
                                    validator: (v) =>
                                        v == null || v.isEmpty ? 'Required' : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomDropdown<String>(
                                    value: _selectedGender,
                                    labelText: 'Gender *',
                                    prefixIcon: const Icon(Icons.wc_rounded),
                                    items: ['Male', 'Female', 'Other']
                                        .map((g) => DropdownMenuItem(
                                              value: g,
                                              child: Text(g),
                                            ))
                                        .toList(),
                                    onChanged: (v) =>
                                        setState(() => _selectedGender = v),
                                    validator: (v) =>
                                        v == null ? 'Required' : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CustomTextField(
                                    readOnly: true,
                                    labelText: 'Date of Birth *',
                                    hintText: _dateOfBirth == null
                                        ? 'Select date'
                                        : DateFormat('MMM dd, yyyy')
                                            .format(_dateOfBirth!),
                                    prefixIcon:
                                        const Icon(Icons.calendar_today_rounded),
                                    onTap: () => _selectDate(context, true),
                                    validator: (_) =>
                                        _dateOfBirth == null ? 'Required' : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _phoneController,
                              labelText: 'Phone',
                              hintText: 'Enter phone number',
                              keyboardType: TextInputType.phone,
                              prefixIcon: const Icon(Icons.phone_outlined),
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _addressController,
                              labelText: 'Address',
                              hintText: 'Enter address',
                              maxLines: 2,
                              prefixIcon: const Icon(Icons.location_on_outlined),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ── Account Information ───────────────────────────────
                        _FormCard(
                          title: 'Account Information',
                          icon: Icons.lock_rounded,
                          accentColor: const Color(0xFF7C3AED),
                          children: [
                            CustomTextField(
                              controller: _emailController,
                              labelText: 'Email *',
                              hintText: 'student@school.com',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: const Icon(Icons.email_outlined),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Required';
                                if (!v.contains('@')) return 'Invalid email';
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
                                  : 'Min. 6 characters',
                              obscureText: true,
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              validator: (v) {
                                if (!isEditMode &&
                                    (v == null || v.isEmpty)) {
                                  return 'Required';
                                }
                                if (v != null &&
                                    v.isNotEmpty &&
                                    v.length < 6) {
                                  return 'Min. 6 characters';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ── Academic Information ──────────────────────────────
                        _FormCard(
                          title: 'Academic Information',
                          icon: Icons.school_rounded,
                          accentColor: const Color(0xFF059669),
                          children: [
                            ClassSectionDropDown(
                              padding: 0,
                              onChangedClass: (v) => _selectedClass = v,
                              onChangedSection: (v) => _selectedSection = v,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              readOnly: true,
                              labelText: 'Admission Date *',
                              hintText: _admissionDate == null
                                  ? 'Select date'
                                  : DateFormat('MMM dd, yyyy')
                                      .format(_admissionDate!),
                              prefixIcon:
                                  const Icon(Icons.calendar_today_rounded),
                              onTap: () => _selectDate(context, false),
                              validator: (_) =>
                                  _admissionDate == null ? 'Required' : null,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ── Guardian Information ──────────────────────────────
                        _FormCard(
                          title: 'Guardian Information',
                          icon: Icons.family_restroom_rounded,
                          accentColor: const Color(0xFFF59E0B),
                          children: [
                            CustomTextField(
                              controller: _guardianNameController,
                              labelText: 'Guardian Name',
                              hintText: 'Enter guardian full name',
                              prefixIcon:
                                  const Icon(Icons.person_outline_rounded),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    controller: _guardianPhoneController,
                                    labelText: 'Guardian Phone',
                                    hintText: 'Phone number',
                                    keyboardType: TextInputType.phone,
                                    prefixIcon: const Icon(Icons.phone_outlined),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CustomTextField(
                                    controller: _guardianEmailController,
                                    labelText: 'Guardian Email',
                                    hintText: 'Email address',
                                    keyboardType: TextInputType.emailAddress,
                                    prefixIcon: const Icon(Icons.email_outlined),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // Save Button
                        PrimaryButton(
                          onPressed: _saveStudent,
                          prefixIcon:
                              isEditMode ? Icons.save_rounded : Icons.add_rounded,
                          child: Text(
                            isEditMode ? 'Update Student' : 'Add Student',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card-based form section wrapper with accent color
class _FormCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final List<Widget> children;

  const _FormCard({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Accent header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentColor.withValues(alpha: 0.1),
                    accentColor.withValues(alpha: 0.04),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: accentColor.withValues(alpha: 0.12),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accentColor, accentColor.withValues(alpha: 0.7)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
