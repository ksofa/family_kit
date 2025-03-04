import '../models/medicine.dart';
import 'api_service.dart';
import 'notification_manager.dart';
import 'cache_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicineService {
  static final _medicines = FirebaseFirestore.instance.collection('medicines');

  static Future<List<Medicine>> getFirstAidKitMedicines(String kitId) async {
    try {
      // Сначала пробуем получить из кэша
      final cached = await CacheService.getCachedMedicines(kitId);
      if (cached != null) {
        return cached;
      }

      // Если нет в кэше, загружаем с сервера
      final response = await ApiService.get('/first-aid-kits/$kitId/medicines');
      final medicines = (response as List)
          .map((json) => Medicine.fromJson(json))
          .toList();
      
      // Кэшируем результат
      await CacheService.cacheMedicines(kitId, medicines);
      
      return medicines;
    } catch (e) {
      throw Exception('Failed to get medicines: $e');
    }
  }

  static Future<Medicine> createMedicine({
    required String firstAidKitId,
    required String name,
    required String activeSubstance,
    required double quantity,
    required String unit,
    required DateTime expirationDate,
  }) async {
    try {
      final response = await ApiService.post(
        '/first-aid-kits/$firstAidKitId/medicines',
        {
          'name': name,
          'active_substance': activeSubstance,
          'quantity': quantity,
          'unit': unit,
          'expiration_date': expirationDate.toIso8601String(),
        },
      );
      final medicine = Medicine.fromJson(response);

      // Добавляем уведомление об истечении срока годности
      await NotificationManager.scheduleExpirationAlert(medicine);

      return medicine;
    } catch (e) {
      throw Exception('Failed to create medicine: $e');
    }
  }

  static Future<Medicine> updateMedicine(
    String medicineId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await ApiService.patch(
        '/medicines/$medicineId',
        updates,
      );
      return Medicine.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update medicine: $e');
    }
  }

  static Future<void> deleteMedicine(String medicineId) async {
    try {
      await ApiService.delete('/medicines/$medicineId');
    } catch (e) {
      throw Exception('Failed to delete medicine: $e');
    }
  }

  static Future<void> updateQuantity(String id, double newQuantity) async {
    await _medicines.doc(id).update({'remainingQuantity': newQuantity});
  }

  static Future<List<Map<String, dynamic>>> checkInteractions(
    String medicineId,
  ) async {
    try {
      final response = await ApiService.get('/medicines/$medicineId/interactions');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to check interactions: $e');
    }
  }

  static Future<Map<String, dynamic>> getStorageRecommendations(
    String medicineId,
  ) async {
    try {
      final response = await ApiService.get('/medicines/$medicineId/storage');
      return response;
    } catch (e) {
      throw Exception('Failed to get storage recommendations: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> searchMedicines(String query) async {
    try {
      final response = await ApiService.get('/medicines/search?q=$query');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to search medicines: $e');
    }
  }

  static Future<Map<String, dynamic>> scanBarcode(String barcode) async {
    try {
      final response = await ApiService.get('/medicines/barcode/$barcode');
      return response;
    } catch (e) {
      throw Exception('Failed to scan barcode: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getExpiringMedicines(
    String firstAidKitId,
  ) async {
    try {
      final response = await ApiService.get(
        '/first-aid-kits/$firstAidKitId/medicines/expiring',
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get expiring medicines: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getLowStockMedicines(
    String firstAidKitId,
  ) async {
    try {
      final response = await ApiService.get(
        '/first-aid-kits/$firstAidKitId/medicines/low-stock',
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get low stock medicines: $e');
    }
  }

  static Future<Medicine> getMedicineByBarcode(String barcode) async {
    try {
      final response = await ApiService.get('/medicines/barcode/$barcode');
      return Medicine.fromJson(response);
    } catch (e) {
      throw Exception('Не удалось найти лекарство по штрих-коду: $e');
    }
  }

  // Получение списка лекарств (с realtime обновлениями)
  static Stream<List<Medicine>> getMedicinesStream(String firstAidKitId) {
    return _medicines
        .where('firstAidKitId', isEqualTo: firstAidKitId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Medicine.fromJson({'id': doc.id, ...doc.data()}))
            .toList());
  }

  // Добавление лекарства
  static Future<Medicine> addMedicine(Medicine medicine) async {
    final docRef = await _medicines.add(medicine.toJson());
    return medicine.copyWith(id: docRef.id);
  }

  // Экспорт в PDF (сложная операция - через Cloud Functions)
  static Future<String> exportToPdf(String firstAidKitId) async {
    return ApiService.post('/export/pdf', {'firstAidKitId': firstAidKitId});
  }
} 