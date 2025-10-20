import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import '../models/offer_model.dart';

class OfferRepository {
  final FirestoreService _firestoreService = FirestoreService();

  // Получить офферы по ресторану
  Stream<List<OfferModel>> getOffersByRestaurant(String restaurantId) {
    return _firestoreService
        .getOffersByRestaurant(restaurantId)
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return OfferModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // Получить все активные офферы
  Stream<List<OfferModel>> getAllActiveOffers() {
    return _firestoreService.getAllActiveOffers().map((snapshot) {
      return snapshot.docs.map((doc) {
        return OfferModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // Получить конкретный оффер
  Future<OfferModel?> getOfferById(String offerId) async {
    try {
      final doc = await _firestoreService.getOffer(offerId);

      if (!doc.exists) return null;

      return OfferModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    } catch (e) {
      throw Exception('Failed to get offer: $e');
    }
  }

  // Уменьшить количество офферов (при бронировании)
  Future<void> decrementQuantity(String offerId) async {
    try {
      await _firestoreService.decrementOfferQuantity(offerId);
    } catch (e) {
      throw Exception('Failed to decrement offer quantity: $e');
    }
  }

  // Увеличить количество офферов (при отмене бронирования)
  Future<void> incrementQuantity(String offerId) async {
    try {
      await _firestoreService.incrementOfferQuantity(offerId);
    } catch (e) {
      throw Exception('Failed to increment offer quantity: $e');
    }
  }
}