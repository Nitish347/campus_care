import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/models/student/student.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:intl/intl.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authController = Get.find<AuthController>();

    // Assuming you have a way to get the full Student object
    // You might need to fetch it from a StudentController or API
    final Student? student = null; // Replace with actual student data

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // gradient: LinearGradient(
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          //   colors: [
          //     theme.colorScheme.primary.withOpacity(0.05),
          //     theme.colorScheme.surface,
          //   ],
          // ),
        ),
        child: CustomScrollView(
          slivers: [
            // Modern App Bar with Background Image
            SliverAppBar(
              expandedHeight: 320,
              pinned: true,
              stretch: true,
              // backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildProfileHeader(context, student),
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                  StretchMode.fadeTitle,
                ],
              ),

            ),

            // Profile Content
            SliverToBoxAdapter(
              child: ResponsivePadding(
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // Quick Stats Cards with Enhanced Design
                    _buildQuickStatsRow(context, student),
                    const SizedBox(height: 24),

                    // Personal Information
                    _buildModernSectionCard(
                      context,
                      'Personal Information',
                      Icons.person_rounded,
                      Colors.blue,
                      [
                        buildModernInfoRow(context, Icons.badge_rounded,
                            'Student ID', student?.studentId ?? 'STU-2024-001'),
                        buildModernInfoRow(
                            context,
                            Icons.cake_rounded,
                            'Date of Birth',
                            student != null
                                ? DateFormat('MMM dd, yyyy')
                                    .format(student.dateOfBirth)
                                : 'Jan 15, 2005'),
                        buildModernInfoRow(context, Icons.wc_rounded, 'Gender',
                            student?.gender ?? 'Male'),
                        buildModernInfoRow(context, Icons.bloodtype_rounded,
                            'Blood Group', student?.bloodGroup ?? 'O+'),
                        buildModernInfoRow(
                            context,
                            Icons.location_on_rounded,
                            'Address',
                            student?.address ?? '123 Main Street, City',
                            maxLines: 2),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Contact Information
                    _buildModernSectionCard(
                      context,
                      'Contact Information',
                      Icons.contact_phone_rounded,
                      Colors.green,
                      [
                        buildModernInfoRow(context, Icons.email_rounded,
                            'Email', student?.email ?? 'student@example.com'),
                        buildModernInfoRow(context, Icons.phone_rounded,
                            'Phone', student?.phone ?? '+1 234 567 8900'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Academic Information
                    _buildModernSectionCard(
                      context,
                      'Academic Information',
                      Icons.school_rounded,
                      Colors.purple,
                      [
                        buildModernInfoRow(context, Icons.class_rounded,
                            'Class', student?.classId ?? 'Grade 10'),
                        buildModernInfoRow(context, Icons.group_rounded,
                            'Section', student?.section ?? 'A'),
                        buildModernInfoRow(
                            context,
                            Icons.calendar_today_rounded,
                            'Admission Date',
                            student != null
                                ? DateFormat('MMM dd, yyyy')
                                    .format(student.admissionDate)
                                : 'Sep 01, 2023'),
                        buildEnhancedStatusChip(
                            context, student?.isActive ?? true),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Guardian Information
                    _buildModernSectionCard(
                      context,
                      'Guardian Information',
                      Icons.family_restroom_rounded,
                      Colors.orange,
                      [
                        buildModernInfoRow(
                            context,
                            Icons.person_outline_rounded,
                            'Name',
                            student?.guardianName ?? 'John Doe'),
                        buildModernInfoRow(
                            context,
                            Icons.phone_outlined,
                            'Phone',
                            student?.guardianPhone ?? '+1 234 567 8901'),
                        buildModernInfoRow(
                            context,
                            Icons.email_outlined,
                            'Email',
                            student?.guardianEmail ?? 'guardian@example.com'),
                        if (student?.guardianRelation != null || true)
                          buildModernInfoRow(
                              context,
                              Icons.connect_without_contact_rounded,
                              'Relation',
                              student?.guardianRelation ?? 'Father'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Medical Information
                    if (student?.medicalInfo != null || true)
                      _buildModernSectionCard(
                        context,
                        'Medical Information',
                        Icons.medical_information_rounded,
                        Colors.red,
                        [
                          buildModernInfoRow(
                              context,
                              Icons.info_outline_rounded,
                              'Details',
                              student?.medicalInfo ??
                                  'No known allergies. Regular checkups recommended.',
                              maxLines: 3),
                        ],
                      ),
                    const SizedBox(height: 16),

                    // Documents
                    if (student?.documents.isNotEmpty ?? false)
                      _buildModernDocumentsCard(context, student!.documents),
                    const SizedBox(height: 24),

                    // Action Buttons with Modern Design
                    _buildModernActionButtons(context, authController),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, Student? student) {
    final theme = Theme.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image with Gradient Overlay
        Container(
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/profile_header_bg.png'),
              fit: BoxFit.cover,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF4F46E5),
                const Color(0xFF7C3AED),
              ],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.6),
                ],
              ),
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

              // Profile Avatar with Enhanced Shadow
              Hero(
                tag: 'profile_avatar',
                child: Container(
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
                      color: Colors.white.withOpacity(0.3),
                      width: 4,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.white,
                    backgroundImage: student?.avatar != null
                        ? NetworkImage(student!.avatar!)
                        : null,
                    child: student?.avatar == null
                        ? Text(
                            student?.name.substring(0, 1).toUpperCase() ?? 'S',
                            style: theme.textTheme.displayLarge?.copyWith(
                              color: const Color(0xFF4F46E5),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Name with Shadow
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  student?.name ?? 'Student Name',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),

              // Email Badge with Glassmorphism
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.email_rounded,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      student?.email ?? 'student@example.com',
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

  Widget _buildQuickStatsRow(BuildContext context, Student? student) {
    return Row(
      children: [
        Expanded(
          child: _buildEnhancedStatCard(
            context,
            Icons.calendar_month_rounded,
            'Days Since\nAdmission',
            student != null
                ? DateTime.now()
                    .difference(student.admissionDate)
                    .inDays
                    .toString()
                : '450',
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildEnhancedStatCard(
            context,
            Icons.description_rounded,
            'Documents',
            (student?.documents.length ?? 5).toString(),
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildEnhancedStatCard(
            context,
            Icons.check_circle_rounded,
            'Status',
            student?.isActive ?? true ? 'Active' : 'Inactive',
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedStatCard(BuildContext context, IconData icon,
      String label, String value, Color accentColor) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withOpacity(0.1),
            accentColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: accentColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernSectionCard(
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
            border: Border(
              left: BorderSide(
                color: accentColor,
                width: 4,
              ),
            ),
          ),
          child: Padding(
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
                        color: theme.colorScheme.onSurface,
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
      ),
    );
  }

  Widget buildModernInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: theme.colorScheme.primary,
            ),
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
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEnhancedStatusChip(BuildContext context, bool isActive) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          const SizedBox(width: 48),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isActive
                    ? [Colors.green.shade400, Colors.green.shade600]
                    : [Colors.red.shade400, Colors.red.shade600],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color:
                      (isActive ? Colors.green : Colors.red).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  isActive ? 'Active' : 'Inactive',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDocumentsCard(
      BuildContext context, List<String> documents) {
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
            border: Border(
              left: BorderSide(
                color: Colors.amber.shade700,
                width: 4,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.folder_open_rounded,
                          color: Colors.amber.shade700, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Documents',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...documents
                    .map((doc) => _buildModernDocumentItem(context, doc)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernDocumentItem(BuildContext context, String documentUrl) {
    final theme = Theme.of(context);
    final fileName = documentUrl.split('/').last;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Open document
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primaryContainer.withOpacity(0.3),
                theme.colorScheme.secondaryContainer.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.insert_drive_file_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  fileName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.download_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernActionButtons(
      BuildContext context, AuthController authController) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Primary Action - Edit Profile
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () {
              // Edit profile
            },
            icon: const Icon(Icons.edit_rounded, color: Colors.white),
            label: const Text('Edit Profile',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Secondary Actions
        _buildModernOutlinedButton(
          context,
          Icons.lock_rounded,
          'Change Password',
          theme.colorScheme.primary,
          () {
            // Change password
          },
        ),
        const SizedBox(height: 12),
        _buildModernOutlinedButton(
          context,
          Icons.settings_rounded,
          'Settings',
          theme.colorScheme.primary,
          () {
            // Settings
          },
        ),
        const SizedBox(height: 24),

        // Logout Button
        _buildModernOutlinedButton(
          context,
          Icons.logout_rounded,
          'Logout',
          theme.colorScheme.error,
          () {
            _showModernLogoutDialog(context, authController);
          },
        ),
      ],
    );
  }

  Widget _buildModernOutlinedButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: color),
        label: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void _showModernLogoutDialog(
      BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.logout_rounded, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text('Logout'),
          ],
        ),
        content:
            const Text('Are you sure you want to logout from your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              authController.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
