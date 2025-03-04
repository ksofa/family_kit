import '../models/medicine.dart';
import 'api_service.dart';

class StorageService {
  static Future<Map<String, dynamic>> getMedicineStorageRecommendations(
    String medicineId,
  ) async {
    try {
      final response = await ApiService.get(
        '/medicines/$medicineId/storage-recommendations',
      );
      return response;
    } catch (e) {
      throw Exception('Failed to get storage recommendations: $e');
    }
  }

  // Helper methods for displaying storage information
  static String getStorageConditionsText(Map<String, dynamic> conditions) {
    return conditions['description'] ?? 'Store according to package instructions';
  }

  static List<String> getAllRecommendations(Map<String, dynamic> storageData) {
    List<String> allRecommendations = [];
    
    // Add general storage conditions recommendations
    if (storageData['conditions'] != null && 
        storageData['conditions']['recommendations'] != null) {
      allRecommendations.addAll(
        List<String>.from(storageData['conditions']['recommendations'])
      );
    }
    
    // Add form-specific recommendations
    if (storageData['form_specific_recommendations'] != null) {
      allRecommendations.addAll(
        List<String>.from(storageData['form_specific_recommendations'])
      );
    }
    
    return allRecommendations;
  }

  static bool isRefrigerated(Map<String, dynamic> storageData) {
    return storageData['storage_type'] == 'refrigerated';
  }

  static String getTemperatureRange(Map<String, dynamic> conditions) {
    final tempMin = conditions['temp_min'];
    final tempMax = conditions['temp_max'];
    return '$tempMin-$tempMax°C';
  }
} 