import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import '../models/booking_model.dart';
import 'offer_repository.dart';

class BookingRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final OfferRepository _offerRepository = OfferRepository();

  // Создать бронирование
  Future<BookingModel> createBooking({
    required String userId,
    required String offerId,
    required String restaurantId,
    required DateTime pickupTime,
  }) async {
    try {
      // Уменьшаем количество доступных офферов
      await _offerRepository.decrementQuantity(offerId);

      // Создаём бронирование
      final bookingData = {
        'userId': userId,
        'offerId': offerId,
        'restaurantId': restaurantId,
        'pickupTime': Timestamp.fromDate(pickupTime),
        'status': 'pending',
        'createdAt': Timestamp.fromDate(DateTime.now()),
      };

      final bookingId = await _firestoreService.createBooking(bookingData);

      return BookingModel(
        id: bookingId,
        userId: userId,
        offerId: offerId,
        restaurantId: restaurantId,
        pickupTime: pickupTime,
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  // Получить бронирования пользователя
  Stream<List<BookingModel>> getUserBookings(String userId) {
    return _firestoreService.getUserBookings(userId).map((snapshot) {
      return snapshot.docs.map((doc) {
        return BookingModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // Получить конкретное бронирование
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final doc = await _firestoreService.getBooking(bookingId);

      if (!doc.exists) return null;

      return BookingModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    } catch (e) {
      throw Exception('Failed to get booking: $e');
    }
  }

  // Отменить бронирование
  Future<void> cancelBooking(String bookingId, String offerId) async {
    try {
      print('Repository: Cancelling booking $bookingId'); // Debug

      // Обновляем статус бронирования
      await _firestoreService.cancelBooking(bookingId);
      print('Repository: Booking status updated'); // Debug

      // Возвращаем оффер в наличие
      await _offerRepository.incrementQuantity(offerId);
      print('Repository: Offer quantity incremented'); // Debug
    } catch (e) {
      print('Repository: Error cancelling booking: $e'); // Debug
      throw Exception('Failed to cancel booking: $e');
    }
  }

  // Завершить бронирование
  Future<void> completeBooking(String bookingId) async {
    try {
      await _firestoreService.updateBookingStatus(
        bookingId: bookingId,
        status: 'completed',
      );
    } catch (e) {
      throw Exception('Failed to complete booking: $e');
    }
  }

  // Удалить бронирование
  Future<void> deleteBooking(String bookingId) async {
    try {
      await _firestoreService.deleteBooking(bookingId);
    } catch (e) {
      throw Exception('Failed to delete booking: $e');
    }
  }
}