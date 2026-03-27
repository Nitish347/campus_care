import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;
  final Color? color;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = color ?? theme.colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with double-ring effect
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.06),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
              child: Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withValues(alpha: 0.1),
                  ),
                  child: Icon(
                    icon,
                    size: 36,
                    color: accentColor.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 28),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
