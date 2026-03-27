import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/controllers/theme_controller.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/widgets/common/institute_context_indicator.dart';

class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? extraActions;
  final bool showMenuButton;
  final VoidCallback? onMenuPressed;

  const AdminAppBar({
    super.key,
    this.title,
    this.extraActions,
    this.showMenuButton = false,
    this.onMenuPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authController = Get.find<AuthController>();
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 64 + MediaQuery.of(context).padding.top,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            if (showMenuButton)
              IconButton(
                icon: const Icon(Icons.menu_rounded, color: Colors.white),
                onPressed: onMenuPressed ?? () => Scaffold.of(context).openDrawer(),
              )
            else
              Row(
                children: [
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
                    title ?? 'Campus Care',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            const Spacer(),
            // Actions
            GetBuilder<ThemeController>(
              builder: (themeController) => _AppBarIconButton(
                icon: theme.brightness == Brightness.dark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                onPressed: () => themeController.toggleTheme(),
                tooltip: 'Toggle theme',
              ),
            ),
            const InstituteContextIndicator(),
            _AppBarIconButton(
              icon: Icons.notifications_outlined,
              onPressed: () {},
              tooltip: 'Notifications',
              badge: 0,
            ),
            const SizedBox(width: 8),
            Obx(() => _UserAvatarButton(
                  name: authController.currentAdmin?.fullName ?? 'Admin',
                  theme: theme,
                  onProfileTap: () => Get.toNamed(AppRoutes.adminProfile),
                  onLogoutTap: () => authController.logout(),
                )),
            const SizedBox(width: 4),
            if (extraActions != null) ...extraActions!,
          ],
        ),
      ),
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final int badge;

  const _AppBarIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
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
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              if (badge > 0)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
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
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'A';
    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
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
          enabled: false,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Administrator',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
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
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings_outlined,
                  color: theme.colorScheme.primary, size: 18),
              const SizedBox(width: 10),
              const Text('Settings'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_rounded,
                  color: theme.colorScheme.error, size: 18),
              const SizedBox(width: 10),
              Text('Logout',
                  style: TextStyle(color: theme.colorScheme.error)),
            ],
          ),
          onTap: onLogoutTap,
        ),
      ],
    );
  }
}
