import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

  // Получить текущего пользователя
  static User? get currentUser => _auth.currentUser;

  // Регистрация по email
  static Future<UserCredential> registerWithEmail(
    String email,
    String password,
    String name,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Создаем профиль пользователя в Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Обновляем displayName пользователя
      await userCredential.user!.updateDisplayName(name);

      return userCredential;
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  // Вход по email
  static Future<UserCredential> loginWithEmail(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  // Выход
  static Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }

  // Сброс пароля
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send reset email: $e');
    }
  }

  // Проверка авторизации
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
} 