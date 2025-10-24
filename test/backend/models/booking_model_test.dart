import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:noleftovers/backend/models/booking_model.dart';

void main() {
  group('BookingModel', () {
    final now = DateTime.now();
    final pickupTime = now.add(const Duration(hours: 2));

    test('should create BookingModel with all fields', () {
      // Arrange & Act
      final booking = BookingModel(
        id: 'booking123',
        userId: 'user123',
        offerId: 'offer123',
        restaurantId: 'rest123',
        pickupTime: pickupTime,
        status: BookingStatus.pending,
        createdAt: now,
      );

      // Assert
      expect(booking.id, 'booking123');
      expect(booking.userId, 'user123');
      expect(booking.offerId, 'offer123');
      expect(booking.restaurantId, 'rest123');
      expect(booking.pickupTime, pickupTime);
      expect(booking.status, BookingStatus.pending);
      expect(booking.createdAt, now);
    });

    test('should convert BookingStatus.pending to string', () {
      // Arrange
      final booking = BookingModel(
        id: 'booking123',
        userId: 'user123',
        offerId: 'offer123',
        restaurantId: 'rest123',
        pickupTime: pickupTime,
        status: BookingStatus.pending,
        createdAt: now,
      );

      // Act
      final map = booking.toMap();

      // Assert
      expect(map['status'], 'pending');
    });

    test('should convert BookingStatus.completed to string', () {
      // Arrange
      final booking = BookingModel(
        id: 'booking123',
        userId: 'user123',
        offerId: 'offer123',
        restaurantId: 'rest123',
        pickupTime: pickupTime,
        status: BookingStatus.completed,
        createdAt: now,
      );

      // Act
      final map = booking.toMap();

      // Assert
      expect(map['status'], 'completed');
    });

    test('should convert BookingStatus.cancelled to string', () {
      // Arrange
      final booking = BookingModel(
        id: 'booking123',
        userId: 'user123',
        offerId: 'offer123',
        restaurantId: 'rest123',
        pickupTime: pickupTime,
        status: BookingStatus.cancelled,
        createdAt: now,
      );

      // Act
      final map = booking.toMap();

      // Assert
      expect(map['status'], 'cancelled');
    });

    test('should create BookingModel from Map with pending status', () {
      // Arrange
      final map = {
        'userId': 'user123',
        'offerId': 'offer123',
        'restaurantId': 'rest123',
        'pickupTime': Timestamp.fromDate(pickupTime),
        'status': 'pending',
        'createdAt': Timestamp.fromDate(now),
      };

      // Act
      final booking = BookingModel.fromMap(map, 'booking123');

      // Assert
      expect(booking.id, 'booking123');
      expect(booking.status, BookingStatus.pending);
    });

    test('should create BookingModel from Map with completed status', () {
      // Arrange
      final map = {
        'userId': 'user123',
        'offerId': 'offer123',
        'restaurantId': 'rest123',
        'pickupTime': Timestamp.fromDate(pickupTime),
        'status': 'completed',
        'createdAt': Timestamp.fromDate(now),
      };

      // Act
      final booking = BookingModel.fromMap(map, 'booking123');

      // Assert
      expect(booking.status, BookingStatus.completed);
    });

    test('should create BookingModel from Map with cancelled status', () {
      // Arrange
      final map = {
        'userId': 'user123',
        'offerId': 'offer123',
        'restaurantId': 'rest123',
        'pickupTime': Timestamp.fromDate(pickupTime),
        'status': 'cancelled',
        'createdAt': Timestamp.fromDate(now),
      };

      // Act
      final booking = BookingModel.fromMap(map, 'booking123');

      // Assert
      expect(booking.status, BookingStatus.cancelled);
    });

    test('should default to pending status for unknown status string', () {
      // Arrange
      final map = {
        'userId': 'user123',
        'offerId': 'offer123',
        'restaurantId': 'rest123',
        'pickupTime': Timestamp.fromDate(pickupTime),
        'status': 'unknown_status',
        'createdAt': Timestamp.fromDate(now),
      };

      // Act
      final booking = BookingModel.fromMap(map, 'booking123');

      // Assert
      expect(booking.status, BookingStatus.pending);
    });

    test('should convert BookingModel to Map correctly', () {
      // Arrange
      final booking = BookingModel(
        id: 'booking123',
        userId: 'user123',
        offerId: 'offer123',
        restaurantId: 'rest123',
        pickupTime: pickupTime,
        status: BookingStatus.pending,
        createdAt: now,
      );

      // Act
      final map = booking.toMap();

      // Assert
      expect(map['userId'], 'user123');
      expect(map['offerId'], 'offer123');
      expect(map['restaurantId'], 'rest123');
      expect(map['pickupTime'], isA<Timestamp>());
      expect(map['status'], 'pending');
      expect(map['createdAt'], isA<Timestamp>());
      expect((map['pickupTime'] as Timestamp).toDate(), pickupTime);
      expect((map['createdAt'] as Timestamp).toDate(), now);
    });

    test('copyWith should update status correctly', () {
      // Arrange
      final booking = BookingModel(
        id: 'booking123',
        userId: 'user123',
        offerId: 'offer123',
        restaurantId: 'rest123',
        pickupTime: pickupTime,
        status: BookingStatus.pending,
        createdAt: now,
      );

      // Act
      final updated = booking.copyWith(status: BookingStatus.cancelled);

      // Assert
      expect(updated.status, BookingStatus.cancelled);
      expect(updated.id, 'booking123');
      expect(updated.userId, 'user123');
    });

    test('copyWith should keep original values if not specified', () {
      // Arrange
      final booking = BookingModel(
        id: 'booking123',
        userId: 'user123',
        offerId: 'offer123',
        restaurantId: 'rest123',
        pickupTime: pickupTime,
        status: BookingStatus.pending,
        createdAt: now,
      );

      // Act
      final copied = booking.copyWith();

      // Assert
      expect(copied.id, booking.id);
      expect(copied.userId, booking.userId);
      expect(copied.offerId, booking.offerId);
      expect(copied.restaurantId, booking.restaurantId);
      expect(copied.pickupTime, booking.pickupTime);
      expect(copied.status, booking.status);
      expect(copied.createdAt, booking.createdAt);
    });
  });
}