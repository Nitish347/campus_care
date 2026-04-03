import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/utils/validators.dart';
import 'package:campus_care/widgets/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TabbedLoginScreen extends StatefulWidget {
  const TabbedLoginScreen({super.key});

  @override
  State<TabbedLoginScreen> createState() => _TabbedLoginScreenState();
}

class _TabbedLoginScreenState extends State<TabbedLoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  final _superAdminFormKey = GlobalKey<FormState>();
  final _adminFormKey = GlobalKey<FormState>();
  final _teacherFormKey = GlobalKey<FormState>();
  final _studentFormKey = GlobalKey<FormState>();

  final _superAdminEmailController = TextEditingController();
  final _superAdminPasswordController = TextEditingController();
  final _adminEmailController = TextEditingController();
  final _adminPasswordController = TextEditingController();
  final _teacherEmailController = TextEditingController();
  final _teacherPasswordController = TextEditingController();
  final _studentEmailController = TextEditingController();
  final _studentPasswordController = TextEditingController();

  final _isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging && mounted) {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _superAdminEmailController.dispose();
    _superAdminPasswordController.dispose();
    _adminEmailController.dispose();
    _adminPasswordController.dispose();
    _teacherEmailController.dispose();
    _teacherPasswordController.dispose();
    _studentEmailController.dispose();
    _studentPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1100;
    final isTablet = size.width >= 700 && size.width < 1100;
    final isSmallMobile = size.width < 420;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.10),
              theme.colorScheme.tertiary.withValues(alpha: 0.05),
              theme.colorScheme.secondary.withValues(alpha: 0.10),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (isDesktop) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildDesktopInfoPanel(theme),
                    ),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
                            child: _buildLoginCard(
                              context,
                              isCompact: false,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(
                    isTablet ? 24 : (isSmallMobile ? 12 : 16),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 700 : 520,
                    ),
                    child: _buildLoginCard(
                      context,
                      isCompact: !isTablet,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopInfoPanel(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E40AF),
            Color(0xFF2563EB),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Campus Care',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 36,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'One place to manage institutions, teachers and students.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const Spacer(),
          _buildInfoItem(Icons.security_rounded, 'Secure role-based access'),
          const SizedBox(height: 10),
          _buildInfoItem(Icons.devices_rounded, 'Optimized for web and mobile'),
          const SizedBox(height: 10),
          _buildInfoItem(
              Icons.speed_rounded, 'Fast daily operations for staff'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(
    BuildContext context, {
    required bool isCompact,
  }) {
    final theme = Theme.of(context);
    final roleConfigs = _roleConfigs(theme);
    final current = roleConfigs[_currentTabIndex];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isCompact ? 20 : 30),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 26,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_circle_rounded,
            size: isCompact ? 54 : 62,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 10),
          Text(
            'Sign In',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Choose your role and continue',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: isCompact,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              labelColor: theme.colorScheme.onPrimary,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              tabs: roleConfigs
                  .map(
                    (cfg) => Tab(
                      icon: Icon(cfg.icon, size: 18),
                      text: cfg.tabLabel,
                      height: 58,
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 22),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: _buildLoginForm(
              key: ValueKey(current.userType),
              formKey: current.formKey,
              emailController: current.emailController,
              passwordController: current.passwordController,
              userType: current.userType,
              onLogin: current.onLogin,
              demoEmail: current.demoEmail,
              demoPassword: current.demoPassword,
              color: current.color,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Campus Care v1.0.0',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<_RoleConfig> _roleConfigs(ThemeData theme) {
    return [
      _RoleConfig(
        tabLabel: 'Super',
        userType: 'Super Admin',
        icon: Icons.shield_rounded,
        color: Colors.purple,
        formKey: _superAdminFormKey,
        emailController: _superAdminEmailController,
        passwordController: _superAdminPasswordController,
        onLogin: _loginSuperAdmin,
        demoEmail: 'superadmin@campuscare.com',
        demoPassword: 'SuperAdmin@123',
      ),
      _RoleConfig(
        tabLabel: 'Admin',
        userType: 'Admin',
        icon: Icons.admin_panel_settings_rounded,
        color: theme.colorScheme.primary,
        formKey: _adminFormKey,
        emailController: _adminEmailController,
        passwordController: _adminPasswordController,
        onLogin: _loginAdmin,
        demoEmail: 'admin@example.com',
        demoPassword: 'admin123',
      ),
      _RoleConfig(
        tabLabel: 'Teacher',
        userType: 'Teacher',
        icon: Icons.person_rounded,
        color: theme.colorScheme.secondary,
        formKey: _teacherFormKey,
        emailController: _teacherEmailController,
        passwordController: _teacherPasswordController,
        onLogin: _loginTeacher,
        demoEmail: 'teacher@example.com',
        demoPassword: 'teacher123',
      ),
      _RoleConfig(
        tabLabel: 'Student',
        userType: 'Student',
        icon: Icons.school_rounded,
        color: theme.colorScheme.tertiary,
        formKey: _studentFormKey,
        emailController: _studentEmailController,
        passwordController: _studentPasswordController,
        onLogin: _loginStudent,
        demoEmail: 'student@example.com',
        demoPassword: 'student123',
      ),
    ];
  }

  Widget _buildLoginForm({
    Key? key,
    required GlobalKey<FormState> formKey,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required String userType,
    required VoidCallback onLogin,
    required String demoEmail,
    required String demoPassword,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Form(
      key: formKey,
      child: Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.validateEmail,
            decoration: InputDecoration(
              labelText: 'Email Address',
              hintText: 'Enter your email',
              prefixIcon: Icon(Icons.email_outlined, color: color),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            validator: Validators.validatePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: Icon(Icons.lock_outline, color: color),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => PrimaryButton(
              onPressed: _isLoading.value ? null : onLogin,
              isLoading: _isLoading.value,
              backgroundColor: color,
              child: Text('Sign In as $userType'),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _isLoading.value
                ? null
                : () {
                    emailController.text = demoEmail;
                    passwordController.text = demoPassword;
                    onLogin();
                  },
            icon: Icon(Icons.flash_on, size: 18, color: color),
            label: Text(
              'Use Demo Account',
              style: TextStyle(color: color),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: color.withValues(alpha: 0.6)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Demo: $demoEmail',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _loginSuperAdmin() async {
    if (!_superAdminFormKey.currentState!.validate()) return;

    _isLoading.value = true;
    try {
      final authController = Get.find<AuthController>();
      await authController.loginWithCredentials(
        email: _superAdminEmailController.text,
        password: _superAdminPasswordController.text,
        role: 'super_admin',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loginAdmin() async {
    if (!_adminFormKey.currentState!.validate()) return;

    _isLoading.value = true;
    try {
      final authController = Get.find<AuthController>();
      await authController.loginWithCredentials(
        email: _adminEmailController.text,
        password: _adminPasswordController.text,
        role: 'admin',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loginTeacher() async {
    if (!_teacherFormKey.currentState!.validate()) return;

    _isLoading.value = true;
    try {
      final authController = Get.find<AuthController>();
      await authController.loginWithCredentials(
        email: _teacherEmailController.text,
        password: _teacherPasswordController.text,
        role: 'teacher',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loginStudent() async {
    if (!_studentFormKey.currentState!.validate()) return;

    _isLoading.value = true;
    try {
      final authController = Get.find<AuthController>();
      await authController.loginWithCredentials(
        email: _studentEmailController.text,
        password: _studentPasswordController.text,
        role: 'student',
      );
    } finally {
      _isLoading.value = false;
    }
  }
}

class _RoleConfig {
  final String tabLabel;
  final String userType;
  final IconData icon;
  final Color color;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;
  final String demoEmail;
  final String demoPassword;

  const _RoleConfig({
    required this.tabLabel,
    required this.userType,
    required this.icon,
    required this.color,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
    required this.demoEmail,
    required this.demoPassword,
  });
}
