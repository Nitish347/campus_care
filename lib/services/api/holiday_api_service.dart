import 'package:campus_care/core/api_client.dart';
import 'package:campus_care/core/constants/app_constants.dart';
import 'package:campus_care/models/holiday_model.dart';

class HolidayApiService {
  final ApiClient _apiClient = ApiClient();

  Future<List<HolidayModel>> getHolidays({
    int? year,
    DateTime? startDate,
    DateTime? endDate,
    bool includeInactive = false,
  }) async {
    final queryParams = <String, dynamic>{};
    if (year != null) queryParams['year'] = year;
    if (startDate != null) {
      queryParams['startDate'] = startDate.toUtc().toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toUtc().toIso8601String();
    }
    if (includeInactive) queryParams['includeInactive'] = 'true';

    final response = await _apiClient.get(
      AppConstants.holidaysEndpoint,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    final data = response['data'];
    if (response['success'] == true && data is List) {
      return data
          .whereType<Map>()
          .map((item) => HolidayModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return [];
  }

  Future<HolidayModel?> getHolidayForDate(DateTime date) async {
    final localDate = DateTime(date.year, date.month, date.day);
    final unix = localDate.millisecondsSinceEpoch ~/ 1000;
    final response =
        await _apiClient.get('${AppConstants.holidaysEndpoint}/date/$unix');
    final data = response['data'];
    if (response['success'] == true && data is Map) {
      return HolidayModel.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  Future<HolidayModel> createHoliday(HolidayModel holiday) async {
    final response = await _apiClient.post(
      AppConstants.holidaysEndpoint,
      body: holiday.toJson()..remove('id'),
    );
    final data = response['data'];
    if (response['success'] == true && data is Map) {
      return HolidayModel.fromJson(Map<String, dynamic>.from(data));
    }
    throw Exception(response['message'] ?? 'Failed to create holiday');
  }

  Future<HolidayModel> updateHoliday(HolidayModel holiday) async {
    final response = await _apiClient.patch(
      '${AppConstants.holidaysEndpoint}/${holiday.id}',
      body: holiday.toJson()..remove('id'),
    );
    final data = response['data'];
    if (response['success'] == true && data is Map) {
      return HolidayModel.fromJson(Map<String, dynamic>.from(data));
    }
    throw Exception(response['message'] ?? 'Failed to update holiday');
  }

  Future<void> deleteHoliday(String id) async {
    await _apiClient.delete('${AppConstants.holidaysEndpoint}/$id');
  }
}
