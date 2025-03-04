import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/medicine.dart';

class NotificationManager {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  static Future<void> init() async {
    tz.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('app_icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  static Future<void> _onNotificationTap(NotificationResponse response) async {
    // Обработка нажатия на уведомление
  }

  // Напоминание о приеме лекарства
  static Future<void> scheduleMedicineReminder({
    required String medicineId,
    required String medicineName,
    required DateTime time,
    required double quantity,
    required String unit,
  }) async {
    final id = medicineId.hashCode;
    
    await _notifications.zonedSchedule(
      id,
      'Время принять лекарство',
      'Примите $medicineName: $quantity $unit',
      tz.TZDateTime.from(time, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'medicine_reminders',
          'Напоминания о приеме',
          channelDescription: 'Напоминания о времени приема лекарств',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default.wav',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Уведомление об истечении срока годности
  static Future<void> scheduleExpirationAlert(Medicine medicine) async {
    final id = '${medicine.id}_expiration'.hashCode;
    final alertDate = medicine.expirationDate.subtract(Duration(days: 30));
    
    if (alertDate.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      id,
      'Срок годности истекает',
      'У ${medicine.name} истекает срок годности через 30 дней',
      tz.TZDateTime.from(alertDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'expiration_alerts',
          'Срок годности',
          channelDescription: 'Уведомления об истечении срока годности',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default.wav',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Уведомление о низком количестве
  static Future<void> showLowStockAlert({
    required String medicineId,
    required String medicineName,
    required double quantity,
    required String unit,
  }) async {
    final id = '${medicineId}_stock'.hashCode;

    await _notifications.show(
      id,
      'Заканчивается лекарство',
      'Осталось мало $medicineName: $quantity $unit',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'low_stock_alerts',
          'Низкий запас',
          channelDescription: 'Уведомления о низком количестве лекарств',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default.wav',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // Отмена напоминаний для конкретного лекарства
  static Future<void> cancelMedicineReminders(String medicineId) async {
    await _notifications.cancel(medicineId.hashCode);
  }

  // Отмена всех напоминаний
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
} 