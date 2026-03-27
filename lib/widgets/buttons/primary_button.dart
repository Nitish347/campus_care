import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final double height;
  final double? width;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? prefixIcon;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.height = 52,
    this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: 28),
    this.backgroundColor,
    this.foregroundColor,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = backgroundColor ?? theme.colorScheme.primary;
    final fg = foregroundColor ?? theme.colorScheme.onPrimary;

    return SizedBox(
      height: height,
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: onPressed != null && !isLoading
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [bg, bg.withValues(alpha: 0.8)],
                )
              : null,
          color: onPressed == null || isLoading
              ? theme.colorScheme.outline.withValues(alpha: 0.25)
              : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: onPressed != null && !isLoading
              ? [
                  BoxShadow(
                    color: bg.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: fg,
            disabledBackgroundColor: Colors.transparent,
            disabledForegroundColor:
                theme.colorScheme.onSurface.withValues(alpha: 0.38),
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          child: isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(fg),
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
      ),
    );
  }
}