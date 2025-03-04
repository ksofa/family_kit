import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/first_aid_kit.dart';
import 'auth_service.dart';

class FirstAidKitService {
  static final _kits = FirebaseFirestore.instance.collection('first_aid_kits');

  // Получение списка аптечек пользователя с realtime обновлениями
  static Stream<List<FirstAidKit>> getUserKitsStream() {
    final userId = AuthService.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _kits
        .where('users.$userId', whereIn: ['owner', 'editor', 'viewer'])
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FirstAidKit.fromJson({'id': doc.id, ...doc.data()}))
            .toList());
  }

  // Создание новой аптечки
  static Future<FirstAidKit> createKit(String name, String description) async {
    final userId = AuthService.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final kitData = {
      'name': name,
      'description': description,
      'users': {userId: 'owner'},
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final docRef = await _kits.add(kitData);
    final doc = await docRef.get();
    
    return FirstAidKit.fromJson({'id': doc.id, ...doc.data()!});
  }

  // Обновление аптечки
  static Future<void> updateKit(String kitId, Map<String, dynamic> updates) async {
    await _kits.doc(kitId).update({
      ...updates,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Удаление аптечки
  static Future<void> deleteKit(String kitId) async {
    // Сначала удаляем все лекарства в этой аптечке
    final medicines = await FirebaseFirestore.instance
        .collection('medicines')
        .where('firstAidKitId', isEqualTo: kitId)
        .get();

    final batch = FirebaseFirestore.instance.batch();
    for (var doc in medicines.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_kits.doc(kitId));
    
    await batch.commit();
  }

  // Предоставление доступа к аптечке
  static Future<void> shareKit(String kitId, String userEmail, String role) async {
    // Найти пользователя по email
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .limit(1)
        .get();

    if (userSnapshot.docs.isEmpty) {
      throw Exception('User not found');
    }

    final userId = userSnapshot.docs.first.id;
    await _kits.doc(kitId).update({
      'users.$userId': role,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Получение статистики по аптечке
  static Stream<Map<String, dynamic>> getKitStats(String kitId) {
    return _kits.doc(kitId).snapshots().map((doc) {
      final data = doc.data()!;
      return {
        'totalMedicines': data['medicineCount'] ?? 0,
        'expiringCount': data['expiringCount'] ?? 0,
        'lowStockCount': data['lowStockCount'] ?? 0,
      };
    });
  }
} 