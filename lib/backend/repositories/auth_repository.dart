import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/firestore_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();

  // Получить текущего пользователя
  User? get currentUser => _authService.currentUser;

  // Stream изменений аутентификации (публичный для StreamBuilder)
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  // Регистрация
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Создаём пользователя в Firebase Auth
      final credential = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Failed to create user');
      }

      // Создаём модель пользователя
      final userModel = UserModel(
        id: user.uid,
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );

      // Сохраняем данные пользователя в Firestore
      await _firestoreService.createUser(
        userId: user.uid,
        userData: userModel.toMap(),
      );

      return userModel;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Вход
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Входим через Firebase Auth
      final credential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Failed to sign in');
      }

      // Получаем данные пользователя из Firestore
      final userDoc = await _firestoreService.getUser(user.uid);

      if (!userDoc.exists) {
        throw Exception('User data not found');
      }

      return UserModel.fromMap(
        userDoc.data() as Map<String, dynamic>,
        user.uid,
      );
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // Выход
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Удаление аккаунта
  Future<void> deleteAccount() async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      // Удаляем данные из Firestore
      await _firestoreService.deleteUser(userId);

      // Удаляем аккаунт из Firebase Auth
      await _authService.deleteAccount();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  // Получить данные текущего пользователя
  Future<UserModel?> getCurrentUserData() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return null;

      final userDoc = await _firestoreService.getUser(user.uid);

      if (!userDoc.exists) return null;

      return UserModel.fromMap(
        userDoc.data() as Map<String, dynamic>,
        user.uid,
      );
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // Обновить имя пользователя
  Future<void> updateUserName(String name) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      await _firestoreService.updateUser(
        userId: userId,
        updates: {'name': name},
      );
    } catch (e) {
      throw Exception('Failed to update name: $e');
    }
  }
}