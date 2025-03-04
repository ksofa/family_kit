import 'package:shared_preferences.dart';
import '../models/notification_settings.dart';

class SettingsService {
  static const _notificationSettingsKey = 'notification_settings';
  static final _prefs = SharedPreferences.getInstance();

  static Future<NotificationSettings> getNotificationSettings() async {
    try {
      final prefs = await _prefs;
      final json = prefs.getString(_notificationSettingsKey);
      if (json != null) {
        return NotificationSettings.fromJson(
          Map<String, dynamic>.from(jsonDecode(json)),
        );
      }
      return NotificationSettings(); // Return default settings
    } catch (e) {
      print('Error loading notification settings: $e');
      return NotificationSettings(); // Return default settings on error
    }
  }

  static Future<void> saveNotificationSettings(
    NotificationSettings settings,
  ) async {
    try {
      final prefs = await _prefs;
      await prefs.setString(
        _notificationSettingsKey,
        jsonEncode(settings.toJson()),
      );

      // Update server settings
      await ApiService.patch(
        '/users/notification-settings',
        settings.toJson(),
      );
    } catch (e) {
      print('Error saving notification settings: $e');
      rethrow;
    }
  }

  static Future<void> clearSettings() async {
    try {
      final prefs = await _prefs;
      await prefs.clear();
    } catch (e) {
      print('Error clearing settings: $e');
      rethrow;
    }
  }
} 