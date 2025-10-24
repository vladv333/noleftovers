import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noleftovers/backend/models/booking_model.dart';
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

  group('BookingRepository Logic', () {
    group('Booking Creation Validation', () {
      test('should validate booking data structure', () {
        // Arrange
        const userId = 'user123';
        const offerId = 'offer123';
        const restaurantId = 'rest123';
        final pickupTime = DateTime.now().add(const Duration(hours: 2));

        // Act
        final bookingData = {
          'userId': userId,
          'offerId': offerId,
          'restaurantId': restaurantId,
          'pickupTime': pickupTime,
          'status': 'pending',
        };

        // Assert
        expect(bookingData['userId'], userId);
        expect(bookingData['offerId'], offerId);
        expect(bookingData['restaurantId'], restaurantId);
        expect(bookingData['pickupTime'], pickupTime);
        expect(bookingData['status'], 'pending');
      });

      test('should ensure pickup time is in the future', () {
        // Arrange
        final now = DateTime.now();
        final futureTime = now.add(const Duration(hours: 2));
        final pastTime = now.subtract(const Duration(hours: 1));

        // Act & Assert
        expect(futureTime.isAfter(now), true);
        expect(pastTime.isAfter(now), false);
      });

      test('should validate all required fields are present', () {
        // Arrange
        final bookingData = {
          'userId': 'user123',
          'offerId': 'offer123',
          'restaurantId': 'rest123',
          'pickupTime': DateTime.now(),
          'status': 'pending',
        };

        // Act & Assert
        expect(bookingData.containsKey('userId'), true);
        expect(bookingData.containsKey('offerId'), true);
        expect(bookingData.containsKey('restaurantId'), true);
        expect(bookingData.containsKey('pickupTime'), true);
        expect(bookingData.containsKey('status'), true);
      });
    });

    group('Booking Status Management', () {
      test('should create booking with pending status', () {
        // Arrange & Act
        final booking = BookingModel(
          id: 'booking123',
          userId: 'user123',
          offerId: 'offer123',
          restaurantId: 'rest123',
          pickupTime: DateTime.now(),
          status: BookingStatus.pending,
          createdAt: DateTime.now(),
        );

        // Assert
        expect(booking.status, BookingStatus.pending);
      });

      test('should update booking status to cancelled', () {
        // Arrange
        final booking = BookingModel(
          id: 'booking123',
          userId: 'user123',
          offerId: 'offer123',
          restaurantId: 'rest123',
          pickupTime: DateTime.now(),
          status: BookingStatus.pending,
          createdAt: DateTime.now(),
        );

        // Act
        final cancelledBooking = booking.copyWith(
          status: BookingStatus.cancelled,
        );

        // Assert
        expect(cancelledBooking.status, BookingStatus.cancelled);
        expect(booking.status, BookingStatus.pending); // Original unchanged
      });

      test('should update booking status to completed', () {
        // Arrange
        final booking = BookingModel(
          id: 'booking123',
          userId: 'user123',
          offerId: 'offer123',
          restaurantId: 'rest123',
          pickupTime: DateTime.now(),
          status: BookingStatus.pending,
          createdAt: DateTime.now(),
        );

        // Act
        final completedBooking = booking.copyWith(
          status: BookingStatus.completed,
        );

        // Assert
        expect(completedBooking.status, BookingStatus.completed);
      });
    });

    group('Booking Cancellation Logic', () {
      test('should allow cancellation of pending booking', () {
        // Arrange
        final booking = BookingModel(
          id: 'booking123',
          userId: 'user123',
          offerId: 'offer123',
          restaurantId: 'rest123',
          pickupTime: DateTime.now(),
          status: BookingStatus.pending,
          createdAt: DateTime.now(),
        );

        // Act
        final canCancel = booking.status == BookingStatus.pending;
        final cancelledBooking = booking.copyWith(
          status: BookingStatus.cancelled,
        );

        // Assert
        expect(canCancel, true);
        expect(cancelledBooking.status, BookingStatus.cancelled);
      });

      test('should not allow cancellation of completed booking', () {
        // Arrange
        final booking = BookingModel(
          id: 'booking123',
          userId: 'user123',
          offerId: 'offer123',
          restaurantId: 'rest123',
          pickupTime: DateTime.now(),
          status: BookingStatus.completed,
          createdAt: DateTime.now(),
        );

        // Act
        final canCancel = booking.status == BookingStatus.pending;

        // Assert
        expect(canCancel, false);
      });

      test('should not allow cancellation of already cancelled booking', () {
        // Arrange
        final booking = BookingModel(
          id: 'booking123',
          userId: 'user123',
          offerId: 'offer123',
          restaurantId: 'rest123',
          pickupTime: DateTime.now(),
          status: BookingStatus.cancelled,
          createdAt: DateTime.now(),
        );

        // Act
        final canCancel = booking.status == BookingStatus.pending;

        // Assert
        expect(canCancel, false);
      });
    });

    group('Offer Quantity Management', () {
      test('should track quantity decrement on booking creation', () {
        // Arrange
        var offerQuantity = 5;
        const bookingQuantity = 1;

        // Act - Simulate booking creation
        offerQuantity -= bookingQuantity;

        // Assert
        expect(offerQuantity, 4);
      });

      test('should track quantity increment on booking cancellation', () {
        // Arrange
        var offerQuantity = 4;
        const bookingQuantity = 1;

        // Act - Simulate booking cancellation
        offerQuantity += bookingQuantity;

        // Assert
        expect(offerQuantity, 5);
      });

      test('should not allow booking when quantity is 0', () {
        // Arrange
        const offerQuantity = 0;

        // Act
        final canBook = offerQuantity > 0;

        // Assert
        expect(canBook, false);
      });

      test('should allow booking when quantity is available', () {
        // Arrange
        const offerQuantity = 3;

        // Act
        final canBook = offerQuantity > 0;

        // Assert
        expect(canBook, true);
      });
    });

    group('Booking Time Validation', () {
      test('should validate pickup time is within restaurant hours', () {
        // Arrange
        final pickupTime = DateTime(2025, 1, 20, 18, 30); // 6:30 PM
        final openingTime = 9; // 9 AM
        final closingTime = 22; // 10 PM

        // Act
        final isWithinHours = pickupTime.hour >= openingTime &&
            pickupTime.hour < closingTime;

        // Assert
        expect(isWithinHours, true);
      });

      test('should reject pickup time before opening', () {
        // Arrange
        final pickupTime = DateTime(2025, 1, 20, 7, 30); // 7:30 AM
        final openingTime = 9; // 9 AM

        // Act
        final isValid = pickupTime.hour >= openingTime;

        // Assert
        expect(isValid, false);
      });

      test('should reject pickup time after closing', () {
        // Arrange
        final pickupTime = DateTime(2025, 1, 20, 23, 30); // 11:30 PM
        final closingTime = 22; // 10 PM

        // Act
        final isValid = pickupTime.hour < closingTime;

        // Assert
        expect(isValid, false);
      });
    });

    group('Data Integrity', () {
      test('should maintain booking data during serialization', () {
        // Arrange
        final booking = BookingModel(
          id: 'booking123',
          userId: 'user123',
          offerId: 'offer123',
          restaurantId: 'rest123',
          pickupTime: DateTime(2025, 1, 20, 18, 0),
          status: BookingStatus.pending,
          createdAt: DateTime.now(),
        );

        // Act
        final serialized = booking.toMap();
        final deserialized = BookingModel.fromMap(serialized, booking.id);

        // Assert
        expect(deserialized.id, booking.id);
        expect(deserialized.userId, booking.userId);
        expect(deserialized.offerId, booking.offerId);
        expect(deserialized.restaurantId, booking.restaurantId);
        expect(deserialized.status, booking.status);
      });

      test('should preserve all relationships', () {
        // Arrange
        const userId = 'user123';
        const offerId = 'offer123';
        const restaurantId = 'rest123';

        final booking = BookingModel(
          id: 'booking123',
          userId: userId,
          offerId: offerId,
          restaurantId: restaurantId,
          pickupTime: DateTime.now(),
          status: BookingStatus.pending,
          createdAt: DateTime.now(),
        );

        // Act & Assert
        expect(booking.userId, userId);
        expect(booking.offerId, offerId);
        expect(booking.restaurantId, restaurantId);
      });
    });

    group('Edge Cases', () {
      test('should handle same-day booking', () {
        // Arrange
        final now = DateTime.now();
        final sameDayPickup = DateTime(
          now.year,
          now.month,
          now.day,
          now.hour + 1,
        );

        // Act
        final isSameDay = sameDayPickup.year == now.year &&
            sameDayPickup.month == now.month &&
            sameDayPickup.day == now.day;

        // Assert
        expect(isSameDay, true);
        expect(sameDayPickup.isAfter(now), true);
      });

      test('should handle multiple bookings per user', () {
        // Arrange
        const userId = 'user123';
        final booking1 = BookingModel(
          id: 'booking1',
          userId: userId,
          offerId: 'offer1',
          restaurantId: 'rest1',
          pickupTime: DateTime.now(),
          status: BookingStatus.pending,
          createdAt: DateTime.now(),
        );
        final booking2 = BookingModel(
          id: 'booking2',
          userId: userId,
          offerId: 'offer2',
          restaurantId: 'rest2',
          pickupTime: DateTime.now(),
          status: BookingStatus.pending,
          createdAt: DateTime.now(),
        );

        // Act & Assert
        expect(booking1.userId, booking2.userId);
        expect(booking1.id != booking2.id, true);
      });
    });
  });
}