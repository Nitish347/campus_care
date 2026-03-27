import 'package:flutter/material.dart';

/// A reusable gradient page header with title, subtitle, icon, and optional trailing actions.
class AdminPageHeader extends StatelessWidget implements PreferredSizeWidget {
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
  });

  @override
  Size get preferredSize {
    double height = 110;
    if (bottom != null) {
      height += bottom!.preferredSize.height;
    }
    return Size.fromHeight(height);
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final g1 = gradientStart ??
        (isDark ? const Color(0xFF1E293B) : const Color(0xFF2563EB));
    final g2 = gradientEnd ??
        (isDark ? const Color(0xFF0F172A) : const Color(0xFF1D4ED8));

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20 + MediaQuery.of(context).padding.top, 24, 20),
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
              if (showBackButton) ...[
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
                ),
              ],
              if (icon != null) ...[
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
                    if (showBreadcrumb && breadcrumbLabel != null) ...[
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
                    if (title is Widget)
                      DefaultTextStyle(
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                        child: title,
                      )
                    else if (title != null)
                      Text(
                        title.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    if (subtitle != null) ...[
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
              if (actions != null) ...[
                const SizedBox(width: 12),
                ...actions!,
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

/// Header action button - white outlined button for use inside AdminPageHeader
class HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const HeaderActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
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
