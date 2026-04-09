import 'package:flutter/material.dart';
import 'package:campus_care/utils/upload_url_utils.dart';

class FileDisplayWidget extends StatelessWidget {
  final String? fileUrl;
  final List<String>? fileUrls;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final bool circular;
  final bool enablePreview;
  final String? previewTitle;

  const FileDisplayWidget({
    super.key,
    this.fileUrl,
    this.fileUrls,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.circular = false,
    this.enablePreview = true,
    this.previewTitle,
  });

  List<String> get _resolvedUrls {
    final values = fileUrls ?? UploadUrlUtils.buildCandidateUrls(fileUrl);
    if (values.isEmpty) return const [];
    return values
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final urls = _resolvedUrls;
    final fallbackWidget =
        errorWidget ?? placeholder ?? const SizedBox.shrink();

    Widget child;
    if (urls.isEmpty) {
      child = placeholder ?? const SizedBox.shrink();
    } else {
      child = _buildFallbackImage(
        urls: urls,
        fit: fit,
        width: width,
        height: height,
        errorWidget: fallbackWidget,
      );
    }

    if (circular) {
      child = ClipOval(child: child);
    } else if (borderRadius != null) {
      child = ClipRRect(borderRadius: borderRadius!, child: child);
    }

    if (width != null || height != null) {
      child = SizedBox(width: width, height: height, child: child);
    }

    if (enablePreview && urls.isNotEmpty) {
      return GestureDetector(
        onTap: () => showImagePreviewDialog(
          context,
          imageUrls: urls,
          title: previewTitle,
        ),
        child: child,
      );
    }

    return child;
  }

  static Future<void> showImagePreviewDialog(
    BuildContext context, {
    required List<String> imageUrls,
    String? title,
  }) async {
    if (imageUrls.isEmpty) return;
    final theme = Theme.of(context);

    await showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title ?? 'Image Preview',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Center(
                    child: InteractiveViewer(
                      minScale: 0.6,
                      maxScale: 5,
                      child: _buildFallbackImage(
                        urls: imageUrls,
                        fit: BoxFit.contain,
                        errorWidget: Text(
                          'Unable to load image',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildFallbackImage({
    required List<String> urls,
    required BoxFit fit,
    required Widget errorWidget,
    double? width,
    double? height,
  }) {
    if (urls.isEmpty) return errorWidget;

    final primary = urls.first;
    final fallback = urls.length > 1 ? urls[1] : null;

    return Image.network(
      primary,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        if (fallback == null || fallback == primary) {
          return errorWidget;
        }
        return Image.network(
          fallback,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (context, error, stackTrace) => errorWidget,
        );
      },
    );
  }
}

class ProfileAvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final List<String>? imageUrls;
  final String displayName;
  final double size;
  final bool enablePreview;
  final Gradient? backgroundGradient;
  final TextStyle? textStyle;
  final Color? backgroundColor;

  const ProfileAvatarWidget({
    super.key,
    this.imageUrl,
    this.imageUrls,
    required this.displayName,
    this.size = 48,
    this.enablePreview = true,
    this.backgroundGradient,
    this.textStyle,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalizedInitial = displayName.trim().isEmpty ? 'U' : displayName[0];
    final effectiveTextStyle = textStyle ??
        TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size > 45 ? 20 : 14,
        );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        gradient: backgroundGradient ??
            LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.7),
              ],
            ),
      ),
      child: FileDisplayWidget(
        fileUrl: imageUrl,
        fileUrls: imageUrls,
        width: size,
        height: size,
        circular: true,
        fit: BoxFit.cover,
        enablePreview: enablePreview,
        previewTitle: displayName,
        placeholder: Center(
          child: Text(
            normalizedInitial.toUpperCase(),
            style: effectiveTextStyle,
          ),
        ),
        errorWidget: Center(
          child: Text(
            normalizedInitial.toUpperCase(),
            style: effectiveTextStyle,
          ),
        ),
      ),
    );
  }
}
