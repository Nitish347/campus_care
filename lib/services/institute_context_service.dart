import 'package:get/get.dart';
import 'package:campus_care/models/institute/institute_model.dart';
import 'package:campus_care/services/storage_service.dart';

class InstituteContextService extends GetxService {
  // Observable current institute
  final Rx<Institute?> currentInstitute = Rx<Institute?>(null);

  // Storage key
  static const String _keyInstituteId = 'current_institute_id';

  // Check if in super admin mode (managing an institute)
  bool get isInInstituteContext => currentInstitute.value != null;

  // Get current institute ID
  String? get currentInstituteId => currentInstitute.value?.id;

  // Get current institute name
  String? get currentInstituteName => currentInstitute.value?.name;

  @override
  void onInit() {
    super.onInit();
    _loadSavedContext();
  }

  /// Load saved institute context from storage
  void _loadSavedContext() {
    final savedId = StorageService.prefs.getString(_keyInstituteId);
    if (savedId != null) {
      // Context will be restored when institute controller loads
      // This is just to indicate that we had a context
    }
  }

  /// Set the current institute context
  Future<void> setInstituteContext(Institute institute) async {
    currentInstitute.value = institute;
    await StorageService.prefs.setString(_keyInstituteId, institute.id);

    Get.snackbar(
      'Institute Context Set',
      'Now managing ${institute.name}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// Clear the current institute context
  Future<void> clearInstituteContext() async {
    currentInstitute.value = null;
    await StorageService.prefs.remove(_keyInstituteId);
  }

  /// Restore institute context from saved ID
  void restoreContext(Institute institute) {
    final savedId = StorageService.prefs.getString(_keyInstituteId);
    if (savedId == institute.id) {
      currentInstitute.value = institute;
    }
  }

  /// Check if a specific institute is the current context
  bool isCurrentInstitute(String instituteId) {
    return currentInstituteId == instituteId;
  }
}
