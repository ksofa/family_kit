import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/api_service.dart';

class AlertService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Request permission for notifications
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle incoming messages when app is in foreground
    FirebaseMessaging.onMessage.listen(_handleMessage);

    // Handle message when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  static void _handleMessage(RemoteMessage message) {
    // Handle different types of alerts
    switch (message.data['type']) {
      case 'expiry_warning':
        _handleExpiryWarning(message);
        break;
      case 'low_stock_warning':
        _handleLowStockWarning(message);
        break;
    }
  }

  static void _handleMessageOpenedApp(RemoteMessage message) {
    // Navigate to appropriate screen based on alert type
    switch (message.data['type']) {
      case 'expiry_warning':
      case 'low_stock_warning':
        if (message.data['medicine_id'] != null) {
          // Navigate to medicine details screen
          // You'll need to implement the navigation logic
        }
        break;
    }
  }

  static void _handleExpiryWarning(RemoteMessage message) {
    // Show in-app notification or update UI
    // You'll need to implement this based on your UI requirements
  }

  static void _handleLowStockWarning(RemoteMessage message) {
    // Show in-app notification or update UI
    // You'll need to implement this based on your UI requirements
  }

  static Future<void> updateFCMToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await ApiService.post('/users/fcm-token', {'token': token});
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }
} 