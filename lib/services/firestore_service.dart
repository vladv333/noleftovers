import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Коллекции
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get restaurantsCollection => _firestore.collection('restaurants');
  CollectionReference get offersCollection => _firestore.collection('offers');
  CollectionReference get bookingsCollection => _firestore.collection('bookings');

  // Создать пользователя
  Future<void> createUser({
    required String userId,
    required Map<String, dynamic> userData,
  }) async {
    try {
      await usersCollection.doc(userId).set(userData);
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  // Получить пользователя
  Future<DocumentSnapshot> getUser(String userId) async {
    try {
      return await usersCollection.doc(userId).get();
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Обновить пользователя
  Future<void> updateUser({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await usersCollection.doc(userId).update(updates);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Удалить пользователя
  Future<void> deleteUser(String userId) async {
    try {
      await usersCollection.doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Получить все рестораны
  Stream<QuerySnapshot> getRestaurants() {
    return restaurantsCollection.orderBy('name').snapshots();
  }

  // Получить конкретный ресторан
  Future<DocumentSnapshot> getRestaurant(String restaurantId) async {
    try {
      return await restaurantsCollection.doc(restaurantId).get();
    } catch (e) {
      throw Exception('Failed to get restaurant: $e');
    }
  }

  // Получить офферы по ресторану
  Stream<QuerySnapshot> getOffersByRestaurant(String restaurantId) {
    return offersCollection
        .where('restaurantId', isEqualTo: restaurantId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Получить все активные офферы
  Stream<QuerySnapshot> getAllActiveOffers() {
    return offersCollection
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Получить конкретный оффер
  Future<DocumentSnapshot> getOffer(String offerId) async {
    try {
      return await offersCollection.doc(offerId).get();
    } catch (e) {
      throw Exception('Failed to get offer: $e');
    }
  }

  // Уменьшить количество доступных офферов
  Future<void> decrementOfferQuantity(String offerId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final offerDoc = await transaction.get(offersCollection.doc(offerId));

        if (!offerDoc.exists) {
          throw Exception('Offer does not exist');
        }

        final data = offerDoc.data() as Map<String, dynamic>;
        final currentQuantity = data['availableQuantity'] as int;

        if (currentQuantity <= 0) {
          throw Exception('No more offers available');
        }

        transaction.update(
          offersCollection.doc(offerId),
          {'availableQuantity': currentQuantity - 1},
        );
      });
    } catch (e) {
      throw Exception('Failed to decrement offer quantity: $e');
    }
  }

  // Увеличить количество доступных офферов (при отмене бронирования)
  Future<void> incrementOfferQuantity(String offerId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final offerDoc = await transaction.get(offersCollection.doc(offerId));

        if (!offerDoc.exists) {
          throw Exception('Offer does not exist');
        }

        final data = offerDoc.data() as Map<String, dynamic>;
        final currentQuantity = data['availableQuantity'] as int;

        transaction.update(
          offersCollection.doc(offerId),
          {'availableQuantity': currentQuantity + 1},
        );
      });
    } catch (e) {
      throw Exception('Failed to increment offer quantity: $e');
    }
  }

  // Создать бронирование
  Future<String> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final docRef = await bookingsCollection.add(bookingData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  // Получить бронирования пользователя
  Stream<QuerySnapshot> getUserBookings(String userId) {
    return bookingsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots(includeMetadataChanges: true);
  }

  // Получить конкретное бронирование
  Future<DocumentSnapshot> getBooking(String bookingId) async {
    try {
      return await bookingsCollection.doc(bookingId).get();
    } catch (e) {
      throw Exception('Failed to get booking: $e');
    }
  }

  // Обновить статус бронирования
  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    try {
      await bookingsCollection.doc(bookingId).update({'status': status});
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  // Отменить бронирование
  Future<void> cancelBooking(String bookingId) async {
    try {
      print('Firestore: Updating booking $bookingId to cancelled'); // Debug
      await updateBookingStatus(bookingId: bookingId, status: 'cancelled');
      print('Firestore: Booking status updated successfully'); // Debug
    } catch (e) {
      print('Firestore: Error cancelling booking: $e'); // Debug
      throw Exception('Failed to cancel booking: $e');
    }
  }

  // Удалить бронирование
  Future<void> deleteBooking(String bookingId) async {
    try {
      await bookingsCollection.doc(bookingId).delete();
    } catch (e) {
      throw Exception('Failed to delete booking: $e');
    }
  }

  // Подсчитать количество офферов для ресторана
  Future<int> getOfferCountForRestaurant(String restaurantId) async {
    try {
      final snapshot = await offersCollection
          .where('restaurantId', isEqualTo: restaurantId)
          .get();

      // Считаем только офферы с доступным количеством
      return snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return (data['availableQuantity'] ?? 0) > 0;
      }).length;
    } catch (e) {
      throw Exception('Failed to get offer count: $e');
    }
  }
}