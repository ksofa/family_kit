import '../services/api_service.dart';

class AnalyticsService {
  static Future<Map<String, dynamic>> getMedicineAnalytics({
    required String medicineId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await ApiService.get(
        '/medicines/$medicineId/analytics',
        queryParameters: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );
      return response;
    } catch (e) {
      throw Exception('Failed to get medicine analytics: $e');
    }
  }

  static Future<Map<String, dynamic>> getUserAnalytics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await ApiService.get(
        '/medicines/analytics/user/me',
        queryParameters: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );
      return response;
    } catch (e) {
      throw Exception('Failed to get user analytics: $e');
    }
  }

  static Future<void> trackMedicineIntake({
    required String medicineId,
    required double dosage,
    required String status,
    String? notes,
  }) async {
    try {
      await ApiService.post(
        '/history/logs',
        {
          'medicine_id': medicineId,
          'dosage': dosage,
          'status': status,
          'notes': notes,
        },
      );
    } catch (e) {
      throw Exception('Failed to track medicine intake: $e');
    }
  }
} 