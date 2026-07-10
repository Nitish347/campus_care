import 'package:campus_care/models/holiday_model.dart';
import 'package:campus_care/services/api/holiday_api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HolidayController extends GetxController {
  final HolidayApiService _service = HolidayApiService();

  final _isLoading = false.obs;
  final _selectedYear = DateTime.now().year.obs;
  final _selectedMonth = DateTime.now().month.obs;
  final _holidays = <HolidayModel>[].obs;
  final _errorMessage = RxnString();

  bool get isLoading => _isLoading.value;
  int get selectedYear => _selectedYear.value;
  int get selectedMonth => _selectedMonth.value;
  List<HolidayModel> get holidays => _holidays;
  String? get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    loadHolidays();
  }

  Future<void> loadHolidays({int? year}) async {
    try {
      _isLoading.value = true;
      if (year != null) _selectedYear.value = year;
      _errorMessage.value = null;
      final data = await _service.getHolidays(year: _selectedYear.value);
      _holidays.assignAll(data);
    } catch (e) {
      _errorMessage.value = 'Failed to load holidays: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  void selectMonth(DateTime month) {
    _selectedYear.value = month.year;
    _selectedMonth.value = month.month;
    loadHolidays(year: month.year);
  }

  void previousMonth() {
    selectMonth(DateTime(_selectedYear.value, _selectedMonth.value - 1));
  }

  void nextMonth() {
    selectMonth(DateTime(_selectedYear.value, _selectedMonth.value + 1));
  }

  HolidayModel? holidayForDate(DateTime date) {
    for (final holiday in _holidays) {
      if (holiday.isActive && holiday.isSameDate(date)) return holiday;
    }
    return null;
  }

  Future<HolidayModel?> fetchHolidayForDate(DateTime date) async {
    try {
      return await _service.getHolidayForDate(date);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveHoliday({
    HolidayModel? existing,
    required String name,
    required DateTime date,
    required String type,
    String? description,
    bool isActive = true,
  }) async {
    try {
      _isLoading.value = true;
      final holiday = HolidayModel(
        id: existing?.id ?? '',
        name: name.trim(),
        date: DateTime(date.year, date.month, date.day),
        type: type,
        description:
            description?.trim().isEmpty == true ? null : description?.trim(),
        isActive: isActive,
      );
      if (existing == null) {
        await _service.createHoliday(holiday);
      } else {
        await _service.updateHoliday(holiday);
      }
      await loadHolidays(year: date.year);
      Get.snackbar('Success', 'Holiday saved successfully');
    } catch (e) {
      Get.dialog(
        AlertDialog(
          title: const Text('Could not save holiday'),
          content: Text(e.toString()),
          actions: [
            TextButton(onPressed: Get.back, child: const Text('OK')),
          ],
        ),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> saveHolidayRange({
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required String type,
    String? description,
    bool isActive = true,
  }) async {
    try {
      _isLoading.value = true;
      final normalizedStart =
          DateTime(startDate.year, startDate.month, startDate.day);
      final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);
      final first = normalizedStart.isBefore(normalizedEnd)
          ? normalizedStart
          : normalizedEnd;
      final last = normalizedStart.isBefore(normalizedEnd)
          ? normalizedEnd
          : normalizedStart;

      var cursor = first;
      while (!cursor.isAfter(last)) {
        final existing = holidayForDate(cursor);
        final holiday = HolidayModel(
          id: existing?.id ?? '',
          name: name.trim(),
          date: cursor,
          type: type,
          description:
              description?.trim().isEmpty == true ? null : description?.trim(),
          isActive: isActive,
        );
        if (existing == null) {
          await _service.createHoliday(holiday);
        } else {
          await _service.updateHoliday(holiday);
        }
        cursor = cursor.add(const Duration(days: 1));
      }

      await loadHolidays(year: first.year);
      Get.snackbar('Success', 'Holiday range saved successfully');
    } catch (e) {
      Get.dialog(
        AlertDialog(
          title: const Text('Could not save holiday range'),
          content: Text(e.toString()),
          actions: [
            TextButton(onPressed: Get.back, child: const Text('OK')),
          ],
        ),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteHoliday(HolidayModel holiday) async {
    try {
      _isLoading.value = true;
      await _service.deleteHoliday(holiday.id);
      _holidays.removeWhere((item) => item.id == holiday.id);
      Get.snackbar('Success', 'Holiday deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete holiday: $e');
    } finally {
      _isLoading.value = false;
    }
  }
}
