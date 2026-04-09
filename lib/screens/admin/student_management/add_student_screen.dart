import 'dart:typed_data';

import 'package:campus_care/widgets/admin/admin_page_header.dart';
import 'package:campus_care/widgets/inputs/class_section_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/models/student/student.dart';
import 'package:campus_care/models/transport/transport_route.dart';
import 'package:campus_care/controllers/student_controller.dart';
import 'package:campus_care/services/transport_service.dart';
import 'package:campus_care/services/upload_service.dart';
import 'package:campus_care/utils/upload_url_utils.dart';
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
  static const String _noRouteValue = '__no_route__';

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
  final ImagePicker _imagePicker = ImagePicker();

  List<TransportRoute> _transportRoutes = <TransportRoute>[];
  bool _isLoadingRoutes = false;
  bool _isSaving = false;
  bool _isUploadingProfileImage = false;

  Uint8List? _profileImageBytes;
  String? _profileImageFileName;
  String? _existingProfileImageUrl;

  String? _selectedClass;
  String? _selectedSection;
  String? _selectedGender;
  String? _selectedRouteId;
  DateTime? _dateOfBirth;
  DateTime? _admissionDate;

  bool get isEditMode => widget.student != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _populateFields();
    }
    _loadTransportRoutes();
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
    _selectedRouteId = s.routeId;
    _dateOfBirth = s.dateOfBirth;
    _admissionDate = s.admissionDate;
    _existingProfileImageUrl = s.profileImageUrl;
  }

  Future<void> _loadTransportRoutes() async {
    setState(() => _isLoadingRoutes = true);
    try {
      final routes = await TransportService.getRoutes();
      if (!mounted) return;
      setState(() => _transportRoutes = routes);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Failed to load transport routes', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoadingRoutes = false);
      }
    }
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

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  Future<void> _pickProfileImage() async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1400,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    if (!mounted) return;

    setState(() {
      _profileImageBytes = bytes;
      _profileImageFileName = file.name;
    });
  }

  Future<String?> _uploadProfileImageForStudent(String studentId) async {
    if (_profileImageBytes == null || _profileImageFileName == null) {
      return _existingProfileImageUrl;
    }

    try {
      setState(() => _isUploadingProfileImage = true);
      final uploadedUrl = await UploadService.uploadStudentProfileImage(
        studentId: studentId,
        fileBytes: _profileImageBytes!,
        fileName: _profileImageFileName!,
      );

      if (!mounted) return uploadedUrl;
      setState(() {
        if (uploadedUrl.isNotEmpty) {
          _existingProfileImageUrl = uploadedUrl;
        }
      });

      return uploadedUrl.isEmpty ? _existingProfileImageUrl : uploadedUrl;
    } catch (e) {
      _showSnackBar(
        'Upload failed: ${e.toString().replaceFirst('Exception: ', '')}',
        isError: true,
      );
      return _existingProfileImageUrl;
    } finally {
      if (mounted) {
        setState(() => _isUploadingProfileImage = false);
      }
    }
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
      lastDate: DateTime.now(),
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
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    if (_selectedClass == null ||
        _selectedSection == null ||
        _selectedGender == null ||
        _dateOfBirth == null ||
        _admissionDate == null) {
      _showSnackBar('Please fill all required fields', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
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

      String? profileImageUrl = _existingProfileImageUrl;
      if (isEditMode && _profileImageBytes != null) {
        profileImageUrl =
            await _uploadProfileImageForStudent(widget.student!.id);
      }

      final student = Student(
        id: isEditMode ? widget.student!.id : '',
        firstName: firstName,
        lastName: lastName,
        enrollmentNumber: _enrollmentController.text,
        rollNumber: _rollNumberController.text,
        email: _emailController.text,
        password: _passwordController.text.isNotEmpty
            ? _passwordController.text
            : null,
        phone: _phoneController.text,
        class_: _selectedClass,
        section: _selectedSection,
        gender: _selectedGender,
        address: _addressController.text,
        dateOfBirth: _dateOfBirth,
        admissionDate: _admissionDate,
        institute: isEditMode ? widget.student!.institute : '',
        routeId: _selectedRouteId,
        profileImageUrl: profileImageUrl,
        createdAt: isEditMode ? widget.student!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
        guardian: guardian,
      );

      if (isEditMode) {
        await _studentController.updateStudent(student);
        return;
      }

      final createdStudentId = await _studentController.addStudent(
        student,
        popOnSuccess: false,
        showSnackbar: false,
      );

      if (createdStudentId == null || createdStudentId.isEmpty) {
        return;
      }

      if (_profileImageBytes != null) {
        final uploadedUrl =
            await _uploadProfileImageForStudent(createdStudentId);
        if ((uploadedUrl ?? '').isNotEmpty) {
          Student? createdStudent;
          for (final item in _studentController.students) {
            if (item.id == createdStudentId) {
              createdStudent = item;
              break;
            }
          }

          if (createdStudent == null) {
            if (!mounted) return;
            Get.back();
            _showSnackBar(
              'Student added, but profile image could not be linked automatically.',
              isError: true,
            );
            return;
          }

          await _studentController.updateStudent(
            student.copyWith(
              id: createdStudentId,
              institute: createdStudent.institute,
              createdAt: createdStudent.createdAt,
              profileImageUrl: uploadedUrl,
              updatedAt: DateTime.now(),
            ),
            popOnSuccess: false,
            showSnackbar: false,
          );
        }
      }

      if (!mounted) return;
      Get.back();
      _showSnackBar('Student added successfully');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Column(
        children: [
          AdminPageHeader(
            title: isEditMode ? 'Edit Student' : 'Add New Student',
            subtitle: isEditMode
                ? 'Update student information below'
                : 'Fill in the details to add a new student',
            icon: isEditMode ? Icons.edit_rounded : Icons.person_add_rounded,
            showBreadcrumb: true,
            breadcrumbLabel: isEditMode ? 'Edit Student' : 'Add Student',
            showBackButton: true,
            actions: [
              HeaderActionButton(
                icon: Icons.save_rounded,
                label: isEditMode ? 'Update' : 'Save',
                onPressed: _saveStudent,
              ),
            ],
          ),
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
                        _FormCard(
                          title: 'Profile Photo',
                          icon: Icons.image_rounded,
                          accentColor: const Color(0xFF0EA5E9),
                          children: [
                            _buildProfileImageEditor(theme),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _FormCard(
                          title: 'Personal Information',
                          icon: Icons.person_rounded,
                          accentColor: theme.colorScheme.primary,
                          children: [
                            CustomTextField(
                              controller: _nameController,
                              labelText: 'Full Name *',
                              hintText: 'Enter student full name',
                              prefixIcon:
                                  const Icon(Icons.person_outline_rounded),
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
                                    validator: (v) => v == null || v.isEmpty
                                        ? 'Required'
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CustomTextField(
                                    controller: _rollNumberController,
                                    labelText: 'Roll Number *',
                                    hintText: 'e.g. 01',
                                    prefixIcon: const Icon(Icons.tag_rounded),
                                    validator: (v) => v == null || v.isEmpty
                                        ? 'Required'
                                        : null,
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
                                    prefixIcon: const Icon(
                                        Icons.calendar_today_rounded),
                                    onTap: () => _selectDate(context, true),
                                    validator: (_) => _dateOfBirth == null
                                        ? 'Required'
                                        : null,
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
                              prefixIcon:
                                  const Icon(Icons.location_on_outlined),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
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
                              prefixIcon:
                                  const Icon(Icons.lock_outline_rounded),
                              validator: (v) {
                                if (!isEditMode && (v == null || v.isEmpty)) {
                                  return 'Required';
                                }
                                if (v != null && v.isNotEmpty && v.length < 6) {
                                  return 'Min. 6 characters';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
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
                            CustomDropdown<String>(
                              value: _selectedRouteId ?? _noRouteValue,
                              labelText: 'Transport Route',
                              hintText: _isLoadingRoutes
                                  ? 'Loading routes...'
                                  : 'Select transport route (optional)',
                              prefixIcon: const Icon(Icons.alt_route_rounded),
                              enabled: !_isLoadingRoutes,
                              onChanged: (value) {
                                setState(() {
                                  _selectedRouteId =
                                      value == _noRouteValue ? null : value;
                                });
                              },
                              items: [
                                const DropdownMenuItem<String>(
                                  value: _noRouteValue,
                                  child: Text('No Route'),
                                ),
                                ..._transportRoutes.map(
                                  (route) => DropdownMenuItem<String>(
                                    value: route.id,
                                    child: Text(
                                      '${route.routeNumber} - ${route.routeName}',
                                    ),
                                  ),
                                ),
                              ],
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
                                    prefixIcon:
                                        const Icon(Icons.phone_outlined),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CustomTextField(
                                    controller: _guardianEmailController,
                                    labelText: 'Guardian Email',
                                    hintText: 'Email address',
                                    keyboardType: TextInputType.emailAddress,
                                    prefixIcon:
                                        const Icon(Icons.email_outlined),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        PrimaryButton(
                          onPressed: _saveStudent,
                          isLoading: _isSaving || _isUploadingProfileImage,
                          prefixIcon: isEditMode
                              ? Icons.save_rounded
                              : Icons.add_rounded,
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

  Widget _buildProfileImageEditor(ThemeData theme) {
    final normalizedExistingProfileImageUrl =
        UploadUrlUtils.normalizeToApiBase(_existingProfileImageUrl);

    final ImageProvider<Object>? imageProvider = _profileImageBytes != null
        ? MemoryImage(_profileImageBytes!)
        : (normalizedExistingProfileImageUrl != null
            ? NetworkImage(normalizedExistingProfileImageUrl)
            : null);

    final studentName = _nameController.text.trim();
    final initial = studentName.isNotEmpty ? studentName[0].toUpperCase() : 'S';

    return Row(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundImage: imageProvider,
          child: imageProvider == null
              ? Text(
                  initial,
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload student profile picture',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Optional. JPG/PNG image from gallery.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: (_isSaving || _isUploadingProfileImage)
                        ? null
                        : _pickProfileImage,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Choose Photo'),
                  ),
                  if (_profileImageBytes != null ||
                      (_existingProfileImageUrl ?? '').isNotEmpty)
                    TextButton.icon(
                      onPressed: (_isSaving || _isUploadingProfileImage)
                          ? null
                          : () {
                              setState(() {
                                _profileImageBytes = null;
                                _profileImageFileName = null;
                                if (!isEditMode) {
                                  _existingProfileImageUrl = null;
                                }
                              });
                            },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Remove'),
                    ),
                ],
              ),
              if (_isUploadingProfileImage)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: LinearProgressIndicator(minHeight: 3),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

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
                        colors: [
                          accentColor,
                          accentColor.withValues(alpha: 0.7),
                        ],
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
