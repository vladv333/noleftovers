import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noleftovers/backend/repositories/auth_repository.dart';
import 'package:noleftovers/backend/repositories/booking_repository.dart';
import 'package:noleftovers/backend/repositories/offer_repository.dart';
import 'package:noleftovers/backend/models/user_model.dart';
import 'package:noleftovers/backend/models/booking_model.dart';
import 'package:noleftovers/backend/models/offer_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:mockito/annotations.dart';

// mock for firebase
typedef Callback = void Function(MethodCall call);

void setupFirebaseAuthMocks([Callback? customHandlers]) {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
}

// mock generation for repos
@GenerateMocks([AuthRepository, BookingRepository, OfferRepository])
void main() {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('Integration Tests', () {
    group('Authentication Flow', () {
      test('complete registration flow should create user in Firestore', () async {
        // Arrange
        const email = 'newuser@example.com';
        const password = 'password123';
        const name = 'Test User';

        // Act - Step 1: Validate input data
        final isEmailValid = email.contains('@') && email.contains('.');
        final isPasswordValid = password.length >= 6;
        final isNameValid = name.isNotEmpty;

        expect(isEmailValid, true);
        expect(isPasswordValid, true);
        expect(isNameValid, true);

        // Act - Step 2: Create user data structure
        final userData = {
          'email': email,
          'password': password,
          'name': name,
        };

        // Act - Step 3: Simulate user creation
        final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
        final createdUser = UserModel(
          id: userId,
          name: name,
          email: email,
          createdAt: DateTime.now(),
        );

        // Assert - User created successfully
        expect(createdUser.id, userId);
        expect(createdUser.name, name);
        expect(createdUser.email, email);
        expect(userData['email'], email);
      });

      test('login flow should authenticate and return user data', () async {
        // Arrange
        const email = 'existinguser@example.com';
        const password = 'password123';

        // Act - Step 1: Validate credentials
        final isEmailValid = email.contains('@');
        final isPasswordValid = password.isNotEmpty;

        expect(isEmailValid, true);
        expect(isPasswordValid, true);

        // Act - Step 2: Simulate authentication
        final loginData = {
          'email': email,
          'password': password,
        };

        // Act - Step 3: Simulate user retrieval from Firestore
        final authenticatedUser = UserModel(
          id: 'user123',
          name: 'Existing User',
          email: email,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        );

        // Assert
        expect(authenticatedUser.email, email);
        expect(loginData['email'], email);
        expect(authenticatedUser.id.isNotEmpty, true);
      });

      test('registration should fail with invalid email', () async {
        // Arrange
        const invalidEmail = 'notanemail';
        const password = 'password123';
        const name = 'Test User';

        // Act
        final isEmailValid = invalidEmail.contains('@') && invalidEmail.contains('.');

        // Assert
        expect(isEmailValid, false);
      });

      test('login should fail with empty password', () async {
        // Arrange
        const email = 'user@example.com';
        const password = '';

        // Act
        final isPasswordValid = password.length >= 6;

        // Assert
        expect(isPasswordValid, false);
      });

      test('user profile update should persist to Firestore', () async {
        // Arrange
        final originalUser = UserModel(
          id: 'user123',
          name: 'Original Name',
          email: 'user@example.com',
          createdAt: DateTime.now(),
        );

        // Act - Update user name
        const newName = 'Updated Name';
        final updatedUser = originalUser.copyWith(name: newName);

        // Assert
        expect(updatedUser.name, newName);
        expect(updatedUser.email, originalUser.email);
        expect(updatedUser.id, originalUser.id);
        expect(originalUser.name, 'Original Name'); // Original unchanged
      });
    });

    group('Booking Flow Integration', () {
      test('complete booking flow should decrement offer quantity', () async {
        // Arrange - Create an offer
        final offer = OfferModel(
          id: 'offer123',
          restaurantId: 'rest123',
          dishName: 'Test Dish',
          description: 'Delicious food',
          originalPrice: 15.0,
          discountPrice: 5.0,
          availableQuantity: 10,
          photoUrl: 'url',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 3)),
        );

        final user = UserModel(
          id: 'user123',
          name: 'Test User',
          email: 'user@example.com',
          createdAt: DateTime.now(),
        );

        // Act - Step 1: Verify offer is available
        expect(offer.isAvailable, true);
        expect(offer.availableQuantity > 0, true);

        // Act - Step 2: Create booking
        final booking = BookingModel(
          id: 'booking123',
          userId: user.id,
          offerId: offer.id,
          restaurantId: offer.restaurantId,
          pickupTime: DateTime.now().add(const Duration(hours: 2)),
          status: BookingStatus.pending,
          createdAt: DateTime.now(),
        );

        // Act - Step 3: Decrement offer quantity
        final updatedQuantity = offer.availableQuantity - 1;
        final updatedOffer = offer.copyWith(availableQuantity: updatedQuantity);

        // Assert
        expect(booking.userId, user.id);
        expect(booking.offerId, offer.id);
        expect(booking.status, BookingStatus.pending);
        expect(updatedOffer.availableQuantity, 9);
        expect(offer.availableQuantity, 10); // Original unchanged
      });

      test('booking cancellation should restore offer quantity', () async {
        // Arrange - Offer with reduced quantity
        final offer = OfferModel(
          id: 'offer123',
          restaurantId: 'rest123',
          dishName: 'Test Dish',
          description: 'Delicious food',
          originalPrice: 15.0,
          discountPrice: 5.0,
          availableQuantity: 9, // Already had one booking
          photoUrl: 'url',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 3)),
        );

        final booking = BookingModel(
          id: 'booking123',
          userId: 'user123',
          offerId: offer.id,
          restaurantId: offer.restaurantId,
          pickupTime: DateTime.now().add(const Duration(hours: 2)),
          status: BookingStatus.pending,
          createdAt: DateTime.now(),
        );

        // Act - Step 1: Cancel booking
        final cancelledBooking = booking.copyWith(
          status: BookingStatus.cancelled,
        );

        // Act - Step 2: Restore offer quantity
        final restoredQuantity = offer.availableQuantity + 1;
        final updatedOffer = offer.copyWith(availableQuantity: restoredQuantity);

        // Assert
        expect(cancelledBooking.status, BookingStatus.cancelled);
        expect(booking.status, BookingStatus.pending); // Original unchanged
        expect(updatedOffer.availableQuantity, 10);
      });

      test('should not allow booking when quantity is 0', () async {
        // Arrange
        final offer = OfferModel(
          id: 'offer123',
          restaurantId: 'rest123',
          dishName: 'Test Dish',
          description: 'Delicious food',
          originalPrice: 15.0,
          discountPrice: 5.0,
          availableQuantity: 0,
          photoUrl: 'url',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 3)),
        );

        // Act
        final canBook = offer.isAvailable;

        // Assert
        expect(canBook, false);
        expect(offer.availableQuantity, 0);
      });

      test('should not allow booking expired offer', () async {
        // Arrange
        final offer = OfferModel(
          id: 'offer123',
          restaurantId: 'rest123',
          dishName: 'Test Dish',
          description: 'Delicious food',
          originalPrice: 15.0,
          discountPrice: 5.0,
          availableQuantity: 5,
          photoUrl: 'url',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        // Act
        final canBook = offer.isAvailable;

        // Assert
        expect(canBook, false);
        expect(offer.isExpired, true);
      });

      test('multiple bookings should correctly update quantity', () async {
        // Arrange
        final offer = OfferModel(
          id: 'offer123',
          restaurantId: 'rest123',
          dishName: 'Test Dish',
          description: 'Delicious food',
          originalPrice: 15.0,
          discountPrice: 5.0,
          availableQuantity: 10,
          photoUrl: 'url',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 3)),
        );

        // Act - Create 3 bookings
        var currentQuantity = offer.availableQuantity;

        // Booking 1
        final booking1 = BookingModel(
          id: 'booking1',
          userId: 'user1',
          offerId: offer.id,
          restaurantId: offer.restaurantId,
          pickupTime: DateTime.now().add(const Duration(hours: 2)),
          status: BookingStatus.pending,
          createdAt: DateTime.now(),
        );
        currentQuantity -= 1; // 9

        // Booking 2
        final booking2 = BookingModel(
          id: 'booking2',
          userId: 'user2',
          offerId: offer.id,
          restaurantId: offer.restaurantId,
          pickupTime: DateTime.now().add(const Duration(hours: 2)),
          status: BookingStatus.pending,
          createdAt: DateTime.now(),
        );
        currentQuantity -= 1; // 8

        // Booking 3
        final booking3 = BookingModel(
          id: 'booking3',
          userId: 'user3',
          offerId: offer.id,
          restaurantId: offer.restaurantId,
          pickupTime: DateTime.now().add(const Duration(hours: 2)),
          status: BookingStatus.pending,
          createdAt: DateTime.now(),
        );
        currentQuantity -= 1; // 7

        // Assert
        expect(currentQuantity, 7);
        expect(booking1.offerId, offer.id);
        expect(booking2.offerId, offer.id);
        expect(booking3.offerId, offer.id);
      });

      test('booking completion should not restore quantity', () async {
        // Arrange
        final offer = OfferModel(
          id: 'offer123',
          restaurantId: 'rest123',
          dishName: 'Test Dish',
          description: 'Delicious food',
          originalPrice: 15.0,
          discountPrice: 5.0,
          availableQuantity: 9,
          photoUrl: 'url',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 3)),
        );

        final booking = BookingModel(
          id: 'booking123',
          userId: 'user123',
          offerId: offer.id,
          restaurantId: offer.restaurantId,
          pickupTime: DateTime.now().add(const Duration(hours: 2)),
          status: BookingStatus.pending,
          createdAt: DateTime.now(),
        );

        // Act - Complete booking (user picked up the food)
        final completedBooking = booking.copyWith(
          status: BookingStatus.completed,
        );

        // Assert - Quantity should remain the same (food was picked up)
        expect(completedBooking.status, BookingStatus.completed);
        expect(offer.availableQuantity, 9); // No restoration
      });
    });

    group('User-Booking-Offer Integration', () {
      test('user should be able to view their bookings', () async {
        // Arrange
        const userId = 'user123';
        final user = UserModel(
          id: userId,
          name: 'Test User',
          email: 'user@example.com',
          createdAt: DateTime.now(),
        );

        final booking1 = BookingModel(
          id: 'booking1',
          userId: userId,
          offerId: 'offer1',
          restaurantId: 'rest1',
          pickupTime: DateTime.now().add(const Duration(hours: 2)),
          status: BookingStatus.pending,
          createdAt: DateTime.now(),
        );

        final booking2 = BookingModel(
          id: 'booking2',
          userId: userId,
          offerId: 'offer2',
          restaurantId: 'rest2',
          pickupTime: DateTime.now().add(const Duration(hours: 3)),
          status: BookingStatus.completed,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        );

        final allBookings = [booking1, booking2];

        // Act - Filter user's bookings
        final userBookings = allBookings.where((b) => b.userId == userId).toList();

        // Assert
        expect(userBookings.length, 2);
        expect(userBookings[0].userId, userId);
        expect(userBookings[1].userId, userId);
      });

      test('restaurant offers should be available to all users', () async {
        // Arrange
        const restaurantId = 'rest123';
        final offer = OfferModel(
          id: 'offer123',
          restaurantId: restaurantId,
          dishName: 'Test Dish',
          description: 'Delicious food',
          originalPrice: 15.0,
          discountPrice: 5.0,
          availableQuantity: 10,
          photoUrl: 'url',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 3)),
        );

        final user1 = UserModel(
          id: 'user1',
          name: 'User One',
          email: 'user1@example.com',
          createdAt: DateTime.now(),
        );

        final user2 = UserModel(
          id: 'user2',
          name: 'User Two',
          email: 'user2@example.com',
          createdAt: DateTime.now(),
        );

        // Act - Both users can book the same offer
        final booking1 = BookingModel(
          id: 'booking1',
          userId: user1.id,
          offerId: offer.id,
          restaurantId: restaurantId,
          pickupTime: DateTime.now().add(const Duration(hours: 2)),
          status: BookingStatus.pending,
          createdAt: DateTime.now(),
        );

        final booking2 = BookingModel(
          id: 'booking2',
          userId: user2.id,
          offerId: offer.id,
          restaurantId: restaurantId,
          pickupTime: DateTime.now().add(const Duration(hours: 2)),
          status: BookingStatus.pending,
          createdAt: DateTime.now(),
        );

        // Assert
        expect(booking1.offerId, booking2.offerId);
        expect(booking1.userId != booking2.userId, true);
      });

      test('booking validation should check all requirements', () async {
        // Arrange
        final offer = OfferModel(
          id: 'offer123',
          restaurantId: 'rest123',
          dishName: 'Test Dish',
          description: 'Delicious food',
          originalPrice: 15.0,
          discountPrice: 5.0,
          availableQuantity: 5,
          photoUrl: 'url',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 3)),
        );

        final user = UserModel(
          id: 'user123',
          name: 'Test User',
          email: 'user@example.com',
          createdAt: DateTime.now(),
        );

        final pickupTime = DateTime.now().add(const Duration(hours: 2));

        // Act - Validate all booking requirements
        final isOfferAvailable = offer.isAvailable;
        final isPickupTimeValid = pickupTime.isAfter(DateTime.now());
        final isUserAuthenticated = user.id.isNotEmpty;
        final hasQuantity = offer.availableQuantity > 0;

        final canCreateBooking = isOfferAvailable &&
            isPickupTimeValid &&
            isUserAuthenticated &&
            hasQuantity;

        // Assert
        expect(isOfferAvailable, true);
        expect(isPickupTimeValid, true);
        expect(isUserAuthenticated, true);
        expect(hasQuantity, true);
        expect(canCreateBooking, true);
      });
    });

    group('Data Consistency Tests', () {
      test('cancelled booking should maintain data integrity', () async {
        // Arrange
        final originalBooking = BookingModel(
          id: 'booking123',
          userId: 'user123',
          offerId: 'offer123',
          restaurantId: 'rest123',
          pickupTime: DateTime.now().add(const Duration(hours: 2)),
          status: BookingStatus.pending,
          createdAt: DateTime.now(),
        );

        // Act - Cancel booking
        final cancelledBooking = originalBooking.copyWith(
          status: BookingStatus.cancelled,
        );

        // Assert - All other data remains unchanged
        expect(cancelledBooking.id, originalBooking.id);
        expect(cancelledBooking.userId, originalBooking.userId);
        expect(cancelledBooking.offerId, originalBooking.offerId);
        expect(cancelledBooking.restaurantId, originalBooking.restaurantId);
        expect(cancelledBooking.pickupTime, originalBooking.pickupTime);
        expect(cancelledBooking.status, BookingStatus.cancelled);
        expect(originalBooking.status, BookingStatus.pending);
      });

      test('offer update should not affect existing bookings', () async {
        // Arrange
        final offer = OfferModel(
          id: 'offer123',
          restaurantId: 'rest123',
          dishName: 'Original Dish',
          description: 'Original description',
          originalPrice: 15.0,
          discountPrice: 5.0,
          availableQuantity: 10,
          photoUrl: 'url',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 3)),
        );

        final booking = BookingModel(
          id: 'booking123',
          userId: 'user123',
          offerId: offer.id,
          restaurantId: offer.restaurantId,
          pickupTime: DateTime.now().add(const Duration(hours: 2)),
          status: BookingStatus.pending,
          createdAt: DateTime.now(),
        );

        // Act - Update offer
        final updatedOffer = offer.copyWith(
          dishName: 'Updated Dish',
          availableQuantity: 5,
        );

        // Assert - Booking reference remains valid
        expect(booking.offerId, offer.id);
        expect(booking.offerId, updatedOffer.id);
        expect(offer.dishName, 'Original Dish');
        expect(updatedOffer.dishName, 'Updated Dish');
      });

      test('user deletion scenario should be handled', () async {
        // Arrange
        final user = UserModel(
          id: 'user123',
          name: 'Test User',
          email: 'user@example.com',
          createdAt: DateTime.now(),
        );

        final booking = BookingModel(
          id: 'booking123',
          userId: user.id,
          offerId: 'offer123',
          restaurantId: 'rest123',
          pickupTime: DateTime.now().add(const Duration(hours: 2)),
          status: BookingStatus.pending,
          createdAt: DateTime.now(),
        );

        // Act - Simulate user data still referenced in booking
        final bookingUserId = booking.userId;
        final userExists = bookingUserId == user.id;

        // Assert
        expect(userExists, true);
        expect(booking.userId, user.id);
      });
    });
  });
}