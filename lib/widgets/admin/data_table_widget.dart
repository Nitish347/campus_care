import 'package:flutter/material.dart';

/// Modern styled data table with themed header, rounded container, and row highlights.
class AdminDataTable extends StatelessWidget {
  final List<AdminDataColumn> columns;
  final List<AdminDataRow> rows;
  final bool isLoading;

  const AdminDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width - 32,
            ),
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: {
                for (var i = 0; i < columns.length; i++)
                  i: columns[i].width ?? const FlexColumnWidth(),
              },
              children: [
                // Header row
                TableRow(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.08),
                        theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                  children: columns
                      .map(
                        (col) => _TableHeaderCell(column: col),
                      )
                      .toList(),
                ),
                // Data rows
                ...rows.asMap().entries.map((entry) {
                  final isEven = entry.key % 2 == 0;
                  return TableRow(
                    decoration: BoxDecoration(
                      color: isEven
                          ? theme.colorScheme.surface
                          : theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.15),
                    ),
                    children: entry.value.cells,
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AdminDataColumn {
  final String label;
  final TableColumnWidth? width;
  final TextAlign align;

  const AdminDataColumn({
    required this.label,
    this.width,
    this.align = TextAlign.left,
  });
}

class AdminDataRow {
  final List<Widget> cells;

  const AdminDataRow({required this.cells});
}

class _TableHeaderCell extends StatelessWidget {
  final AdminDataColumn column;

  const _TableHeaderCell({required this.column});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text(
        column.label,
        textAlign: column.align,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.primary,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

/// A standard table cell padding wrapper
class AdminTableCell extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const AdminTableCell({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(padding: padding, child: child);
  }
}

/// A badge/chip used in tables for status, class labels, etc.
class TableBadge extends StatelessWidget {
  final String label;
  final Color? color;

  const TableBadge({super.key, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeColor = color ?? theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: badgeColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
