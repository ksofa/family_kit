import '../services/api_service.dart';
import '../models/reminder.dart';

class ReminderService {
  static Future<Reminder> createReminder({
    required String medicineId,
    required DateTime time,
    required String frequency,
    required int durationDays,
    String? notes,
  }) async {
    try {
      final response = await ApiService.post(
        '/medicines/$medicineId/reminders',
        {
          'time': time.toIso8601String(),
          'frequency': frequency,
          'duration_days': durationDays,
          'notes': notes,
        },
      );
      return Reminder.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create reminder: $e');
    }
  }

  static Future<List<Reminder>> getUserReminders() async {
    try {
      final response = await ApiService.get('/medicines/reminders/user/me');
      return (response as List)
          .map((json) => Reminder.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get reminders: $e');
    }
  }

  static Future<Reminder> updateReminder(
    String reminderId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await ApiService.patch(
        '/medicines/reminders/$reminderId',
        updates,
      );
      return Reminder.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update reminder: $e');
    }
  }

  static Future<void> deleteReminder(String reminderId) async {
    try {
      await ApiService.delete('/medicines/reminders/$reminderId');
    } catch (e) {
      throw Exception('Failed to delete reminder: $e');
    }
  }

  // Helper methods for reminder frequency
  static List<String> getFrequencyOptions() {
    return [
      'Once daily',
      'Twice daily',
      'Three times daily',
      'Every 4 hours',
      'Every 6 hours',
      'Every 8 hours',
      'Every 12 hours',
      'Weekly',
      'As needed'
    ];
  }

  static String getFrequencyDescription(String frequency) {
    final descriptions = {
      'Once daily': 'Take once per day',
      'Twice daily': 'Take twice per day',
      'Three times daily': 'Take three times per day',
      'Every 4 hours': 'Take every 4 hours',
      'Every 6 hours': 'Take every 6 hours',
      'Every 8 hours': 'Take every 8 hours',
      'Every 12 hours': 'Take every 12 hours',
      'Weekly': 'Take once per week',
      'As needed': 'Take as needed'
    };
    return descriptions[frequency] ?? frequency;
  }
} 