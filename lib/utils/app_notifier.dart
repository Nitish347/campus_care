import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppNotifier {
  const AppNotifier._();

  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();
  static const Duration _snackDuration = Duration(seconds: 4);

  static void success(String title, String message) {
    show(
      title,
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  static void error(String title, String message) {
    show(
      title,
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  static void info(String title, String message) {
    show(
      title,
      message,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  static void show(
    String title,
    String message, {
    Color? backgroundColor,
    Color? colorText,
  }) {
    final messenger = messengerKey.currentState;
    if (messenger == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final retryMessenger = messengerKey.currentState;
        if (retryMessenger == null) {
          debugPrint('Snackbar skipped: $title - $message');
          return;
        }
        _showSnackBar(
          retryMessenger,
          title,
          message,
          backgroundColor: backgroundColor,
          colorText: colorText,
        );
      });
      return;
    }

    _showSnackBar(
      messenger,
      title,
      message,
      backgroundColor: backgroundColor,
      colorText: colorText,
    );
  }

  static void _showSnackBar(
    ScaffoldMessengerState messenger,
    String title,
    String message, {
    Color? backgroundColor,
    Color? colorText,
  }) {
    final context = messengerKey.currentContext;
    final mediaQuery = context != null ? MediaQuery.maybeOf(context) : null;
    final screenWidth = mediaQuery?.size.width ?? 0;
    final screenHeight = mediaQuery?.size.height ?? 0;
    final isDesktopWeb = kIsWeb && screenWidth >= 768;
    final desktopToastWidth = screenWidth >= 420 ? 360.0 : screenWidth - 48;
    final theme = context != null ? Theme.of(context) : null;
    final resolvedBackground = backgroundColor ?? const Color(0xFF111827);
    final resolvedTextColor = colorText ?? Colors.white;
    final progressColor =
        Color.alphaBlend(Colors.white.withValues(alpha: 0.18), resolvedBackground);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: _snackDuration,
          behavior:
              isDesktopWeb ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
          margin: isDesktopWeb
              ? EdgeInsets.fromLTRB(
                  (screenWidth - desktopToastWidth - 24).clamp(24.0, screenWidth),
                  24,
                  24,
                  (screenHeight - 120).clamp(24.0, screenHeight),
                )
              : null,
          dismissDirection: isDesktopWeb
              ? DismissDirection.horizontal
              : DismissDirection.down,
          elevation: isDesktopWeb ? 10 : 6,
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isDesktopWeb ? 18 : 14),
          ),
          content: Container(
            decoration: BoxDecoration(
              color: resolvedBackground,
              borderRadius: BorderRadius.circular(isDesktopWeb ? 18 : 14),
              boxShadow: isDesktopWeb
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          _resolveIcon(resolvedBackground),
                          size: 18,
                          color: resolvedTextColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style:
                                  theme?.textTheme.titleSmall?.copyWith(
                                    color: resolvedTextColor,
                                    fontWeight: FontWeight.w800,
                                  ) ??
                                      TextStyle(
                                        color: resolvedTextColor,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              message,
                              style:
                                  theme?.textTheme.bodyMedium?.copyWith(
                                    color: resolvedTextColor.withValues(alpha: 0.92),
                                    height: 1.3,
                                  ) ??
                                      TextStyle(
                                        color:
                                            resolvedTextColor.withValues(alpha: 0.92),
                                        height: 1.3,
                                        fontSize: 13,
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: _snackDuration,
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 4,
                        backgroundColor: progressColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          resolvedTextColor.withValues(alpha: 0.9),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  static IconData _resolveIcon(Color backgroundColor) {
    if (backgroundColor == Colors.green) {
      return Icons.check_rounded;
    }
    if (backgroundColor == Colors.red) {
      return Icons.error_outline_rounded;
    }
    if (backgroundColor == Colors.blue) {
      return Icons.info_outline_rounded;
    }
    return Icons.notifications_active_outlined;
  }

  static void afterNavigation(
    String title,
    String message, {
    bool isError = false,
  }) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (isError) {
        error(title, message);
      } else {
        success(title, message);
      }
    });
  }
}
