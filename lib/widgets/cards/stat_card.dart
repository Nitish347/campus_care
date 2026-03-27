import 'package:flutter/material.dart';

/// Modern gradient stat card with icon in circular badge, value, and label.
class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? color;
  final String? change;
  final bool isPositiveChange;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.color,
    this.change,
    this.isPositiveChange = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      cardColor.withValues(alpha: 0.25),
                      cardColor.withValues(alpha: 0.12),
                    ]
                  : [
                      cardColor,
                      cardColor.withValues(alpha: 0.8),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: cardColor.withValues(alpha: isDark ? 0.15 : 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon badge
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      icon,
                      color: isDark ? cardColor : Colors.white,
                      size: 24,
                    ),
                  ),
                  // Change badge
                  if (change != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositiveChange
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            size: 12,
                            color: isDark
                                ? cardColor
                                : Colors.white,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            change!,
                            style: TextStyle(
                              color: isDark ? cardColor : Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                    color: isDark ? cardColor : Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: isDark
                      ? cardColor.withValues(alpha: 0.75)
                      : Colors.white.withValues(alpha: 0.85),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
