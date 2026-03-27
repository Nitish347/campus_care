import 'package:flutter/material.dart';

/// A reusable modern detail/view popup dialog.
class DetailDialog extends StatelessWidget {
  /// Avatar initial letter or image
  final String avatarInitial;
  final String title;
  final String? subtitle;
  final Color? accentColor;
  final List<DetailSection> sections;
  final List<Widget>? footerActions;

  const DetailDialog({
    super.key,
    required this.avatarInitial,
    required this.title,
    this.subtitle,
    this.accentColor,
    required this.sections,
    this.footerActions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accentColor ?? theme.colorScheme.primary;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: theme.colorScheme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gradient header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 16, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2),
                    ),
                    child: Center(
                      child: Text(
                        avatarInitial.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: Colors.white, size: 18),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: sections
                      .map((s) => _DetailSectionWidget(section: s, accentColor: color))
                      .toList(),
                ),
              ),
            ),

            // Footer actions
            if (footerActions != null && footerActions!.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.4),
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.15),
                    ),
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: footerActions!
                      .map((w) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: w,
                          ))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DetailSection {
  final String title;
  final List<DetailRow> rows;

  const DetailSection({required this.title, required this.rows});
}

class DetailRow {
  final IconData icon;
  final String label;
  final String value;

  const DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _DetailSectionWidget extends StatelessWidget {
  final DetailSection section;
  final Color accentColor;

  const _DetailSectionWidget({
    required this.section,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title with left accent
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                section.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Rows grouped in a card
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              children: section.rows.asMap().entries.map((entry) {
                final isLast = entry.key == section.rows.length - 1;
                return _DetailRowWidget(
                  row: entry.value,
                  accentColor: accentColor,
                  showDivider: !isLast,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRowWidget extends StatelessWidget {
  final DetailRow row;
  final Color accentColor;
  final bool showDivider;

  const _DetailRowWidget({
    required this.row,
    required this.accentColor,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(row.icon, size: 16, color: accentColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      row.value.isEmpty ? '—' : row.value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 60,
            endIndent: 0,
            color: theme.colorScheme.outline.withValues(alpha: 0.12),
          ),
      ],
    );
  }
}
