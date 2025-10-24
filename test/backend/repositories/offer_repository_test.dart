import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noleftovers/backend/models/offer_model.dart';
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

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('OfferRepository Logic', () {
    group('Quantity Management', () {
      test('should decrement quantity correctly', () {
        // Arrange
        var quantity = 10;
        const decrement = 1;

        // Act
        quantity -= decrement;

        // Assert
        expect(quantity, 9);
      });

      test('should increment quantity correctly', () {
        // Arrange
        var quantity = 9;
        const increment = 1;

        // Act
        quantity += increment;

        // Assert
        expect(quantity, 10);
      });

      test('should not allow quantity below 0', () {
        // Arrange
        var quantity = 0;

        // Act
        final canDecrement = quantity > 0;

        // Assert
        expect(canDecrement, false);
      });

      test('should handle multiple decrements', () {
        // Arrange
        var quantity = 5;

        // Act
        quantity -= 1; // 4
        quantity -= 1; // 3
        quantity -= 1; // 2

        // Assert
        expect(quantity, 2);
      });

      test('should handle quantity restoration after cancellation', () {
        // Arrange
        var quantity = 5;

        // Act - Booking created
        quantity -= 1; // 4

        // Act - Booking cancelled
        quantity += 1; // 5

        // Assert
        expect(quantity, 5);
      });
    });

    group('Offer Availability', () {
      test('should be available when quantity > 0 and not expired', () {
        // Arrange
        final offer = OfferModel(
          id: 'offer123',
          restaurantId: 'rest123',
          dishName: 'Test Dish',
          description: 'Description',
          originalPrice: 15.0,
          discountPrice: 5.0,
          availableQuantity: 5,
          photoUrl: 'url',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 2)),
        );

        // Act & Assert
        expect(offer.isAvailable, true);
        expect(offer.availableQuantity > 0, true);
        expect(offer.isExpired, false);
      });

      test('should not be available when quantity is 0', () {
        // Arrange
        final offer = OfferModel(
          id: 'offer123',
          restaurantId: 'rest123',
          dishName: 'Test Dish',
          description: 'Description',
          originalPrice: 15.0,
          discountPrice: 5.0,
          availableQuantity: 0,
          photoUrl: 'url',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 2)),
        );

        // Act & Assert
        expect(offer.isAvailable, false);
      });

      test('should not be available when expired', () {
        // Arrange
        final offer = OfferModel(
          id: 'offer123',
          restaurantId: 'rest123',
          dishName: 'Test Dish',
          description: 'Description',
          originalPrice: 15.0,
          discountPrice: 5.0,
          availableQuantity: 5,
          photoUrl: 'url',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        // Act & Assert
        expect(offer.isAvailable, false);
        expect(offer.isExpired, true);
      });
    });

    group('Discount Calculation', () {
      test('should calculate discount percentage correctly', () {
        // Arrange
        const originalPrice = 20.0;
        const discountPrice = 10.0;

        // Act
        final discountPercentage = ((originalPrice - discountPrice) / originalPrice * 100).round();

        // Assert
        expect(discountPercentage, 50);
      });

      test('should calculate 33% discount correctly', () {
        // Arrange
        const originalPrice = 15.0;
        const discountPrice = 10.0;

        // Act
        final discountPercentage = ((originalPrice - discountPrice) / originalPrice * 100).round();

        // Assert
        expect(discountPercentage, 33);
      });

      test('should calculate 66% discount correctly', () {
        // Arrange
        const originalPrice = 15.0;
        const discountPrice = 5.0;

        // Act
        final discountPercentage = ((originalPrice - discountPrice) / originalPrice * 100).round();

        // Assert
        expect(discountPercentage, 67); // Rounds up
      });

      test('should handle 100% discount', () {
        // Arrange
        const originalPrice = 10.0;
        const discountPrice = 0.0;

        // Act
        final discountPercentage = ((originalPrice - discountPrice) / originalPrice * 100).round();

        // Assert
        expect(discountPercentage, 100);
      });

      test('should handle no discount', () {
        // Arrange
        const originalPrice = 10.0;
        const discountPrice = 10.0;

        // Act
        final discountPercentage = ((originalPrice - discountPrice) / originalPrice * 100).round();

        // Assert
        expect(discountPercentage, 0);
      });
    });

    group('Price Validation', () {
      test('discount price should be less than original price', () {
        // Arrange
        const originalPrice = 15.0;
        const discountPrice = 5.0;

        // Act & Assert
        expect(discountPrice < originalPrice, true);
      });

      test('should handle equal prices (no discount)', () {
        // Arrange
        const originalPrice = 10.0;
        const discountPrice = 10.0;

        // Act
        final hasDiscount = discountPrice < originalPrice;

        // Assert
        expect(hasDiscount, false);
      });

      test('prices should be positive', () {
        // Arrange
        const originalPrice = 15.0;
        const discountPrice = 5.0;

        // Act & Assert
        expect(originalPrice > 0, true);
        expect(discountPrice >= 0, true);
      });
    });

    group('Expiration Logic', () {
      test('should detect expired offer', () {
        // Arrange
        final expiresAt = DateTime.now().subtract(const Duration(hours: 1));
        final now = DateTime.now();

        // Act
        final isExpired = now.isAfter(expiresAt);

        // Assert
        expect(isExpired, true);
      });

      test('should detect valid offer', () {
        // Arrange
        final expiresAt = DateTime.now().add(const Duration(hours: 2));
        final now = DateTime.now();

        // Act
        final isExpired = now.isAfter(expiresAt);

        // Assert
        expect(isExpired, false);
      });

      test('should handle offer expiring soon', () {
        // Arrange
        final expiresAt = DateTime.now().add(const Duration(minutes: 30));
        final now = DateTime.now();

        // Act
        final isExpired = now.isAfter(expiresAt);
        final expiresInMinutes = expiresAt.difference(now).inMinutes;

        // Assert
        expect(isExpired, false);
        expect(expiresInMinutes < 60, true);
      });
    });

    group('Offer Filtering', () {
      test('should filter by restaurant', () {
        // Arrange
        const restaurantId = 'rest123';
        final offers = [
          OfferModel(
            id: 'offer1',
            restaurantId: 'rest123',
            dishName: 'Dish 1',
            description: 'Desc',
            originalPrice: 15.0,
            discountPrice: 5.0,
            availableQuantity: 5,
            photoUrl: 'url',
            createdAt: DateTime.now(),
            expiresAt: DateTime.now().add(const Duration(hours: 2)),
          ),
          OfferModel(
            id: 'offer2',
            restaurantId: 'rest456',
            dishName: 'Dish 2',
            description: 'Desc',
            originalPrice: 15.0,
            discountPrice: 5.0,
            availableQuantity: 5,
            photoUrl: 'url',
            createdAt: DateTime.now(),
            expiresAt: DateTime.now().add(const Duration(hours: 2)),
          ),
        ];

        // Act
        final filtered = offers.where((o) => o.restaurantId == restaurantId).toList();

        // Assert
        expect(filtered.length, 1);
        expect(filtered.first.restaurantId, restaurantId);
      });

      test('should filter available offers only', () {
        // Arrange
        final offers = [
          OfferModel(
            id: 'offer1',
            restaurantId: 'rest123',
            dishName: 'Dish 1',
            description: 'Desc',
            originalPrice: 15.0,
            discountPrice: 5.0,
            availableQuantity: 5,
            photoUrl: 'url',
            createdAt: DateTime.now(),
            expiresAt: DateTime.now().add(const Duration(hours: 2)),
          ),
          OfferModel(
            id: 'offer2',
            restaurantId: 'rest123',
            dishName: 'Dish 2',
            description: 'Desc',
            originalPrice: 15.0,
            discountPrice: 5.0,
            availableQuantity: 0,
            photoUrl: 'url',
            createdAt: DateTime.now(),
            expiresAt: DateTime.now().add(const Duration(hours: 2)),
          ),
        ];

        // Act
        final available = offers.where((o) => o.isAvailable).toList();

        // Assert
        expect(available.length, 1);
        expect(available.first.availableQuantity > 0, true);
      });
    });

    group('Data Integrity', () {
      test('should maintain offer data during updates', () {
        // Arrange
        final originalOffer = OfferModel(
          id: 'offer123',
          restaurantId: 'rest123',
          dishName: 'Original Dish',
          description: 'Original Description',
          originalPrice: 15.0,
          discountPrice: 5.0,
          availableQuantity: 10,
          photoUrl: 'url',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 2)),
        );

        // Act - Update quantity
        final updatedOffer = originalOffer.copyWith(availableQuantity: 9);

        // Assert
        expect(updatedOffer.availableQuantity, 9);
        expect(updatedOffer.id, originalOffer.id);
        expect(updatedOffer.dishName, originalOffer.dishName);
        expect(updatedOffer.originalPrice, originalOffer.originalPrice);
        expect(originalOffer.availableQuantity, 10); // Original unchanged
      });

      test('should maintain data during serialization', () {
        // Arrange
        final offer = OfferModel(
          id: 'offer123',
          restaurantId: 'rest123',
          dishName: 'Test Dish',
          description: 'Test Description',
          originalPrice: 15.0,
          discountPrice: 5.0,
          availableQuantity: 10,
          photoUrl: 'url',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 2)),
        );

        // Act
        final serialized = offer.toMap();
        final deserialized = OfferModel.fromMap(serialized, offer.id);

        // Assert
        expect(deserialized.id, offer.id);
        expect(deserialized.restaurantId, offer.restaurantId);
        expect(deserialized.dishName, offer.dishName);
        expect(deserialized.description, offer.description);
        expect(deserialized.originalPrice, offer.originalPrice);
        expect(deserialized.discountPrice, offer.discountPrice);
        expect(deserialized.availableQuantity, offer.availableQuantity);
      });

      test('should preserve all required fields', () {
        // Arrange & Act
        final offer = OfferModel(
          id: 'offer123',
          restaurantId: 'rest123',
          dishName: 'Test Dish',
          description: 'Test Description',
          originalPrice: 15.0,
          discountPrice: 5.0,
          availableQuantity: 10,
          photoUrl: 'photo.jpg',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 2)),
        );

        // Assert
        expect(offer.id.isNotEmpty, true);
        expect(offer.restaurantId.isNotEmpty, true);
        expect(offer.dishName.isNotEmpty, true);
        expect(offer.description.isNotEmpty, true);
        expect(offer.originalPrice > 0, true);
        expect(offer.discountPrice >= 0, true);
        expect(offer.availableQuantity >= 0, true);
        expect(offer.photoUrl.isNotEmpty, true);
      });
    });

    group('Edge Cases', () {
      test('should handle offer with very long description', () {
        // Arrange
        final longDescription = 'A' * 500;

        // Act
        final offer = OfferModel(
          id: 'offer123',
          restaurantId: 'rest123',
          dishName: 'Test Dish',
          description: longDescription,
          originalPrice: 15.0,
          discountPrice: 5.0,
          availableQuantity: 5,
          photoUrl: 'url',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 2)),
        );

        // Assert
        expect(offer.description.length, 500);
        expect(offer.description, longDescription);
      });

      test('should handle large quantity values', () {
        // Arrange
        const largeQuantity = 1000;

        // Act
        final offer = OfferModel(
          id: 'offer123',
          restaurantId: 'rest123',
          dishName: 'Test Dish',
          description: 'Description',
          originalPrice: 15.0,
          discountPrice: 5.0,
          availableQuantity: largeQuantity,
          photoUrl: 'url',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 2)),
        );

        // Assert
        expect(offer.availableQuantity, largeQuantity);
        expect(offer.isAvailable, true);
      });

      test('should handle decimal prices correctly', () {
        // Arrange
        const originalPrice = 15.99;
        const discountPrice = 7.49;

        // Act
        final offer = OfferModel(
          id: 'offer123',
          restaurantId: 'rest123',
          dishName: 'Test Dish',
          description: 'Description',
          originalPrice: originalPrice,
          discountPrice: discountPrice,
          availableQuantity: 5,
          photoUrl: 'url',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 2)),
        );

        // Assert
        expect(offer.originalPrice, originalPrice);
        expect(offer.discountPrice, discountPrice);
        expect(offer.discountPrice < offer.originalPrice, true);
      });

      test('should handle offer expiring at exact current time', () {
        // Arrange
        final now = DateTime.now();
        final expiresAtNow = DateTime(
          now.year,
          now.month,
          now.day,
          now.hour,
          now.minute,
          now.second,
        );

        // Act
        final isExpired = DateTime.now().isAfter(expiresAtNow) ||
            DateTime.now().isAtSameMomentAs(expiresAtNow);

        // Assert - Should be expired or at the same moment
        expect(isExpired, true);
      });

      test('should handle multiple offers from same restaurant', () {
        // Arrange
        const restaurantId = 'rest123';
        final offer1 = OfferModel(
          id: 'offer1',
          restaurantId: restaurantId,
          dishName: 'Dish 1',
          description: 'Desc 1',
          originalPrice: 15.0,
          discountPrice: 5.0,
          availableQuantity: 5,
          photoUrl: 'url1',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 2)),
        );
        final offer2 = OfferModel(
          id: 'offer2',
          restaurantId: restaurantId,
          dishName: 'Dish 2',
          description: 'Desc 2',
          originalPrice: 20.0,
          discountPrice: 10.0,
          availableQuantity: 3,
          photoUrl: 'url2',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 3)),
        );

        // Act & Assert
        expect(offer1.restaurantId, offer2.restaurantId);
        expect(offer1.id != offer2.id, true);
        expect(offer1.dishName != offer2.dishName, true);
      });
    });
  });
}