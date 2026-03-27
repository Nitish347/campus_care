import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final double height;
  final double? width;
  final EdgeInsets padding;
  final Color? borderColor;
  final Color? foregroundColor;
  final IconData? prefixIcon;

  const SecondaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.height = 52,
    this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: 28),
    this.borderColor,
    this.foregroundColor,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fgColor = foregroundColor ?? theme.colorScheme.primary;
    final bd = borderColor ?? theme.colorScheme.primary.withValues(alpha: 0.4);

    return SizedBox(
      height: height,
      width: width,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: fgColor,
          side: BorderSide(color: bd, width: 1.5),
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                ),
              )
            : (prefixIcon != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(prefixIcon, size: 18),
                      const SizedBox(width: 8),
                      child,
                    ],
                  )
                : child),
      ),
    );
  }
}
