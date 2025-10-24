import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:noleftovers/backend/models/offer_model.dart';

void main() {
  group('OfferModel', () {
    final now = DateTime.now();
    final futureDate = now.add(const Duration(hours: 2));
    final pastDate = now.subtract(const Duration(hours: 1));

    test('should create OfferModel with all fields', () {
      // Arrange & Act
      final offer = OfferModel(
        id: 'offer123',
        restaurantId: 'rest123',
        dishName: 'Pizza',
        description: 'Delicious pizza',
        originalPrice: 15.0,
        discountPrice: 5.0,
        availableQuantity: 10,
        photoUrl: 'https://example.com/photo.jpg',
        createdAt: now,
        expiresAt: futureDate,
      );

      // Assert
      expect(offer.id, 'offer123');
      expect(offer.restaurantId, 'rest123');
      expect(offer.dishName, 'Pizza');
      expect(offer.description, 'Delicious pizza');
      expect(offer.originalPrice, 15.0);
      expect(offer.discountPrice, 5.0);
      expect(offer.availableQuantity, 10);
      expect(offer.photoUrl, 'https://example.com/photo.jpg');
      expect(offer.createdAt, now);
      expect(offer.expiresAt, futureDate);
    });

    test('isExpired should return true when expiresAt is in the past', () {
      // Arrange
      final offer = OfferModel(
        id: 'offer123',
        restaurantId: 'rest123',
        dishName: 'Pizza',
        description: 'Delicious pizza',
        originalPrice: 15.0,
        discountPrice: 5.0,
        availableQuantity: 10,
        photoUrl: 'https://example.com/photo.jpg',
        createdAt: now,
        expiresAt: pastDate,
      );

      // Act & Assert
      expect(offer.isExpired, true);
    });

    test('isExpired should return false when expiresAt is in the future', () {
      // Arrange
      final offer = OfferModel(
        id: 'offer123',
        restaurantId: 'rest123',
        dishName: 'Pizza',
        description: 'Delicious pizza',
        originalPrice: 15.0,
        discountPrice: 5.0,
        availableQuantity: 10,
        photoUrl: 'https://example.com/photo.jpg',
        createdAt: now,
        expiresAt: futureDate,
      );

      // Act & Assert
      expect(offer.isExpired, false);
    });

    test('isAvailable should return true when not expired and quantity > 0', () {
      // Arrange
      final offer = OfferModel(
        id: 'offer123',
        restaurantId: 'rest123',
        dishName: 'Pizza',
        description: 'Delicious pizza',
        originalPrice: 15.0,
        discountPrice: 5.0,
        availableQuantity: 5,
        photoUrl: 'https://example.com/photo.jpg',
        createdAt: now,
        expiresAt: futureDate,
      );

      // Act & Assert
      expect(offer.isAvailable, true);
    });

    test('isAvailable should return false when quantity is 0', () {
      // Arrange
      final offer = OfferModel(
        id: 'offer123',
        restaurantId: 'rest123',
        dishName: 'Pizza',
        description: 'Delicious pizza',
        originalPrice: 15.0,
        discountPrice: 5.0,
        availableQuantity: 0,
        photoUrl: 'https://example.com/photo.jpg',
        createdAt: now,
        expiresAt: futureDate,
      );

      // Act & Assert
      expect(offer.isAvailable, false);
    });

    test('isAvailable should return false when offer is expired', () {
      // Arrange
      final offer = OfferModel(
        id: 'offer123',
        restaurantId: 'rest123',
        dishName: 'Pizza',
        description: 'Delicious pizza',
        originalPrice: 15.0,
        discountPrice: 5.0,
        availableQuantity: 5,
        photoUrl: 'https://example.com/photo.jpg',
        createdAt: now,
        expiresAt: pastDate,
      );

      // Act & Assert
      expect(offer.isAvailable, false);
    });

    test('discountPercentage should calculate correctly', () {
      // Arrange
      final offer = OfferModel(
        id: 'offer123',
        restaurantId: 'rest123',
        dishName: 'Pizza',
        description: 'Delicious pizza',
        originalPrice: 20.0,
        discountPrice: 10.0,
        availableQuantity: 5,
        photoUrl: 'https://example.com/photo.jpg',
        createdAt: now,
        expiresAt: futureDate,
      );

      // Act & Assert
      expect(offer.discountPercentage, 50);
    });

    test('discountPercentage should return 0 when originalPrice is 0', () {
      // Arrange
      final offer = OfferModel(
        id: 'offer123',
        restaurantId: 'rest123',
        dishName: 'Pizza',
        description: 'Delicious pizza',
        originalPrice: 0.0,
        discountPrice: 0.0,
        availableQuantity: 5,
        photoUrl: 'https://example.com/photo.jpg',
        createdAt: now,
        expiresAt: futureDate,
      );

      // Act & Assert
      expect(offer.discountPercentage, 0);
    });

    test('discountPercentage should round correctly', () {
      // Arrange
      final offer = OfferModel(
        id: 'offer123',
        restaurantId: 'rest123',
        dishName: 'Pizza',
        description: 'Delicious pizza',
        originalPrice: 15.0,
        discountPrice: 5.0,
        availableQuantity: 5,
        photoUrl: 'https://example.com/photo.jpg',
        createdAt: now,
        expiresAt: futureDate,
      );

      // Act & Assert
      // (15 - 5) / 15 * 100 = 66.666... should round to 67
      expect(offer.discountPercentage, 67);
    });

    test('should convert OfferModel to Map correctly', () {
      // Arrange
      final offer = OfferModel(
        id: 'offer123',
        restaurantId: 'rest123',
        dishName: 'Pizza',
        description: 'Delicious pizza',
        originalPrice: 15.0,
        discountPrice: 5.0,
        availableQuantity: 10,
        photoUrl: 'https://example.com/photo.jpg',
        createdAt: now,
        expiresAt: futureDate,
      );

      // Act
      final map = offer.toMap();

      // Assert
      expect(map['restaurantId'], 'rest123');
      expect(map['dishName'], 'Pizza');
      expect(map['description'], 'Delicious pizza');
      expect(map['originalPrice'], 15.0);
      expect(map['discountPrice'], 5.0);
      expect(map['availableQuantity'], 10);
      expect(map['photoUrl'], 'https://example.com/photo.jpg');
      expect(map['createdAt'], isA<Timestamp>());
      expect(map['expiresAt'], isA<Timestamp>());
    });

    test('should create OfferModel from Map correctly', () {
      // Arrange
      final map = {
        'restaurantId': 'rest123',
        'dishName': 'Pizza',
        'description': 'Delicious pizza',
        'originalPrice': 15.0,
        'discountPrice': 5.0,
        'availableQuantity': 10,
        'photoUrl': 'https://example.com/photo.jpg',
        'createdAt': Timestamp.fromDate(now),
        'expiresAt': Timestamp.fromDate(futureDate),
      };

      // Act
      final offer = OfferModel.fromMap(map, 'offer123');

      // Assert
      expect(offer.id, 'offer123');
      expect(offer.restaurantId, 'rest123');
      expect(offer.dishName, 'Pizza');
      expect(offer.availableQuantity, 10);
    });

    test('copyWith should update specified fields only', () {
      // Arrange
      final offer = OfferModel(
        id: 'offer123',
        restaurantId: 'rest123',
        dishName: 'Pizza',
        description: 'Delicious pizza',
        originalPrice: 15.0,
        discountPrice: 5.0,
        availableQuantity: 10,
        photoUrl: 'https://example.com/photo.jpg',
        createdAt: now,
        expiresAt: futureDate,
      );

      // Act
      final updated = offer.copyWith(availableQuantity: 5);

      // Assert
      expect(updated.availableQuantity, 5);
      expect(updated.dishName, 'Pizza');
      expect(updated.originalPrice, 15.0);
    });
  });
}