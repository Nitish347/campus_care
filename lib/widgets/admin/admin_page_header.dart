import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/controllers/theme_controller.dart';
import 'package:campus_care/core/constants/app_constants.dart';
import 'package:campus_care/core/routes/app_routes.dart';
import 'package:campus_care/widgets/common/file_display_widget.dart';

/// A reusable gradient page header with title, subtitle, icon, and optional trailing actions.
class AdminPageHeader extends StatelessWidget implements PreferredSizeWidget {
  static const double _mobileBreakpoint = 700;

  final dynamic title;
  final String? subtitle;
  final IconData? icon;
  final List<Widget>? actions;
  final Color? gradientStart;
  final Color? gradientEnd;
  final bool showBreadcrumb;
  final String? breadcrumbLabel;
  final bool showBackButton;
  final PreferredSizeWidget? bottom;
  final bool showProfileControls;

  const AdminPageHeader({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.actions,
    this.gradientStart,
    this.gradientEnd,
    this.showBreadcrumb = false,
    this.breadcrumbLabel,
    this.showBackButton = false,
    this.bottom,
    this.showProfileControls = false,
  });

  @override
  Size get preferredSize {
    final hasExtendedText =
        subtitle != null || (showBreadcrumb && breadcrumbLabel != null);
    double height = hasExtendedText ? 124 : 112;
    if (bottom != null) {
      height += bottom!.preferredSize.height;
    }
    return Size.fromHeight(height);
  }

  List<Widget> _buildActionsForViewport(bool isMobile) {
    final source = actions ?? const <Widget>[];
    if (!isMobile) return source;

    return source.map((action) {
      if (action is HeaderActionButton) {
        return action.copyWith(compact: true);
      }
      if (action is SizedBox) {
        return SizedBox(
          width: action.width == null
              ? null
              : (action.width! > 4 ? 4 : action.width),
          height: action.height,
        );
      }
      return action;
    }).toList();
  }

  Widget _buildTitleWidget({
    required double fontSize,
    required FontWeight fontWeight,
  }) {
    final style = TextStyle(
      color: Colors.white,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: -0.3,
    );

    if (title == null) {
      return const SizedBox.shrink();
    }

    if (title is Text) {
      final text = title as Text;
      final textValue = text.data ?? text.textSpan?.toPlainText() ?? '';
      return Text(
        textValue,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }

    if (title is Widget) {
      return DefaultTextStyle(style: style, child: title);
    }

    return Text(
      title.toString(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < _mobileBreakpoint;

    // Mobile compact mode:
    // - keeps just title + action icons
    // - hides breadcrumb/subtitle/header icon
    // - keeps back button visible when requested
    final shouldShowBackButton = showBackButton;
    final shouldShowHeaderIcon = icon != null && !isMobile;
    final shouldShowBreadcrumb =
        showBreadcrumb && breadcrumbLabel != null && !isMobile;
    final shouldShowSubtitle = subtitle != null && !isMobile;
    final resolvedActions = _buildActionsForViewport(isMobile);
    final trailingProfileControls = showProfileControls && !isMobile
        ? const _HeaderProfileControls()
        : null;

    final g1 = gradientStart ??
        (isDark ? const Color(0xFF1E293B) : const Color(0xFF2563EB));
    final g2 = gradientEnd ??
        (isDark ? const Color(0xFF0F172A) : const Color(0xFF1D4ED8));

    final horizontalPadding = isMobile ? 12.0 : 24.0;
    final verticalPadding = isMobile ? 12.0 : 20.0;
    final titleFontSize = isMobile ? 20.0 : 22.0;
    final titleFontWeight = isMobile ? FontWeight.w600 : FontWeight.w700;

    return Container(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        verticalPadding + MediaQuery.of(context).padding.top,
        horizontalPadding,
        verticalPadding,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [g1, g2],
        ),
        boxShadow: [
          BoxShadow(
            color: g1.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (shouldShowBackButton) ...[
                Container(
                  margin: EdgeInsets.only(right: isMobile ? 10 : 16),
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Padding(
                        padding: EdgeInsets.all(isMobile ? 8 : 10),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: isMobile ? 20 : 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              if (shouldShowHeaderIcon) ...[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (shouldShowBreadcrumb) ...[
                      Row(
                        children: [
                          Text(
                            'Admin',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          Text(
                            breadcrumbLabel!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                    _buildTitleWidget(
                      fontSize: titleFontSize,
                      fontWeight: titleFontWeight,
                    ),
                    if (shouldShowSubtitle) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (resolvedActions.isNotEmpty ||
                  trailingProfileControls != null) ...[
                SizedBox(width: isMobile ? 8 : 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...resolvedActions,
                    if (resolvedActions.isNotEmpty &&
                        trailingProfileControls != null)
                      const SizedBox(width: 10),
                    if (trailingProfileControls != null)
                      trailingProfileControls,
                  ],
                ),
              ],
            ],
          ),
          if (bottom != null) ...[
            const SizedBox(height: 16),
            bottom!,
          ],
        ],
      ),
    );
  }
}

class _HeaderProfileControls extends StatelessWidget {
  const _HeaderProfileControls();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HeaderSquareIconButton(
          icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          tooltip: 'Toggle theme',
          onTap: () {
            if (Get.isRegistered<ThemeController>()) {
              Get.find<ThemeController>().toggleTheme();
            }
          },
        ),
        const SizedBox(width: 8),
        const _HeaderProfileMenuButton(),
      ],
    );
  }
}

class _HeaderProfileMenuButton extends StatelessWidget {
  const _HeaderProfileMenuButton();

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AuthController>()) {
      return const _ProfileAvatarTrigger(
        displayName: 'User',
      );
    }

    final authController = Get.find<AuthController>();

    return Obx(() {
      final role = authController.currentRole ?? '';

      String displayName;
      String roleLabel;
      String? profileImageUrl;
      String profileRoute;

      if (role == AppConstants.roleTeacher) {
        displayName = authController.currentTeacher?.fullName ?? 'Teacher';
        roleLabel = 'Teacher';
        profileImageUrl = authController.currentTeacher?.profileImageUrl;
        profileRoute = AppRoutes.teacherProfile;
      } else if (role == AppConstants.roleStudent) {
        displayName = authController.currentStudent?.fullName ?? 'Student';
        roleLabel = 'Student';
        profileImageUrl = authController.currentStudent?.profileImageUrl;
        profileRoute = AppRoutes.studentProfile;
      } else {
        displayName = authController.currentAdmin?.fullName ?? 'Admin';
        roleLabel = 'Administrator';
        profileImageUrl = authController.currentAdmin?.profileImageUrl;
        profileRoute = AppRoutes.adminProfile;
      }

      return PopupMenuButton<String>(
        tooltip: 'Profile',
        offset: const Offset(0, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onSelected: (value) {
          if (value == 'profile') {
            Get.toNamed(profileRoute);
            return;
          }
          if (value == 'logout') {
            authController.logout();
          }
        },
        child: _ProfileAvatarTrigger(
          displayName: displayName,
          profileImageUrl: profileImageUrl,
        ),
        itemBuilder: (context) => [
          PopupMenuItem<String>(
            enabled: false,
            child: Row(
              children: [
                ProfileAvatarWidget(
                  size: 34,
                  enablePreview: false,
                  imageUrl: profileImageUrl,
                  displayName: displayName,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        roleLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem<String>(
            value: 'profile',
            child: Row(
              children: [
                Icon(Icons.person_outline_rounded, size: 18),
                SizedBox(width: 10),
                Text('My Profile'),
              ],
            ),
          ),
          const PopupMenuItem<String>(
            value: 'logout',
            child: Row(
              children: [
                Icon(Icons.logout_rounded, size: 18),
                SizedBox(width: 10),
                Text('Logout'),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _ProfileAvatarTrigger extends StatelessWidget {
  final String displayName;
  final String? profileImageUrl;

  const _ProfileAvatarTrigger({
    required this.displayName,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: ClipOval(
        child: ProfileAvatarWidget(
          size: 36,
          enablePreview: false,
          imageUrl: profileImageUrl,
          displayName: displayName,
        ),
      ),
    );
  }
}

class _HeaderSquareIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderSquareIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Header action button - white outlined button for use inside AdminPageHeader
class HeaderActionButton extends StatelessWidget {
  static const double _mobileBreakpoint = 700;

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool compact;
  final String? tooltip;

  const HeaderActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.compact = false,
    this.tooltip,
  });

  HeaderActionButton copyWith({
    bool? compact,
    String? tooltip,
  }) {
    return HeaderActionButton(
      icon: icon,
      label: label,
      onPressed: onPressed,
      compact: compact ?? this.compact,
      tooltip: tooltip ?? this.tooltip,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < _mobileBreakpoint;
    final useCompact = compact || isMobile;

    if (useCompact) {
      return Tooltip(
        message: tooltip ?? label,
        child: Material(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onPressed,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: Icon(icon, color: Colors.white, size: 18),
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
