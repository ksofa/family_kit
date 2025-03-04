import 'api_service.dart';

class StatisticsService {
  static Future<Map<String, dynamic>> getFirstAidKitStatistics(
    String firstAidKitId,
  ) async {
    try {
      final response = await ApiService.get(
        '/first-aid-kits/$firstAidKitId/statistics',
      );
      return response;
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getMedicineUsageHistory(
    String firstAidKitId,
    String medicineId,
  ) async {
    try {
      final response = await ApiService.get(
        '/first-aid-kits/$firstAidKitId/medicines/$medicineId/usage',
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get usage history: $e');
    }
  }

  static Future<void> recordMedicineUsage(
    String firstAidKitId,
    String medicineId,
    double quantity,
  ) async {
    try {
      await ApiService.post(
        '/first-aid-kits/$firstAidKitId/medicines/$medicineId/usage',
        {'quantity': quantity},
      );
    } catch (e) {
      throw Exception('Failed to record usage: $e');
    }
  }
} 