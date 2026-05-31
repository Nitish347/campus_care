import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/controllers/theme_controller.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StudentAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? extraActions;
  final PreferredSizeWidget? bottom;
  final bool? showBackButton;
  final bool showRightActions;

  const StudentAppBar({
    super.key,
    required this.title,
    this.extraActions,
    this.bottom,
    this.showBackButton,
    this.showRightActions = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(64 + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authController = Get.find<AuthController>();
    final isDark = theme.brightness == Brightness.dark;

    final canPop = Navigator.of(context).canPop();
    final shouldShowBack = showBackButton ?? canPop;

    return Container(
      height: 64 + MediaQuery.of(context).padding.top + (bottom?.preferredSize.height ?? 0),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1A1F2E),
                  const Color(0xFF1E2540),
                ]
              : [
                  const Color(0xFF2563EB),
                  const Color(0xFF1D4ED8),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF2563EB))
                .withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 64,
              child: Row(
                children: [
                  if (shouldShowBack)
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Spacer(),
                  if (showRightActions) ...[
                    GetBuilder<ThemeController>(
                      builder: (themeController) => _AppBarIconButton(
                        icon: theme.brightness == Brightness.dark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        onPressed: () => themeController.toggleTheme(),
                        tooltip: 'Toggle theme',
                      ),
                    ),
                    _AppBarIconButton(
                      icon: Icons.notifications_outlined,
                      onPressed: () => Get.toNamed(AppRoutes.studentNotifications),
                      tooltip: 'Notifications',
                    ),
                    const SizedBox(width: 8),
                    Obx(
                      () => _UserAvatarButton(
                        name: authController.currentStudent?.fullName ?? 'Student',
                        theme: theme,
                        onProfileTap: () => Get.toNamed(AppRoutes.studentProfile),
                        onLogoutTap: () => authController.logout(),
                      ),
                    ),
                    if (extraActions != null) ...extraActions!,
                  ],
                ],
              ),
            ),
          ),
          if (bottom != null) bottom!,
        ],
      ),
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  const _AppBarIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onPressed,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _UserAvatarButton extends StatelessWidget {
  final String name;
  final ThemeData theme;
  final VoidCallback onProfileTap;
  final VoidCallback onLogoutTap;

  const _UserAvatarButton({
    required this.name,
    required this.theme,
    required this.onProfileTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'S';

    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            initial,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person_outline_rounded,
                  color: theme.colorScheme.primary, size: 18),
              const SizedBox(width: 10),
              const Text('My Profile'),
            ],
          ),
          onTap: onProfileTap,
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_rounded,
                  color: theme.colorScheme.error, size: 18),
              const SizedBox(width: 10),
              Text('Logout', style: TextStyle(color: theme.colorScheme.error)),
            ],
          ),
          onTap: onLogoutTap,
        ),
      ],
    );
  }
}
