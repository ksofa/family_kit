import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: "AIzaSyDeKvFaRds3fQcoEm1RDwsH5GZ7CY0mf0U",
        authDomain: "fluttermet.firebaseapp.com",
        projectId: "fluttermet",
        storageBucket: "fluttermet.appspot.com",
        messagingSenderId: "996585139099",
        appId: "1:996585139099:web:ad7c87ecad572a1952cf3e",
        measurementId: "G-JZDGFTGEXZ"
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey: "AIzaSyDeKvFaRds3fQcoEm1RDwsH5GZ7CY0mf0U",
          appId: "1:996585139099:android:ad7c87ecad572a1952cf3e",
          messagingSenderId: "996585139099",
          projectId: "fluttermet",
          storageBucket: "fluttermet.appspot.com",
        );
      case TargetPlatform.iOS:
        return const FirebaseOptions(
          apiKey: "AIzaSyDeKvFaRds3fQcoEm1RDwsH5GZ7CY0mf0U",
          appId: "1:996585139099:ios:ad7c87ecad572a1952cf3e",
          messagingSenderId: "996585139099",
          projectId: "fluttermet",
          storageBucket: "fluttermet.appspot.com",
          iosClientId: "YOUR_IOS_CLIENT_ID", // Нужно добавить при необходимости
          iosBundleId: "YOUR_IOS_BUNDLE_ID", // Нужно добавить при необходимости
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
} 