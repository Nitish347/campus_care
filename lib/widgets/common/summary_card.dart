import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final Widget child;
  final double? padding;

  const SummaryCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: padding ?? 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1D4ED8).withValues(alpha: isDark ? 0.28 : 0.12),
            const Color(0xFF0891B2).withValues(alpha: isDark ? 0.22 : 0.09),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color:
              const Color(0xFF0891B2).withValues(alpha: isDark ? 0.22 : 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color:
                const Color(0xFF0891B2).withValues(alpha: isDark ? 0.18 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
