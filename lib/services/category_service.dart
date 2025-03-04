import '../models/category.dart';
import 'api_service.dart';

class CategoryService {
  static Future<List<Category>> getPresetCategories() async {
    try {
      final response = await ApiService.get('/categories/presets');
      return (response as List)
          .map((json) => Category.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get preset categories: $e');
    }
  }

  static Future<Category> createCustomCategory(Category category) async {
    try {
      final response = await ApiService.post(
        '/categories/custom',
        category.toJson(),
      );
      return Category.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create custom category: $e');
    }
  }

  static Future<List<Category>> getCustomCategories() async {
    try {
      final response = await ApiService.get('/categories/custom');
      return (response as List)
          .map((json) => Category.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get custom categories: $e');
    }
  }

  static Future<void> deleteCustomCategory(String categoryId) async {
    try {
      await ApiService.delete('/categories/custom/$categoryId');
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }
} 