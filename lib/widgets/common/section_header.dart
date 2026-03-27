import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final Color? accentColor;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accentColor ?? theme.colorScheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left accent bar
        Container(
          width: 4,
          height: subtitle != null ? 38 : 22,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color, color.withValues(alpha: 0.4)],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}
