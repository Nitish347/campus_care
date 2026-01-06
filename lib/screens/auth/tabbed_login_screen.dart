import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/utils/validators.dart';
import 'package:campus_care/widgets/buttons/primary_button.dart';

class TabbedLoginScreen extends StatefulWidget {
  const TabbedLoginScreen({super.key});

  @override
  State<TabbedLoginScreen> createState() => _TabbedLoginScreenState();
}

class _TabbedLoginScreenState extends State<TabbedLoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _superAdminFormKey = GlobalKey<FormState>();
  final _adminFormKey = GlobalKey<FormState>();
  final _teacherFormKey = GlobalKey<FormState>();
  final _studentFormKey = GlobalKey<FormState>();

  // Controllers for each tab
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
  }

  @override
  void dispose() {
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
    final isWeb = size.width > 800;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.1),
              theme.colorScheme.secondary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                width: isWeb ? 600 : double.infinity,
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // App Logo and Title
                    Icon(
                      Icons.school_rounded,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Campus Care',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Sign in to continue',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Tab Bar
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        indicator: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        labelColor: theme.colorScheme.onPrimary,
                        unselectedLabelColor:
                            theme.colorScheme.onSurfaceVariant,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 13,
                        ),
                        tabs: const [
                          Tab(
                            icon: Icon(Icons.shield, size: 20),
                            text: 'Super\nAdmin',
                            height: 70,
                          ),
                          Tab(
                            icon: Icon(Icons.admin_panel_settings, size: 20),
                            text: 'Admin',
                            height: 70,
                          ),
                          Tab(
                            icon: Icon(Icons.person, size: 20),
                            text: 'Teacher',
                            height: 70,
                          ),
                          Tab(
                            icon: Icon(Icons.school, size: 20),
                            text: 'Student',
                            height: 70,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Tab Views
                    SizedBox(
                      height: 350,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildLoginForm(
                            formKey: _superAdminFormKey,
                            emailController: _superAdminEmailController,
                            passwordController: _superAdminPasswordController,
                            userType: 'Super Admin',
                            onLogin: _loginSuperAdmin,
                            demoEmail: 'superadmin@campuscare.com',
                            demoPassword: 'SuperAdmin@123',
                            color: Colors.purple,
                          ),
                          _buildLoginForm(
                            formKey: _adminFormKey,
                            emailController: _adminEmailController,
                            passwordController: _adminPasswordController,
                            userType: 'Admin',
                            onLogin: _loginAdmin,
                            demoEmail: 'admin@example.com',
                            demoPassword: 'admin123',
                            color: theme.colorScheme.primary,
                          ),
                          _buildLoginForm(
                            formKey: _teacherFormKey,
                            emailController: _teacherEmailController,
                            passwordController: _teacherPasswordController,
                            userType: 'Teacher',
                            onLogin: _loginTeacher,
                            demoEmail: 'teacher@example.com',
                            demoPassword: 'teacher123',
                            color: theme.colorScheme.secondary,
                          ),
                          _buildLoginForm(
                            formKey: _studentFormKey,
                            emailController: _studentEmailController,
                            passwordController: _studentPasswordController,
                            userType: 'Student',
                            onLogin: _loginStudent,
                            demoEmail: 'student@example.com',
                            demoPassword: 'student123',
                            color: theme.colorScheme.tertiary,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Version info
                    Text(
                      'Campus Care v1.0.0',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm({
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

    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email Field
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
              decoration: InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter your email',
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: color,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: color, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Password Field
            TextFormField(
              controller: passwordController,
              obscureText: true,
              validator: Validators.validatePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: color,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: color, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Login Button
            Obx(() => PrimaryButton(
                  onPressed: _isLoading.value ? null : onLogin,
                  isLoading: _isLoading.value,
                  backgroundColor: color,
                  child: Text('Sign In as $userType'),
                )),

            const SizedBox(height: 16),

            // Demo Login Button
            OutlinedButton.icon(
              onPressed: () {
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
                side: BorderSide(color: color),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
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
