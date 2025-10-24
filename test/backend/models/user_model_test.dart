import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:noleftovers/backend/models/user_model.dart';

void main() {
  group('UserModel', () {
    final testDate = DateTime(2025, 1, 20, 10, 0, 0);

    test('should create UserModel with all fields', () {
      // Arrange & Act
      final user = UserModel(
        id: 'user123',
        name: 'Test User',
        email: 'test@example.com',
        createdAt: testDate,
      );

      // Assert
      expect(user.id, 'user123');
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.createdAt, testDate);
    });

    test('should convert UserModel to Map correctly', () {
      // Arrange
      final user = UserModel(
        id: 'user123',
        name: 'Test User',
        email: 'test@example.com',
        createdAt: testDate,
      );

      // Act
      final map = user.toMap();

      // Assert
      expect(map['name'], 'Test User');
      expect(map['email'], 'test@example.com');
      expect(map['createdAt'], isA<Timestamp>());
      expect((map['createdAt'] as Timestamp).toDate(), testDate);
    });

    test('should create UserModel from Map correctly', () {
      // Arrange
      final map = {
        'name': 'Test User',
        'email': 'test@example.com',
        'createdAt': Timestamp.fromDate(testDate),
      };

      // Act
      final user = UserModel.fromMap(map, 'user123');

      // Assert
      expect(user.id, 'user123');
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.createdAt, testDate);
    });

    test('should handle empty name in fromMap', () {
      // Arrange
      final map = {
        'name': '',
        'email': 'test@example.com',
        'createdAt': Timestamp.fromDate(testDate),
      };

      // Act
      final user = UserModel.fromMap(map, 'user123');

      // Assert
      expect(user.name, '');
    });

    test('should create copy of UserModel with updated fields', () {
      // Arrange
      final user = UserModel(
        id: 'user123',
        name: 'Test User',
        email: 'test@example.com',
        createdAt: testDate,
      );

      // Act
      final updatedUser = user.copyWith(name: 'Updated Name');

      // Assert
      expect(updatedUser.id, 'user123');
      expect(updatedUser.name, 'Updated Name');
      expect(updatedUser.email, 'test@example.com');
      expect(updatedUser.createdAt, testDate);
    });

    test('copyWith should keep original values if not specified', () {
      // Arrange
      final user = UserModel(
        id: 'user123',
        name: 'Test User',
        email: 'test@example.com',
        createdAt: testDate,
      );

      // Act
      final copiedUser = user.copyWith();

      // Assert
      expect(copiedUser.id, user.id);
      expect(copiedUser.name, user.name);
      expect(copiedUser.email, user.email);
      expect(copiedUser.createdAt, user.createdAt);
    });
  });
}