import '../services/api_service.dart';

class InteractionService {
  static Future<Map<String, dynamic>> checkInteractions(String medicineId) async {
    try {
      final response = await ApiService.get(
        '/medicines/$medicineId/interactions',
      );
      return response;
    } catch (e) {
      throw Exception('Failed to check interactions: $e');
    }
  }

  static String getSeverityDescription(String severity) {
    final descriptions = {
      'severe': 'Avoid combination - serious interaction possible',
      'moderate': 'Use with caution - monitor for side effects',
      'minor': 'Minor interaction possible',
    };
    return descriptions[severity] ?? 'Unknown severity';
  }

  static String getActionRecommendation(String severity) {
    final actions = {
      'severe': 'Do not take these medicines together without medical supervision',
      'moderate': 'Take at different times or consult healthcare provider',
      'minor': 'Monitor for minor side effects',
    };
    return actions[severity] ?? 'Consult healthcare provider';
  }

  static String getSeverityColor(String severity) {
    final colors = {
      'severe': '#FF0000',  // Red
      'moderate': '#FFA500', // Orange
      'minor': '#FFFF00',   // Yellow
    };
    return colors[severity] ?? '#808080'; // Gray for unknown
  }
} 