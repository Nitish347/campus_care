import 'package:flutter/material.dart';

/// Shows a modern styled confirmation dialog.
/// Returns true if confirmed, false if cancelled/dismissed.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool isDanger = false,
  IconData? icon,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => ConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      isDanger: isDanger,
      icon: icon,
    ),
  );
  return result ?? false;
}

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDanger;
  final IconData? icon;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.isDanger = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor =
        isDanger ? theme.colorScheme.error : theme.colorScheme.primary;
    final dialogIcon = icon ??
        (isDanger ? Icons.warning_amber_rounded : Icons.help_outline_rounded);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: theme.colorScheme.surface,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon badge
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(dialogIcon, color: accentColor, size: 32),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(cancelLabel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(confirmLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
