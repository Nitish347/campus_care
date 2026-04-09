import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/services/upload_service.dart';
import 'package:campus_care/widgets/common/file_display_widget.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:image_picker/image_picker.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final AuthController _authController;
  final ImagePicker _imagePicker = ImagePicker();

  bool _isEditMode = false;
  bool _isSaving = false;
  bool _isUploadingProfileImage = false;
  String? _profileImageUrl;

  // Controllers for all editable fields
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _instituteNameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _websiteCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _pincodeCtrl;
  late final TextEditingController _addressCtrl;

  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
    _initControllers();
  }

  void _initControllers() {
    final admin = _authController.currentAdmin;
    _firstNameCtrl = TextEditingController(text: admin?.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: admin?.lastName ?? '');
    _instituteNameCtrl =
        TextEditingController(text: admin?.instituteName ?? '');
    _emailCtrl = TextEditingController(text: admin?.email ?? '');
    _phoneCtrl = TextEditingController(text: admin?.phone ?? '');
    _websiteCtrl = TextEditingController(text: admin?.website ?? '');
    _cityCtrl = TextEditingController(text: admin?.city ?? '');
    _stateCtrl = TextEditingController(text: admin?.state ?? '');
    _countryCtrl = TextEditingController(text: admin?.country ?? '');
    _pincodeCtrl = TextEditingController(text: admin?.pincode ?? '');
    _addressCtrl = TextEditingController(text: admin?.address ?? '');
    _profileImageUrl = admin?.profileImageUrl;
  }

  void _resetControllers() {
    final admin = _authController.currentAdmin;
    _firstNameCtrl.text = admin?.firstName ?? '';
    _lastNameCtrl.text = admin?.lastName ?? '';
    _instituteNameCtrl.text = admin?.instituteName ?? '';
    _emailCtrl.text = admin?.email ?? '';
    _phoneCtrl.text = admin?.phone ?? '';
    _websiteCtrl.text = admin?.website ?? '';
    _cityCtrl.text = admin?.city ?? '';
    _stateCtrl.text = admin?.state ?? '';
    _countryCtrl.text = admin?.country ?? '';
    _pincodeCtrl.text = admin?.pincode ?? '';
    _addressCtrl.text = admin?.address ?? '';
    _profileImageUrl = admin?.profileImageUrl;
  }

  Future<void> _pickAndUploadProfileImage() async {
    if (!_isEditMode || _isUploadingProfileImage) return;

    final admin = _authController.currentAdmin;
    if (admin == null) {
      Get.snackbar('Error', 'Admin profile not loaded');
      return;
    }

    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1400,
    );
    if (file == null) return;

    try {
      setState(() => _isUploadingProfileImage = true);
      final bytes = await file.readAsBytes();
      final uploadedUrl = await UploadService.uploadAdminProfileImage(
        adminId: admin.id,
        fileBytes: bytes,
        fileName: file.name,
      );

      if (uploadedUrl.isEmpty) {
        throw Exception('Upload succeeded but image URL was empty');
      }

      if (!mounted) return;
      setState(() {
        _profileImageUrl = uploadedUrl;
      });
      _authController.updateAdminProfileImage(uploadedUrl);
      Get.snackbar('Success', 'Profile image updated');
    } catch (e) {
      Get.snackbar(
        'Upload Failed',
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploadingProfileImage = false);
      }
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _instituteNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _websiteCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _countryCtrl.dispose();
    _pincodeCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final admin = _authController.currentAdmin!;
    final updated = admin.copyWith(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      instituteName: _instituteNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      profileImageUrl: _profileImageUrl,
      website: _websiteCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      country: _countryCtrl.text.trim(),
      pincode: _pincodeCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
    );

    await _authController.updateAdminProfile(updated);

    setState(() {
      _isSaving = false;
      _isEditMode = false;
    });
  }

  void _enterEditMode() => setState(() => _isEditMode = true);

  void _cancelEdit() {
    _resetControllers();
    setState(() => _isEditMode = false);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        body: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                stretch: true,
                actions: _isEditMode
                    ? [
                        if (_isSaving)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        else ...[
                          IconButton(
                            icon: const Icon(Icons.check_rounded,
                                color: Colors.white),
                            tooltip: 'Save',
                            onPressed: _saveProfile,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: Colors.white),
                            tooltip: 'Cancel',
                            onPressed: _cancelEdit,
                          ),
                        ],
                      ]
                    : [
                        IconButton(
                          icon: const Icon(Icons.edit_rounded,
                              color: Colors.white),
                          tooltip: 'Edit Profile',
                          onPressed: _enterEditMode,
                        ),
                      ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildProfileHeader(context, _authController),
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                  ],
                ),
              ),

              // Profile Content
              SliverToBoxAdapter(
                child: ResponsivePadding(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),

                      // Quick Stats
                      _buildQuickStatsRow(context),
                      const SizedBox(height: 24),

                      // Personal Information
                      _buildSectionCard(
                        context,
                        'Personal Information',
                        Icons.person_rounded,
                        Colors.blue,
                        [
                          _buildField(
                            context,
                            Icons.account_circle_rounded,
                            'First Name',
                            _authController.currentAdmin?.firstName ?? '',
                            _firstNameCtrl,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                          _buildField(
                            context,
                            Icons.account_circle_outlined,
                            'Last Name',
                            _authController.currentAdmin?.lastName ?? '',
                            _lastNameCtrl,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                          _buildField(
                            context,
                            Icons.school_rounded,
                            'Institute Name',
                            _authController.currentAdmin?.instituteName ?? '',
                            _instituteNameCtrl,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                          _buildField(
                            context,
                            Icons.email_rounded,
                            'Email',
                            _authController.currentAdmin?.email ?? '',
                            _emailCtrl,
                            readOnly: true, // email is not editable
                          ),
                          _buildField(
                            context,
                            Icons.format_underline_outlined,
                            'Website',
                            _authController.currentAdmin?.website ?? '',
                            _websiteCtrl,
                            keyboardType: TextInputType.url,
                          ),
                          _buildField(
                            context,
                            Icons.phone_rounded,
                            'Phone',
                            _authController.currentAdmin?.phone ?? '',
                            _phoneCtrl,
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Address Information
                      _buildSectionCard(
                        context,
                        'Address',
                        Icons.location_on,
                        Colors.purple,
                        [
                          _buildField(
                            context,
                            Icons.location_city_rounded,
                            'City',
                            _authController.currentAdmin?.city ?? '',
                            _cityCtrl,
                          ),
                          _buildField(
                            context,
                            Icons.map_rounded,
                            'State',
                            _authController.currentAdmin?.state ?? '',
                            _stateCtrl,
                          ),
                          _buildField(
                            context,
                            Icons.public_rounded,
                            'Country',
                            _authController.currentAdmin?.country ?? '',
                            _countryCtrl,
                          ),
                          _buildField(
                            context,
                            Icons.pin_drop_rounded,
                            'Pin Code',
                            _authController.currentAdmin?.pincode ?? '',
                            _pincodeCtrl,
                            keyboardType: TextInputType.number,
                          ),
                          _buildField(
                            context,
                            Icons.location_on_rounded,
                            'Address',
                            _authController.currentAdmin?.address ?? '',
                            _addressCtrl,
                            maxLines: 2,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Action Buttons
                      _buildActionButtons(context, _authController),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildProfileHeader(
      BuildContext context, AuthController authController) {
    final theme = Theme.of(context);
    final profileImageUrl =
        _profileImageUrl ?? authController.currentAdmin?.profileImageUrl;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
            ),
          ),
        ),

        // Glassmorphism Effect
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
            ),
          ),
        ),

        // Profile Content
        SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Profile Avatar
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3), width: 4),
                    ),
                    child: ProfileAvatarWidget(
                      size: 120,
                      imageUrl: profileImageUrl,
                      displayName:
                          authController.currentAdmin?.instituteName ?? 'Admin',
                      enablePreview: true,
                      backgroundColor: Colors.white,
                      textStyle: theme.textTheme.headlineSmall?.copyWith(
                        color: const Color(0xFF4F46E5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_isEditMode)
                    InkWell(
                      onTap: _isUploadingProfileImage
                          ? null
                          : _pickAndUploadProfileImage,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: _isUploadingProfileImage
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Name / Institute
              Text(
                _isEditMode
                    ? (_instituteNameCtrl.text.isNotEmpty
                        ? _instituteNameCtrl.text
                        : 'Institute Name')
                    : authController.currentAdmin?.instituteName ??
                        'Institute Name',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Edit mode badge or email badge
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _isEditMode
                    ? Container(
                        key: const ValueKey('edit-badge'),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.orange.withOpacity(0.5)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit_rounded,
                                color: Colors.orange, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Editing Profile',
                              style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        key: const ValueKey('email-badge'),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.email_rounded,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              authController.currentAdmin?.email ??
                                  'admin@example.com',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
              context, Icons.class_rounded, 'Classes', '5', Colors.blue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
              context, Icons.people_rounded, 'Students', '120', Colors.green),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(context, Icons.assignment_rounded, 'Homework',
              '8', Colors.orange),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, IconData icon, String label,
      String value, Color color) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color accentColor,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _isEditMode
                ? accentColor.withOpacity(0.12)
                : Colors.black.withOpacity(0.05),
            blurRadius: _isEditMode ? 30 : 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: _isEditMode
            ? Border.all(color: accentColor.withOpacity(0.3), width: 1.5)
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: accentColor, width: 4)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: accentColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_isEditMode) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Editing',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  /// Renders either an info row (view mode) or a TextFormField (edit mode).
  Widget _buildField(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    TextEditingController controller, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool readOnly = false,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);

    if (!_isEditMode) {
      // --- View mode ---
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value.isEmpty ? '—' : value,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // --- Edit mode ---
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        validator: validator,
        autofillHints: const [],
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon,
              size: 20,
              color: readOnly
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.primary),
          filled: true,
          fillColor: readOnly
              ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.4)
              : theme.colorScheme.primaryContainer.withOpacity(0.15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                BorderSide(color: theme.colorScheme.outline.withOpacity(0.4)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                BorderSide(color: theme.colorScheme.outline.withOpacity(0.4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                BorderSide(color: theme.colorScheme.primary, width: 1.8),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: theme.colorScheme.error),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintText: readOnly ? 'Cannot be changed' : 'Enter $label',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, AuthController authController) {
    if (_isEditMode) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _saveProfile,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Icon(Icons.check_rounded),
              label: Text(_isSaving ? 'Saving…' : 'Save Changes'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: _isSaving ? null : _cancelEdit,
              icon: const Icon(Icons.close_rounded),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            onPressed: _enterEditMode,
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Edit Profile'),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () => authController.logout(),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }
}
