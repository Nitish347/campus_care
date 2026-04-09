import 'dart:typed_data';

import 'package:campus_care/widgets/admin/admin_page_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:campus_care/models/teacher/teacher.dart';
import 'package:campus_care/controllers/teacher_controller.dart';
import 'package:campus_care/services/upload_service.dart';
import 'package:campus_care/utils/upload_url_utils.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:campus_care/widgets/buttons/primary_button.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:image_picker/image_picker.dart';

class AddTeacherScreen extends StatefulWidget {
  final Teacher? teacher;

  const AddTeacherScreen({super.key, this.teacher});

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
  final ImagePicker _imagePicker = ImagePicker();
  DateTime? _hireDate;
  Uint8List? _profileImageBytes;
  String? _profileImageFileName;
  String? _existingProfileImageUrl;
  bool _isUploadingProfileImage = false;
  bool _isSaving = false;

  bool get isEditMode => widget.teacher != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) _populateFields();
  }

  void _populateFields() {
    final t = widget.teacher!;
    _nameController.text = t.fullName;
    _emailController.text = t.email;
    _phoneController.text = t.phone ?? '';
    _addressController.text = t.address ?? '';
    _departmentController.text = t.department ?? '';
    _hireDate = t.hireDate;
    _existingProfileImageUrl = t.profileImageUrl;
  }

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

  Future<void> _selectHireDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _hireDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _hireDate = picked);
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

  Future<String?> _uploadProfileImageForTeacher(String teacherId) async {
    if (_profileImageBytes == null || _profileImageFileName == null) {
      return _existingProfileImageUrl;
    }

    try {
      setState(() => _isUploadingProfileImage = true);
      final uploadedUrl = await UploadService.uploadTeacherProfileImage(
        teacherId: teacherId,
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

  Future<void> _saveTeacher() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final nameParts = _nameController.text.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '-';

    try {
      String? profileImageUrl = _existingProfileImageUrl;

      if (isEditMode && _profileImageBytes != null) {
        profileImageUrl =
            await _uploadProfileImageForTeacher(widget.teacher!.id);
      }

      final teacher = Teacher(
        id: isEditMode ? widget.teacher!.id : '',
        firstName: firstName,
        lastName: lastName,
        email: _emailController.text,
        password: _passwordController.text.isNotEmpty
            ? _passwordController.text
            : null,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        address:
            _addressController.text.isNotEmpty ? _addressController.text : null,
        department: _departmentController.text.isNotEmpty
            ? _departmentController.text
            : null,
        profileImageUrl: profileImageUrl,
        hireDate: _hireDate,
        institute: isEditMode ? widget.teacher!.institute : '',
        createdAt: isEditMode ? widget.teacher!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isEditMode) {
        await _teacherController.updateTeacher(teacher);
        return;
      }

      final createdTeacherId = await _teacherController.addTeacher(
        teacher,
        popOnSuccess: false,
        showSnackbar: false,
      );

      if (createdTeacherId == null || createdTeacherId.isEmpty) {
        return;
      }

      if (_profileImageBytes != null) {
        final uploadedUrl =
            await _uploadProfileImageForTeacher(createdTeacherId);
        if ((uploadedUrl ?? '').isNotEmpty) {
          Teacher? createdTeacher;
          for (final item in _teacherController.teachers) {
            if (item.id == createdTeacherId) {
              createdTeacher = item;
              break;
            }
          }

          if (createdTeacher == null) {
            if (!mounted) return;
            Get.back();
            _showSnackBar(
              'Teacher added, but profile image could not be linked automatically.',
              isError: true,
            );
            return;
          }

          await _teacherController.updateTeacher(
            teacher.copyWith(
              id: createdTeacherId,
              institute: createdTeacher.institute,
              createdAt: createdTeacher.createdAt,
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
      _showSnackBar('Teacher added successfully');
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
            title: isEditMode ? 'Edit Teacher' : 'Add New Teacher',
            subtitle: isEditMode
                ? 'Update teacher information below'
                : 'Fill in the details to add a new teacher',
            icon: isEditMode ? Icons.edit_rounded : Icons.person_add_rounded,
            showBreadcrumb: true,
            breadcrumbLabel: isEditMode ? 'Edit Teacher' : 'Add Teacher',
            showBackButton: true,
            actions: [
              HeaderActionButton(
                icon: Icons.save_rounded,
                label: isEditMode ? 'Update' : 'Save',
                onPressed: _saveTeacher,
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

                        // Personal Information Card
                        _FormCard(
                          title: 'Personal Information',
                          icon: Icons.person_rounded,
                          accentColor: theme.colorScheme.primary,
                          children: [
                            CustomTextField(
                              controller: _nameController,
                              labelText: 'Full Name *',
                              hintText: 'Enter full name',
                              prefixIcon:
                                  const Icon(Icons.person_outline_rounded),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _emailController,
                              labelText: 'Email *',
                              hintText: 'teacher@school.com',
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

                        // Professional Information Card
                        _FormCard(
                          title: 'Professional Information',
                          icon: Icons.work_rounded,
                          accentColor: const Color(0xFF059669),
                          children: [
                            CustomTextField(
                              controller: _departmentController,
                              labelText: 'Department',
                              hintText: 'e.g. Mathematics, Science',
                              prefixIcon: const Icon(Icons.business_rounded),
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              readOnly: true,
                              labelText: 'Hire Date',
                              hintText: _hireDate == null
                                  ? 'Select hire date'
                                  : DateFormat('MMM dd, yyyy')
                                      .format(_hireDate!),
                              prefixIcon:
                                  const Icon(Icons.calendar_today_rounded),
                              onTap: () => _selectHireDate(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        PrimaryButton(
                          onPressed: _saveTeacher,
                          isLoading: _isSaving || _isUploadingProfileImage,
                          prefixIcon: isEditMode
                              ? Icons.save_rounded
                              : Icons.add_rounded,
                          child: Text(
                            isEditMode ? 'Update Teacher' : 'Add Teacher',
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

    final teacherName = _nameController.text.trim();
    final initial = teacherName.isNotEmpty ? teacherName[0].toUpperCase() : 'T';

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
                'Upload teacher profile picture',
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
        border:
            Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
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
                gradient: LinearGradient(colors: [
                  accentColor.withValues(alpha: 0.1),
                  accentColor.withValues(alpha: 0.04),
                ]),
                border: Border(
                    bottom:
                        BorderSide(color: accentColor.withValues(alpha: 0.12))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        accentColor,
                        accentColor.withValues(alpha: 0.7),
                      ]),
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
