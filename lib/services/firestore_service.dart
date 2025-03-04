import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final _firestore = FirebaseFirestore.instance;

  // Коллекции
  static final firstAidKits = _firestore.collection('first_aid_kits');
  static final medicines = _firestore.collection('medicines');
  static final users = _firestore.collection('users');
  
  // Правила безопасности для Firestore
  /* 
  rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {
      match /first_aid_kits/{kitId} {
        allow read: if request.auth != null && 
          (resource.data.users[request.auth.uid] != null);
        allow write: if request.auth != null && 
          (resource.data.users[request.auth.uid] == 'owner' ||
           resource.data.users[request.auth.uid] == 'editor');
      }
      
      match /medicines/{medicineId} {
        allow read: if request.auth != null;
        allow write: if request.auth != null;
      }
      
      match /users/{userId} {
        allow read, write: if request.auth != null && 
          request.auth.uid == userId;
      }
    }
  }
  */
} 