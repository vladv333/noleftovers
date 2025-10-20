import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import '../models/restaurant_model.dart';

class RestaurantRepository {
  final FirestoreService _firestoreService = FirestoreService();

  // Получить все рестораны как Stream
  Stream<List<RestaurantModel>> getRestaurants() {
    return _firestoreService.getRestaurants().map((snapshot) {
      return snapshot.docs.map((doc) {
        return RestaurantModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // Получить конкретный ресторан
  Future<RestaurantModel?> getRestaurantById(String restaurantId) async {
    try {
      final doc = await _firestoreService.getRestaurant(restaurantId);

      if (!doc.exists) return null;

      return RestaurantModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    } catch (e) {
      throw Exception('Failed to get restaurant: $e');
    }
  }

  // Получить рестораны с количеством офферов
  Future<List<Map<String, dynamic>>> getRestaurantsWithOfferCount() async {
    try {
      final restaurants = await _firestoreService.restaurantsCollection.get();

      final List<Map<String, dynamic>> result = [];

      for (var doc in restaurants.docs) {
        final restaurant = RestaurantModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );

        final offerCount = await _firestoreService.getOfferCountForRestaurant(
          restaurant.id,
        );

        result.add({
          'restaurant': restaurant,
          'offerCount': offerCount,
        });
      }

      return result;
    } catch (e) {
      throw Exception('Failed to get restaurants with offer count: $e');
    }
  }

  // Получить количество офферов для ресторана
  Future<int> getOfferCount(String restaurantId) async {
    try {
      return await _firestoreService.getOfferCountForRestaurant(restaurantId);
    } catch (e) {
      throw Exception('Failed to get offer count: $e');
    }
  }
}