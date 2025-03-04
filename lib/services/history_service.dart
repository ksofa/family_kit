import '../models/medicine_log.dart';
import 'api_service.dart';

class HistoryService {
  static Future<MedicineLog> createMedicineLog(MedicineLog log) async {
    try {
      final response = await ApiService.post(
        '/history/logs',
        log.toJson(),
      );
      return MedicineLog.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create medicine log: $e');
    }
  }

  static Future<List<MedicineLog>> getMedicineLogs({
    required String medicineId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = {
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      };

      final response = await ApiService.get(
        '/history/logs/medicine/$medicineId',
        queryParameters: queryParams,
      );

      return (response as List)
          .map((json) => MedicineLog.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get medicine logs: $e');
    }
  }

  static Future<List<MedicineLog>> generateUserReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await ApiService.get(
        '/history/reports/user/me',
        queryParameters: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );

      return (response as List)
          .map((json) => MedicineLog.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to generate report: $e');
    }
  }

  static Future<String> generatePdfReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await ApiService.get(
        '/history/reports/user/me/pdf',
        queryParameters: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );

      return response['pdf_url'];
    } catch (e) {
      throw Exception('Failed to generate PDF report: $e');
    }
  }
} 