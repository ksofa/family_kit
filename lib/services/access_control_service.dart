import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_role.dart';
import 'api_service.dart';

class AccessControlService {
  static Future<UserRole> getUserRole(String firstAidKitId) async {
    try {
      final response = await ApiService.get('/first-aid-kits/$firstAidKitId/role');
      return UserRole.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get user role: $e');
    }
  }

  static Future<void> updateUserRole(
    String firstAidKitId,
    String userId,
    String role,
  ) async {
    try {
      await ApiService.patch(
        '/first-aid-kits/$firstAidKitId/users/$userId',
        {'role': role},
      );
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getAuditLog(
    String firstAidKitId,
  ) async {
    try {
      final response = await ApiService.get(
        '/first-aid-kits/$firstAidKitId/audit-log',
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get audit log: $e');
    }
  }

  static Future<void> enableTwoFactor() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await ApiService.post('/users/2fa/enable', {});
    } catch (e) {
      throw Exception('Failed to enable 2FA: $e');
    }
  }

  static Future<void> verifyTwoFactor(String code) async {
    try {
      await ApiService.post('/users/2fa/verify', {'code': code});
    } catch (e) {
      throw Exception('Failed to verify 2FA: $e');
    }
  }

  static Future<void> logAction(
    String firstAidKitId,
    String action,
    Map<String, dynamic> details,
  ) async {
    try {
      await ApiService.post(
        '/first-aid-kits/$firstAidKitId/audit-log',
        {
          'action': action,
          'details': details,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Логируем локально в случае ошибки
      print('Failed to log action: $e');
    }
  }
} 