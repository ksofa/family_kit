import 'dart:convert';
import 'package:shared_preferences.dart';
import '../models/medicine.dart';
import '../models/first_aid_kit.dart';

class CacheService {
  static const String _medicinesKey = 'cached_medicines_';
  static const String _firstAidKitKey = 'cached_first_aid_kit_';
  static const Duration _cacheExpiration = Duration(minutes: 30);

  static Future<void> cacheMedicines(
    String firstAidKitId,
    List<Medicine> medicines,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'timestamp': DateTime.now().toIso8601String(),
      'medicines': medicines.map((m) => m.toJson()).toList(),
    };
    await prefs.setString(
      _medicinesKey + firstAidKitId,
      jsonEncode(data),
    );
  }

  static Future<List<Medicine>?> getCachedMedicines(String firstAidKitId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_medicinesKey + firstAidKitId);
      
      if (cached == null) return null;

      final data = jsonDecode(cached);
      final timestamp = DateTime.parse(data['timestamp']);
      
      if (DateTime.now().difference(timestamp) > _cacheExpiration) {
        await prefs.remove(_medicinesKey + firstAidKitId);
        return null;
      }

      return (data['medicines'] as List)
          .map((json) => Medicine.fromJson(json))
          .toList();
    } catch (e) {
      print('Cache error: $e');
      return null;
    }
  }

  static Future<void> cacheFirstAidKit(FirstAidKit firstAidKit) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'timestamp': DateTime.now().toIso8601String(),
      'first_aid_kit': firstAidKit.toJson(),
    };
    await prefs.setString(
      _firstAidKitKey + firstAidKit.id,
      jsonEncode(data),
    );
  }

  static Future<FirstAidKit?> getCachedFirstAidKit(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_firstAidKitKey + id);
      
      if (cached == null) return null;

      final data = jsonDecode(cached);
      final timestamp = DateTime.parse(data['timestamp']);
      
      if (DateTime.now().difference(timestamp) > _cacheExpiration) {
        await prefs.remove(_firstAidKitKey + id);
        return null;
      }

      return FirstAidKit.fromJson(data['first_aid_kit']);
    } catch (e) {
      print('Cache error: $e');
      return null;
    }
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_medicinesKey) || key.startsWith(_firstAidKitKey)) {
        await prefs.remove(key);
      }
    }
  }

  static Future<void> invalidateFirstAidKitCache(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_firstAidKitKey + id);
    await prefs.remove(_medicinesKey + id);
  }
} 