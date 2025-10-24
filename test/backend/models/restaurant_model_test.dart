import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:noleftovers/backend/models/restaurant_model.dart';

void main() {
  group('RestaurantModel', () {
    final testDate = DateTime(2025, 1, 20, 10, 0, 0);
    final openingHours = {
      'Monday': '9:00-22:00',
      'Tuesday': '9:00-22:00',
      'Wednesday': '9:00-22:00',
      'Thursday': '9:00-22:00',
      'Friday': '9:00-23:00',
      'Saturday': '10:00-23:00',
      'Sunday': '10:00-21:00',
    };

    test('should create RestaurantModel with all fields', () {
      // Arrange & Act
      final restaurant = RestaurantModel(
        id: 'rest123',
        name: 'Test Restaurant',
        description: 'A great place to eat',
        address: 'Viru väljak 4, Tallinn',
        latitude: 59.437,
        longitude: 24.7536,
        photoUrl: 'https://example.com/photo.jpg',
        openingHours: openingHours,
        createdAt: testDate,
      );

      // Assert
      expect(restaurant.id, 'rest123');
      expect(restaurant.name, 'Test Restaurant');
      expect(restaurant.description, 'A great place to eat');
      expect(restaurant.address, 'Viru väljak 4, Tallinn');
      expect(restaurant.latitude, 59.437);
      expect(restaurant.longitude, 24.7536);
      expect(restaurant.photoUrl, 'https://example.com/photo.jpg');
      expect(restaurant.openingHours, openingHours);
      expect(restaurant.createdAt, testDate);
    });

    test('should handle valid coordinates', () {
      // Arrange & Act
      final restaurant = RestaurantModel(
        id: 'rest123',
        name: 'Test Restaurant',
        description: 'A great place to eat',
        address: 'Viru väljak 4, Tallinn',
        latitude: 59.437,
        longitude: 24.7536,
        photoUrl: 'https://example.com/photo.jpg',
        openingHours: openingHours,
        createdAt: testDate,
      );

      // Assert
      expect(restaurant.latitude, greaterThan(0));
      expect(restaurant.longitude, greaterThan(0));
      expect(restaurant.latitude, lessThan(90));
      expect(restaurant.longitude, lessThan(180));
    });

    test('should handle negative coordinates', () {
      // Arrange & Act
      final restaurant = RestaurantModel(
        id: 'rest123',
        name: 'Test Restaurant',
        description: 'A great place to eat',
        address: 'Some address',
        latitude: -34.0,
        longitude: -58.0,
        photoUrl: 'https://example.com/photo.jpg',
        openingHours: openingHours,
        createdAt: testDate,
      );

      // Assert
      expect(restaurant.latitude, -34.0);
      expect(restaurant.longitude, -58.0);
    });

    test('should convert RestaurantModel to Map correctly', () {
      // Arrange
      final restaurant = RestaurantModel(
        id: 'rest123',
        name: 'Test Restaurant',
        description: 'A great place to eat',
        address: 'Viru väljak 4, Tallinn',
        latitude: 59.437,
        longitude: 24.7536,
        photoUrl: 'https://example.com/photo.jpg',
        openingHours: openingHours,
        createdAt: testDate,
      );

      // Act
      final map = restaurant.toMap();

      // Assert
      expect(map['name'], 'Test Restaurant');
      expect(map['description'], 'A great place to eat');
      expect(map['address'], 'Viru väljak 4, Tallinn');
      expect(map['latitude'], 59.437);
      expect(map['longitude'], 24.7536);
      expect(map['photoUrl'], 'https://example.com/photo.jpg');
      expect(map['openingHours'], openingHours);
      expect(map['createdAt'], isA<Timestamp>());
      expect((map['createdAt'] as Timestamp).toDate(), testDate);
    });

    test('should create RestaurantModel from Map correctly', () {
      // Arrange
      final map = {
        'name': 'Test Restaurant',
        'description': 'A great place to eat',
        'address': 'Viru väljak 4, Tallinn',
        'latitude': 59.437,
        'longitude': 24.7536,
        'photoUrl': 'https://example.com/photo.jpg',
        'openingHours': openingHours,
        'createdAt': Timestamp.fromDate(testDate),
      };

      // Act
      final restaurant = RestaurantModel.fromMap(map, 'rest123');

      // Assert
      expect(restaurant.id, 'rest123');
      expect(restaurant.name, 'Test Restaurant');
      expect(restaurant.description, 'A great place to eat');
      expect(restaurant.address, 'Viru väljak 4, Tallinn');
      expect(restaurant.latitude, 59.437);
      expect(restaurant.longitude, 24.7536);
      expect(restaurant.photoUrl, 'https://example.com/photo.jpg');
      expect(restaurant.openingHours, openingHours);
      expect(restaurant.createdAt, testDate);
    });

    test('should handle empty strings in fromMap', () {
      // Arrange
      final map = {
        'name': '',
        'description': '',
        'address': '',
        'latitude': 0.0,
        'longitude': 0.0,
        'photoUrl': '',
        'openingHours': <String, String>{},
        'createdAt': Timestamp.fromDate(testDate),
      };

      // Act
      final restaurant = RestaurantModel.fromMap(map, 'rest123');

      // Assert
      expect(restaurant.name, '');
      expect(restaurant.description, '');
      expect(restaurant.address, '');
      expect(restaurant.photoUrl, '');
      expect(restaurant.openingHours, isEmpty);
    });

    test('should handle integer coordinates in fromMap', () {
      // Arrange
      final map = {
        'name': 'Test Restaurant',
        'description': 'A great place to eat',
        'address': 'Viru väljak 4, Tallinn',
        'latitude': 59, // integer instead of double
        'longitude': 24, // integer instead of double
        'photoUrl': 'https://example.com/photo.jpg',
        'openingHours': openingHours,
        'createdAt': Timestamp.fromDate(testDate),
      };

      // Act
      final restaurant = RestaurantModel.fromMap(map, 'rest123');

      // Assert
      expect(restaurant.latitude, 59.0);
      expect(restaurant.longitude, 24.0);
    });

    test('should preserve openingHours structure', () {
      // Arrange
      final restaurant = RestaurantModel(
        id: 'rest123',
        name: 'Test Restaurant',
        description: 'A great place to eat',
        address: 'Viru väljak 4, Tallinn',
        latitude: 59.437,
        longitude: 24.7536,
        photoUrl: 'https://example.com/photo.jpg',
        openingHours: openingHours,
        createdAt: testDate,
      );

      // Act
      final map = restaurant.toMap();
      final restored = RestaurantModel.fromMap(map, 'rest123');

      // Assert
      expect(restored.openingHours['Monday'], '9:00-22:00');
      expect(restored.openingHours['Friday'], '9:00-23:00');
      expect(restored.openingHours['Sunday'], '10:00-21:00');
      expect(restored.openingHours.length, 7);
    });

    test('copyWith should update name correctly', () {
      // Arrange
      final restaurant = RestaurantModel(
        id: 'rest123',
        name: 'Test Restaurant',
        description: 'A great place to eat',
        address: 'Viru väljak 4, Tallinn',
        latitude: 59.437,
        longitude: 24.7536,
        photoUrl: 'https://example.com/photo.jpg',
        openingHours: openingHours,
        createdAt: testDate,
      );

      // Act
      final updated = restaurant.copyWith(name: 'Updated Restaurant');

      // Assert
      expect(updated.name, 'Updated Restaurant');
      expect(updated.id, 'rest123');
      expect(updated.description, 'A great place to eat');
    });

    test('copyWith should update coordinates correctly', () {
      // Arrange
      final restaurant = RestaurantModel(
        id: 'rest123',
        name: 'Test Restaurant',
        description: 'A great place to eat',
        address: 'Viru väljak 4, Tallinn',
        latitude: 59.437,
        longitude: 24.7536,
        photoUrl: 'https://example.com/photo.jpg',
        openingHours: openingHours,
        createdAt: testDate,
      );

      // Act
      final updated = restaurant.copyWith(
        latitude: 60.0,
        longitude: 25.0,
      );

      // Assert
      expect(updated.latitude, 60.0);
      expect(updated.longitude, 25.0);
      expect(updated.name, 'Test Restaurant');
    });

    test('copyWith should update openingHours correctly', () {
      // Arrange
      final restaurant = RestaurantModel(
        id: 'rest123',
        name: 'Test Restaurant',
        description: 'A great place to eat',
        address: 'Viru väljak 4, Tallinn',
        latitude: 59.437,
        longitude: 24.7536,
        photoUrl: 'https://example.com/photo.jpg',
        openingHours: openingHours,
        createdAt: testDate,
      );

      final newHours = {'Monday': '10:00-20:00'};

      // Act
      final updated = restaurant.copyWith(openingHours: newHours);

      // Assert
      expect(updated.openingHours, newHours);
      expect(updated.openingHours.length, 1);
      expect(updated.name, 'Test Restaurant');
    });

    test('copyWith should keep original values if not specified', () {
      // Arrange
      final restaurant = RestaurantModel(
        id: 'rest123',
        name: 'Test Restaurant',
        description: 'A great place to eat',
        address: 'Viru väljak 4, Tallinn',
        latitude: 59.437,
        longitude: 24.7536,
        photoUrl: 'https://example.com/photo.jpg',
        openingHours: openingHours,
        createdAt: testDate,
      );

      // Act
      final copied = restaurant.copyWith();

      // Assert
      expect(copied.id, restaurant.id);
      expect(copied.name, restaurant.name);
      expect(copied.description, restaurant.description);
      expect(copied.address, restaurant.address);
      expect(copied.latitude, restaurant.latitude);
      expect(copied.longitude, restaurant.longitude);
      expect(copied.photoUrl, restaurant.photoUrl);
      expect(copied.openingHours, restaurant.openingHours);
      expect(copied.createdAt, restaurant.createdAt);
    });
  });
}