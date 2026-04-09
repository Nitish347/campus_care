import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/controllers/super_admin_controller.dart';
import 'package:campus_care/models/admin/admin.dart';
import 'package:campus_care/screens/super_admin/school_details_screen.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  late final SuperAdminController _controller;
  late final AuthController _authController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = Get.put(SuperAdminController());
    _authController = Get.find<AuthController>();
    _searchController.addListener(() {
      _controller.searchSchools(_searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Panel'),
        actions: [
          IconButton(
            onPressed: _controller.refreshDashboardData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: _openAddSchoolDialog,
            icon: const Icon(Icons.add_business),
            tooltip: 'Add School',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'logout') {
                _authController.logout();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: theme.colorScheme.error),
                    const SizedBox(width: 8),
                    const Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSchoolDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add School'),
      ),
      body: Obx(() => _buildBody(context, theme)),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme) {
    final stats = _controller.dashboardStats;
    final schools = _controller.filteredSchools;
    final isLoading = _controller.isLoading;

    return RefreshIndicator(
      onRefresh: _controller.refreshDashboardData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        children: [
          Text(
            'Manage schools from one place',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Create schools, update school admins, and open school data quickly.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _QuickStatsCard(
            schools: '${stats['schools'] ?? 0}',
            students: '${stats['students'] ?? 0}',
            teachers: '${stats['teachers'] ?? 0}',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by school name, email, or city',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        _controller.searchSchools('');
                        setState(() {});
                      },
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          if (isLoading && schools.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (schools.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 52,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No schools found',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first school to start managing data.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: _openAddSchoolDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Add School'),
                    ),
                  ],
                ),
              ),
            )
          else
            ...schools.map((school) => _buildSchoolCard(context, school)),
        ],
      ),
    );
  }

  Widget _buildSchoolCard(BuildContext context, Admin school) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  child: Text(
                    school.instituteName.isEmpty
                        ? 'S'
                        : school.instituteName.substring(0, 1).toUpperCase(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        school.instituteName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${school.firstName} ${school.lastName}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        school.email,
                        style: theme.textTheme.bodySmall,
                      ),
                      if ((school.city ?? '').isNotEmpty ||
                          (school.state ?? '').isNotEmpty)
                        Text(
                          [school.city, school.state]
                              .where((item) => item != null && item.isNotEmpty)
                              .join(', '),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: school.isActive
                        ? Colors.green.withValues(alpha: 0.13)
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    school.isActive ? 'Active' : 'Inactive',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: school.isActive
                          ? Colors.green.shade700
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      _controller.selectSchool(school);
                      Get.to(() => SchoolDetailsScreen(school: school));
                    },
                    icon: const Icon(Icons.manage_search, size: 18),
                    label: const Text('Manage Data'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  onPressed: () => _openEditSchoolDialog(school),
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                ),
                IconButton.outlined(
                  onPressed: () => _confirmDeleteSchool(school),
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAddSchoolDialog() async {
    await showDialog<void>(
      context: context,
      builder: (_) => _SchoolFormDialog(
        onSubmit: (payload) => _controller.createSchool(payload),
      ),
    );
  }

  Future<void> _openEditSchoolDialog(Admin school) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _SchoolFormDialog(
        school: school,
        onSubmit: (payload) => _controller.updateSchool(school.id, payload),
      ),
    );
  }

  Future<void> _confirmDeleteSchool(Admin school) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete School'),
        content: Text(
          'Delete ${school.instituteName}? This will remove school-level data that depends on this account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _controller.deleteSchool(school.id);
    }
  }
}

class _QuickStatsCard extends StatelessWidget {
  final String schools;
  final String students;
  final String teachers;

  const _QuickStatsCard({
    required this.schools,
    required this.students,
    required this.teachers,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.42),
            theme.colorScheme.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Quick Stats',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 420;
              final items = [
                _QuickStatItem(
                  icon: Icons.school_outlined,
                  label: 'Schools',
                  value: schools,
                ),
                _QuickStatItem(
                  icon: Icons.people_alt_outlined,
                  label: 'Students',
                  value: students,
                ),
                _QuickStatItem(
                  icon: Icons.person_outline,
                  label: 'Teachers',
                  value: teachers,
                ),
              ];

              if (isCompact) {
                return Column(
                  children: [
                    items[0],
                    const SizedBox(height: 10),
                    Divider(
                      height: 1,
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.55),
                    ),
                    const SizedBox(height: 10),
                    items[1],
                    const SizedBox(height: 10),
                    Divider(
                      height: 1,
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.55),
                    ),
                    const SizedBox(height: 10),
                    items[2],
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: items[0]),
                  VerticalDivider(
                    width: 18,
                    thickness: 1,
                    color: theme.colorScheme.outlineVariant
                        .withValues(alpha: 0.55),
                  ),
                  Expanded(child: items[1]),
                  VerticalDivider(
                    width: 18,
                    thickness: 1,
                    color: theme.colorScheme.outlineVariant
                        .withValues(alpha: 0.55),
                  ),
                  Expanded(child: items[2]),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _QuickStatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SchoolFormDialog extends StatefulWidget {
  final Admin? school;
  final Future<bool> Function(Map<String, dynamic> payload) onSubmit;

  const _SchoolFormDialog({
    this.school,
    required this.onSubmit,
  });

  @override
  State<_SchoolFormDialog> createState() => _SchoolFormDialogState();
}

class _SchoolFormDialogState extends State<_SchoolFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _instituteNameController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _phoneController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _countryController;
  late final TextEditingController _pincodeController;
  late final TextEditingController _addressController;
  late final TextEditingController _websiteController;
  late final TextEditingController _establishedYearController;

  bool _isSubmitting = false;

  bool get _isEditing => widget.school != null;

  @override
  void initState() {
    super.initState();
    final school = widget.school;
    _instituteNameController =
        TextEditingController(text: school?.instituteName ?? '');
    _firstNameController = TextEditingController(text: school?.firstName ?? '');
    _lastNameController = TextEditingController(text: school?.lastName ?? '');
    _emailController = TextEditingController(text: school?.email ?? '');
    _passwordController = TextEditingController();
    _phoneController = TextEditingController(text: school?.phone ?? '');
    _cityController = TextEditingController(text: school?.city ?? '');
    _stateController = TextEditingController(text: school?.state ?? '');
    _countryController =
        TextEditingController(text: school?.country ?? 'India');
    _pincodeController = TextEditingController(text: school?.pincode ?? '');
    _addressController = TextEditingController(text: school?.address ?? '');
    _websiteController = TextEditingController(text: school?.website ?? '');
    _establishedYearController =
        TextEditingController(text: school?.establishedYear?.toString() ?? '');
  }

  @override
  void dispose() {
    _instituteNameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _pincodeController.dispose();
    _addressController.dispose();
    _websiteController.dispose();
    _establishedYearController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final password = _passwordController.text.trim();
    if (!_isEditing && password.length < 6) {
      Get.snackbar('Validation', 'Password must be at least 6 characters');
      return;
    }

    final establishedYearText = _establishedYearController.text.trim();
    int? establishedYear;
    if (establishedYearText.isNotEmpty) {
      establishedYear = int.tryParse(establishedYearText);
      if (establishedYear == null) {
        Get.snackbar('Validation', 'Established year must be a valid number');
        return;
      }
    }

    final payload = <String, dynamic>{
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'institute_name': _instituteNameController.text.trim(),
    };

    void addOptional(String key, String value) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        payload[key] = trimmed;
      }
    }

    addOptional('phone', _phoneController.text);
    addOptional('address', _addressController.text);
    addOptional('city', _cityController.text);
    addOptional('state', _stateController.text);
    addOptional('country', _countryController.text);
    addOptional('pincode', _pincodeController.text);
    addOptional('website', _websiteController.text);

    if (establishedYear != null) {
      payload['established_year'] = establishedYear;
    }

    if (password.isNotEmpty) {
      payload['password'] = password;
    }

    setState(() {
      _isSubmitting = true;
    });

    final success = await widget.onSubmit(payload);
    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit School' : 'Create School'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _instituteNameController,
                  decoration: const InputDecoration(
                    labelText: 'School Name',
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                  validator: (value) =>
                      _requiredValidator(value, 'School name'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'Admin First Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) =>
                            _requiredValidator(value, 'First name'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Admin Last Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) =>
                            _requiredValidator(value, 'Last name'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Admin Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    final base = _requiredValidator(value, 'Email');
                    if (base != null) return base;
                    if (value != null && !GetUtils.isEmail(value.trim())) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText:
                        _isEditing ? 'New Password (Optional)' : 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone (Optional)',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address (Optional)',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          labelText: 'City (Optional)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _stateController,
                        decoration: const InputDecoration(
                          labelText: 'State (Optional)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _countryController,
                        decoration: const InputDecoration(
                          labelText: 'Country (Optional)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _pincodeController,
                        decoration: const InputDecoration(
                          labelText: 'Pincode (Optional)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _websiteController,
                        decoration: const InputDecoration(
                          labelText: 'Website (Optional)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _establishedYearController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Established Year (Optional)',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _isSubmitting ? null : _submit,
          icon: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save),
          label: Text(_isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }
}
