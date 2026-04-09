import 'package:campus_care/core/constants/app_constants.dart';

class UploadUrlUtils {
  static const String _uploadsFilePrefix = '/api/v1/uploads/file/';

  /// Rebind upload-file URLs to the current API base URL.
  ///
  /// This keeps images visible when data was stored from a different environment
  /// (for example: production host URL stored while app currently uses localhost).
  static String? normalizeToApiBase(String? rawUrl) {
    if (rawUrl == null) return null;
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return null;

    final markerIndex = trimmed.indexOf(_uploadsFilePrefix);
    if (markerIndex == -1) {
      return trimmed;
    }

    final encodedObjectKey =
        trimmed.substring(markerIndex + _uploadsFilePrefix.length);
    if (encodedObjectKey.isEmpty) {
      return trimmed;
    }

    final base = AppConstants.baseUrl.endsWith('/')
        ? AppConstants.baseUrl.substring(0, AppConstants.baseUrl.length - 1)
        : AppConstants.baseUrl;

    return '$base$_uploadsFilePrefix$encodedObjectKey';
  }

  /// Returns candidate URLs in priority order:
  /// 1) URL rebound to current API base
  /// 2) Original stored URL
  static List<String> buildCandidateUrls(String? rawUrl) {
    if (rawUrl == null) return const [];
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return const [];

    final candidates = <String>{};
    final rebased = normalizeToApiBase(trimmed);
    if (rebased != null && rebased.isNotEmpty) {
      candidates.add(rebased);
    }
    candidates.add(trimmed);
    return candidates.toList();
  }
}
