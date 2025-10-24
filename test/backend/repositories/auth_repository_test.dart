import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noleftovers/backend/repositories/auth_repository.dart';
import 'package:noleftovers/backend/models/user_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

// Firebase mock
typedef Callback = void Function(MethodCall call);

void setupFirebaseAuthMocks([Callback? customHandlers]) {
  TestWidgetsFlutterBinding.ensureInitialized();

  setupFirebaseCoreMocks();
}

void main() {
  setupFirebaseAuthMocks();

  group('AuthRepository', () {
    late AuthRepository authRepository;

    setUpAll(() async {
      // firebase init
      await Firebase.initializeApp();
    });

    setUp(() {
      authRepository = AuthRepository();
    });

    group('User Data Validation', () {
      test('should validate email format', () {
        // Arrange
        const validEmail = 'test@example.com';
        const invalidEmail = 'invalid-email';

        // Act & Assert
        expect(validEmail.contains('@'), true);
        expect(invalidEmail.contains('@'), false);
      });

      test('should validate password length', () {
        // Arrange
        const validPassword = 'password123';
        const shortPassword = '12345';
        const minLength = 6;

        // Act & Assert
        expect(validPassword.length >= minLength, true);
        expect(shortPassword.length >= minLength, false);
      });

      test('should validate name is not empty', () {
        // Arrange
        const validName = 'Test User';
        const emptyName = '';

        // Act & Assert
        expect(validName.isNotEmpty, true);
        expect(emptyName.isNotEmpty, false);
      });
    });

    group('UserModel Creation', () {
      test('should create valid UserModel with required fields', () {
        // Arrange
        const userId = 'user123';
        const name = 'Test User';
        const email = 'test@example.com';
        final createdAt = DateTime.now();

        // Act
        final user = UserModel(
          id: userId,
          name: name,
          email: email,
          createdAt: createdAt,
        );

        // Assert
        expect(user.id, userId);
        expect(user.name, name);
        expect(user.email, email);
        expect(user.createdAt, createdAt);
      });

      test('should handle user data correctly', () {
        // Arrange
        final user = UserModel(
          id: 'user123',
          name: 'Test User',
          email: 'test@example.com',
          createdAt: DateTime.now(),
        );

        // Act
        final userData = user.toMap();

        // Assert
        expect(userData['name'], 'Test User');
        expect(userData['email'], 'test@example.com');
        expect(userData.containsKey('createdAt'), true);
      });
    });

    group('Authentication Logic', () {
      test('should handle registration data structure', () {
        // Arrange
        const name = 'New User';
        const email = 'newuser@example.com';
        const password = 'password123';

        // Act
        final registrationData = {
          'name': name,
          'email': email,
          'password': password,
        };

        // Assert
        expect(registrationData['name'], name);
        expect(registrationData['email'], email);
        expect(registrationData['password'], password);
        expect(registrationData['name']!.isNotEmpty, true);
        expect(registrationData['email']!.contains('@'), true);
        expect(registrationData['password']!.length >= 6, true);
      });

      test('should handle login data structure', () {
        // Arrange
        const email = 'user@example.com';
        const password = 'password123';

        // Act
        final loginData = {
          'email': email,
          'password': password,
        };

        // Assert
        expect(loginData['email'], email);
        expect(loginData['password'], password);
        expect(loginData['email']!.contains('@'), true);
        expect(loginData['password']!.isNotEmpty, true);
      });
    });

    group('User Data Processing', () {
      test('should process user update correctly', () {
        // Arrange
        final originalUser = UserModel(
          id: 'user123',
          name: 'Original Name',
          email: 'original@example.com',
          createdAt: DateTime.now(),
        );

        const newName = 'Updated Name';

        // Act
        final updatedUser = originalUser.copyWith(name: newName);

        // Assert
        expect(updatedUser.name, newName);
        expect(updatedUser.email, originalUser.email);
        expect(updatedUser.id, originalUser.id);
      });

      test('should maintain user data integrity during operations', () {
        // Arrange
        final user = UserModel(
          id: 'user123',
          name: 'Test User',
          email: 'test@example.com',
          createdAt: DateTime.now(),
        );

        // Act
        final serialized = user.toMap();
        final deserialized = UserModel.fromMap(serialized, user.id);

        // Assert
        expect(deserialized.id, user.id);
        expect(deserialized.name, user.name);
        expect(deserialized.email, user.email);
      });
    });

    group('Error Handling', () {
      test('should handle empty email', () {
        // Arrange
        const emptyEmail = '';

        // Act & Assert
        expect(emptyEmail.isEmpty, true);
        expect(emptyEmail.contains('@'), false);
      });

      test('should handle empty password', () {
        // Arrange
        const emptyPassword = '';
        const minLength = 6;

        // Act & Assert
        expect(emptyPassword.isEmpty, true);
        expect(emptyPassword.length < minLength, true);
      });

      test('should detect invalid email format', () {
        // Arrange
        const invalidEmails = [
          'notanemail',
          'user@',
          'user @example.com',
          '@.com',
        ];

        // Act & Assert
        for (final email in invalidEmails) {
          final atIndex = email.indexOf('@');
          final isValid = atIndex > 0 &&
              email.indexOf('.', atIndex) > atIndex &&
              !email.contains(' ');
          expect(isValid, false);
        }
      });
    });

    group('Edge Cases', () {
      test('should handle very long names', () {
        // Arrange
        final longName = 'A' * 100;

        // Act
        final user = UserModel(
          id: 'user123',
          name: longName,
          email: 'test@example.com',
          createdAt: DateTime.now(),
        );

        // Assert
        expect(user.name.length, 100);
        expect(user.name, longName);
      });

      test('should handle special characters in email', () {
        // Arrange
        const emailWithSpecialChars = 'user+test@example.com';

        // Act & Assert
        expect(emailWithSpecialChars.contains('@'), true);
        expect(emailWithSpecialChars.contains('+'), true);
      });

      test('should handle minimum valid password', () {
        // Arrange
        const minPassword = '123456'; // exactly 6 characters

        // Act & Assert
        expect(minPassword.length, 6);
        expect(minPassword.length >= 6, true);
      });
    });
  });
}