import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../backend/models/user_model.dart';
import '../../backend/repositories/auth_repository.dart';

class AppAuthProvider with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  // Публичный доступ к repository для Stream
  AuthRepository get authRepository => _authRepository;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AppAuthProvider() {
    _initializeAuth();
  }

  // Инициализация - слушаем изменения аутентификации
  void _initializeAuth() {
    _authRepository.authStateChanges.listen((User? user) async {
      print('Auth state changed: user = ${user?.uid}'); // Debug
      if (user != null) {
        await _loadUserData();
        print('User loaded: ${_currentUser?.name}'); // Debug
      } else {
        _currentUser = null;
        print('User logged out'); // Debug
        notifyListeners();
      }
    });
  }

  // Загрузить данные текущего пользователя
  Future<void> _loadUserData() async {
    try {
      _currentUser = await _authRepository.getCurrentUserData();
      print('User data loaded in provider: ${_currentUser?.name}'); // Debug
      print('isAuthenticated after load: $isAuthenticated'); // Debug
      notifyListeners(); // КРИТИЧНО: Уведомляем об изменении!
      print('notifyListeners called!'); // Debug
    } catch (e) {
      _errorMessage = e.toString();
      print('Error loading user data: $e'); // Debug
      notifyListeners();
    }
  }

  // Регистрация
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      print('Starting registration for: $email');
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentUser = await _authRepository.register(
        name: name,
        email: email,
        password: password,
      );

      print('Registration successful: ${_currentUser?.name}');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Registration failed: $e');
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Вход
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('Starting sign in for: $email');
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentUser = await _authRepository.signIn(
        email: email,
        password: password,
      );

      print('Sign in successful: ${_currentUser?.name}');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Sign in failed: $e');
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Выход
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authRepository.signOut();
      _currentUser = null;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Удаление аккаунта
  Future<bool> deleteAccount() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authRepository.deleteAccount();
      _currentUser = null;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Обновить имя пользователя
  Future<bool> updateUserName(String name) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authRepository.updateUserName(name);
      await _loadUserData();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Очистить сообщение об ошибке
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}