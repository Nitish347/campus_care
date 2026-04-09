import 'dart:ui';
import 'package:campus_care/models/teacher/teacher.dart';
import 'package:campus_care/services/upload_service.dart';
import 'package:campus_care/utils/upload_url_utils.dart';
import 'package:campus_care/widgets/common/file_display_widget.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:campus_care/controllers/auth_controller.dart';

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({super.key});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploadingImage = false;

  Future<void> _pickAndUploadImage() async {
    final teacher = _authController.currentTeacher;
    if (teacher == null) {
      Get.snackbar('Error', 'Teacher profile not loaded');
      return;
    }

    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1400,
    );

    if (file == null) return;

    try {
      setState(() => _isUploadingImage = true);
      final bytes = await file.readAsBytes();
      final imageUrl = await UploadService.uploadTeacherProfileImage(
        teacherId: teacher.id,
        fileBytes: bytes,
        fileName: file.name,
      );

      if (imageUrl.isEmpty) {
        throw Exception('Upload succeeded but image URL was empty');
      }

      _authController.updateTeacherProfileImage(imageUrl);
      Get.snackbar('Success', 'Profile photo updated');
    } catch (e) {
      Get.snackbar(
          'Upload Failed', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final teacher = _authController.currentTeacher;
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              stretch: true,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildProfileHeader(context, teacher),
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: ResponsivePadding(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildSectionCard(
                      context,
                      'Personal Information',
                      Icons.person_rounded,
                      Colors.blue,
                      [
                        _buildInfoRow(context, Icons.badge_rounded,
                            'Teacher ID', teacher?.id ?? 'N/A'),
                        _buildInfoRow(context, Icons.email_rounded, 'Email',
                            teacher?.email ?? 'N/A'),
                        _buildInfoRow(
                            context,
                            Icons.phone_rounded,
                            'Phone',
                            teacher?.phone?.trim().isNotEmpty == true
                                ? teacher!.phone!
                                : 'N/A'),
                        _buildInfoRow(
                          context,
                          Icons.location_on_rounded,
                          'Address',
                          teacher?.address?.trim().isNotEmpty == true
                              ? teacher!.address!
                              : 'N/A',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      context,
                      'Professional Information',
                      Icons.work_rounded,
                      Colors.purple,
                      [
                        _buildInfoRow(
                          context,
                          Icons.school_rounded,
                          'Department',
                          teacher?.department?.trim().isNotEmpty == true
                              ? teacher!.department!
                              : 'N/A',
                        ),
                        _buildInfoRow(
                          context,
                          Icons.calendar_today_rounded,
                          'Hire Date',
                          teacher?.hireDate != null
                              ? '${teacher!.hireDate!.day.toString().padLeft(2, '0')}-${teacher.hireDate!.month.toString().padLeft(2, '0')}-${teacher.hireDate!.year}'
                              : 'N/A',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildActionButtons(context),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildProfileHeader(BuildContext context, Teacher? teacher) {
    final theme = Theme.of(context);
    final fullName = teacher?.fullName.trim().isNotEmpty == true
        ? teacher!.fullName
        : 'Teacher';
    final imageUrls =
        UploadUrlUtils.buildCandidateUrls(teacher?.profileImageUrl);

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
            ),
          ),
        ),
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
        SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 34),
              Stack(
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
                    child: CircleAvatar(
                      radius: 64,
                      backgroundColor: Colors.transparent,
                      child: ProfileAvatarWidget(
                        size: 128,
                        imageUrls: imageUrls,
                        displayName: fullName,
                        enablePreview: true,
                        backgroundColor: Colors.white,
                        textStyle: theme.textTheme.displayLarge?.copyWith(
                          color: const Color(0xFF4F46E5),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: InkWell(
                      onTap: _isUploadingImage ? null : _pickAndUploadImage,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: const Color(0xFF4F46E5), width: 2),
                        ),
                        child: _isUploadingImage
                            ? const Padding(
                                padding: EdgeInsets.all(8),
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.camera_alt_rounded,
                                size: 18, color: Color(0xFF4F46E5)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  fullName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.email_rounded,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      teacher?.email ?? 'N/A',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
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

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);

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
                  value,
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

  Widget _buildActionButtons(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () => _authController.logout(),
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: OutlinedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
