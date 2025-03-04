import '../services/api_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'first_aid_kit_service.dart';

class SharingService {
  static Future<String> generateAccessCode(String kitId, String role) async {
    try {
      final response = await ApiService.post(
        '/first-aid-kits/$kitId/access-code',
        {'role': role},
      );
      return response['access_code'];
    } catch (e) {
      throw Exception('Failed to generate access code: $e');
    }
  }

  static Future<void> joinFirstAidKit(String accessCode) async {
    try {
      await ApiService.post(
        '/first-aid-kits/join/$accessCode',
        {},
      );
    } catch (e) {
      throw Exception('Failed to join first aid kit: $e');
    }
  }

  static Future<void> removeUser(String kitId, String userId) async {
    try {
      await ApiService.delete(
        '/first-aid-kits/$kitId/users/$userId',
      );
    } catch (e) {
      throw Exception('Failed to remove user: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getFirstAidKitUsers(String kitId) async {
    try {
      final response = await ApiService.get('/first-aid-kits/$kitId/users');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  static Future<void> updateUserRole(
    String kitId,
    String userId,
    String newRole,
  ) async {
    try {
      await ApiService.patch(
        '/first-aid-kits/$kitId/users/$userId',
        {'role': newRole},
      );
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  static Future<Map<String, dynamic>> getFirstAidKitDetails(String kitId) async {
    try {
      final response = await ApiService.get('/first-aid-kits/$kitId');
      return response;
    } catch (e) {
      throw Exception('Failed to get first aid kit details: $e');
    }
  }

  static Future<bool> checkUserAccess(String kitId) async {
    try {
      final response = await ApiService.get('/first-aid-kits/$kitId/access');
      return response['has_access'] ?? false;
    } catch (e) {
      throw Exception('Failed to check access: $e');
    }
  }

  static Future<String> getUserRole(String kitId) async {
    try {
      final response = await ApiService.get('/first-aid-kits/$kitId/role');
      return response['role'];
    } catch (e) {
      throw Exception('Failed to get user role: $e');
    }
  }

  static Future<bool> canManageUsers(String kitId) async {
    try {
      final role = await getUserRole(kitId);
      return role == 'administrator';
    } catch (e) {
      return false;
    }
  }

  static Future<bool> canEditMedicines(String kitId) async {
    try {
      final role = await getUserRole(kitId);
      return role == 'administrator' || role == 'editor';
    } catch (e) {
      return false;
    }
  }

  static Future<String> generateSharingCode(String firstAidKitId) async {
    try {
      final response = await ApiService.post(
        '/first-aid-kits/$firstAidKitId/share',
        {},
      );
      return response['access_code'];
    } catch (e) {
      throw Exception('Failed to generate sharing code: $e');
    }
  }

  static Future<void> shareFirstAidKit(String firstAidKitId, String kitName) async {
    try {
      final accessCode = await generateSharingCode(firstAidKitId);
      
      await Share.share(
        'Join my first aid kit "$kitName" using this access code: $accessCode',
        subject: 'Join First Aid Kit',
      );
    } catch (e) {
      throw Exception('Failed to share first aid kit: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getSharedUsers(
    String firstAidKitId,
  ) async {
    try {
      final response = await ApiService.get(
        '/first-aid-kits/$firstAidKitId/shared-users',
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get shared users: $e');
    }
  }

  static Future<void> removeSharedUser(
    String firstAidKitId,
    String userId,
  ) async {
    try {
      await ApiService.delete(
        '/first-aid-kits/$firstAidKitId/shared-users/$userId',
      );
    } catch (e) {
      throw Exception('Failed to remove shared user: $e');
    }
  }

  static Future<void> shareFirstAidKitFirestore(
    String kitId,
    String userEmail,
    String role,
  ) async {
    await FirstAidKitService.shareKit(kitId, userEmail, role);
  }

  static Future<List<Map<String, dynamic>>> getKitUsers(String kitId) async {
    final doc = await FirebaseFirestore.instance
        .collection('first_aid_kits')
        .doc(kitId)
        .get();

    if (!doc.exists) throw Exception('First aid kit not found');

    final users = doc.data()!['users'] as Map<String, dynamic>;
    final usersList = await Future.wait(
      users.entries.map((entry) async {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(entry.key)
            .get();
        
        return {
          'id': entry.key,
          'role': entry.value,
          ...userDoc.data() ?? {},
        };
      }),
    );

    return usersList;
  }

  static Future<void> removeUserAccess(String kitId, String userId) async {
    await FirebaseFirestore.instance
        .collection('first_aid_kits')
        .doc(kitId)
        .update({
      'users.$userId': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
} 