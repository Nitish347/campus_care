import 'package:get/get.dart';
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

      // Don't send id and issuedDate, let backend handle those
      final noticeData = {
        'title': notice.title,
        'description': notice.description,
        'priority': notice.priority,
        'targetedClassId': notice.targetedClassId,
        'targetSections': notice.targetSections,
        'expiryDate': notice.expiryDate?.toIso8601String(),
        'attachment': notice.attachment,
      };

      await _apiService.createNotice(noticeData);
      await loadNotices(); // Refresh list

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
        'description': notice.description,
        'priority': notice.priority,
        'targetedClassId': notice.targetedClassId,
        'targetSections': notice.targetSections,
        'expiryDate': notice.expiryDate?.toIso8601String(),
        'attachment': notice.attachment,
      };

      await _apiService.updateNotice(id, noticeData);
      await loadNotices(); // Refresh list

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
