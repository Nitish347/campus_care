import 'package:flutter/material.dart';

/// Modern interactive dashboard/feature card with hover animation and gradient accent.
class DashboardCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? value;
  final Color? iconColor;
  final Color? sidebarColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
    this.trailing,
    this.sidebarColor,
  });

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = widget.iconColor ?? theme.colorScheme.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: widget.backgroundColor ??
                (isDark
                    ? theme.colorScheme.surfaceContainerHighest
                    : theme.colorScheme.surface),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered
                  ? color.withValues(alpha: 0.4)
                  : theme.colorScheme.outline.withValues(alpha: 0.1),
              width: _isHovered ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? color.withValues(alpha: 0.18)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: _isHovered ? 24 : 10,
                offset: _isHovered ? const Offset(0, 8) : const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(20),
              hoverColor: Colors.transparent,
              splashColor: color.withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Gradient icon container
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: _isHovered ? 50 : 46,
                          height: _isHovered ? 50 : 46,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                color,
                                color.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.icon,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        if (widget.trailing != null) widget.trailing!
                        else
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _isHovered ? 1 : 0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                color: color,
                                size: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (widget.value != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        widget.value!,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                    // Bottom accent line on hover
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(top: 12),
                      height: _isHovered ? 3 : 0,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, color.withValues(alpha: 0.3)],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
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
}
