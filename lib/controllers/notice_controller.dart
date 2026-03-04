import 'package:get/get.dart';
import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/models/notice_model.dart';
import 'package:campus_care/services/api/notice_api_service.dart';

class NoticeController extends GetxController {
  final NoticeApiService _apiService = NoticeApiService();

  final _notices = <NoticeModel>[].obs;
  final _isLoading = false.obs;
  final _filteredNotices = <NoticeModel>[].obs;
  final _searchQuery = ''.obs;

  List<NoticeModel> get notices => _filteredNotices;
  bool get isLoading => _isLoading.value;
  String get searchQuery => _searchQuery.value;

  @override
  void onInit() {
    super.onInit();
    loadNotices();
  }

  Future<void> loadNotices() async {
    try {
      _isLoading.value = true;
      final data = await _apiService.getNotices();

      _notices.value = data.map((json) => NoticeModel.fromJson(json)).toList();

      _applyFilter();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load notices: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> createNotice(NoticeModel notice) async {
    try {
      _isLoading.value = true;

      // Get the logged-in admin's ID for author_id
      final authController = Get.find<AuthController>();
      final authorId = authController.getMarkedBy() ?? '';

      final noticeData = {
        'title': notice.title,
        'content': notice.description, // DB column: content
        'author_id': authorId, // DB column: author_id (required)
        'priority': notice.priority, // 'low', 'normal', 'high'
        'publish_date': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        if (notice.expiryDate != null)
          'expiry_date': notice.expiryDate!.millisecondsSinceEpoch ~/ 1000,
        if (notice.targetedClassId != null)
          'target_classes': notice.targetedClassId,
        if (notice.targetSections != null)
          'target_audience': notice.targetSections,
        if (notice.attachment != null) 'attachments': notice.attachment,
        'is_active': 1,
      };

      await _apiService.createNotice(noticeData);
      await loadNotices();

      Get.snackbar('Success', 'Notice created successfully');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to create notice: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateNotice(String id, NoticeModel notice) async {
    try {
      _isLoading.value = true;

      final noticeData = {
        'title': notice.title,
        'content': notice.description, // DB column: content
        'priority': notice.priority,
        if (notice.expiryDate != null)
          'expiry_date': notice.expiryDate!.millisecondsSinceEpoch ~/ 1000,
        if (notice.targetedClassId != null)
          'target_classes': notice.targetedClassId,
        if (notice.targetSections != null)
          'target_audience': notice.targetSections,
        if (notice.attachment != null) 'attachments': notice.attachment,
      };

      await _apiService.updateNotice(id, noticeData);
      await loadNotices();

      Get.snackbar('Success', 'Notice updated successfully');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update notice: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> deleteNotice(String id) async {
    try {
      _isLoading.value = true;
      await _apiService.deleteNotice(id);
      await loadNotices(); // Refresh list

      Get.snackbar('Success', 'Notice deleted successfully');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete notice: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  void searchNotices(String query) {
    _searchQuery.value = query;
    _applyFilter();
  }

  void _applyFilter() {
    if (_searchQuery.value.isEmpty) {
      _filteredNotices.value = List.from(_notices);
    } else {
      _filteredNotices.value = _notices.where((notice) {
        final searchLower = _searchQuery.value.toLowerCase();
        return notice.title.toLowerCase().contains(searchLower) ||
            notice.description.toLowerCase().contains(searchLower);
      }).toList();
    }
  }
}
