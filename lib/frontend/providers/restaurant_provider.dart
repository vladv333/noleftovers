import 'package:flutter/foundation.dart';
import '../../backend/models/restaurant_model.dart';
import '../../backend/repositories/restaurant_repository.dart';

class RestaurantProvider with ChangeNotifier {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();

  List<RestaurantModel> _restaurants = [];
  Map<String, int> _offerCounts = {};
  RestaurantModel? _selectedRestaurant;
  bool _isLoading = false;
  String? _errorMessage;

  List<RestaurantModel> get restaurants => _restaurants;
  Map<String, int> get offerCounts => _offerCounts;
  RestaurantModel? get selectedRestaurant => _selectedRestaurant;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Получить количество офферов для ресторана
  int getOfferCount(String restaurantId) {
    return _offerCounts[restaurantId] ?? 0;
  }

  // Загрузить рестораны (используем Stream)
  void loadRestaurants() {
    _isLoading = true;
    notifyListeners();

    _restaurantRepository.getRestaurants().listen(
          (restaurants) {
        _restaurants = restaurants;
        _isLoading = false;
        notifyListeners();

        // Загружаем количество офферов для каждого ресторана
        _loadOfferCounts();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Загрузить количество офферов для всех ресторанов
  Future<void> _loadOfferCounts() async {
    try {
      for (var restaurant in _restaurants) {
        final count = await _restaurantRepository.getOfferCount(restaurant.id);
        _offerCounts[restaurant.id] = count;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Получить ресторан по ID (синхронный метод для виджетов)
  Future<RestaurantModel?> getRestaurantById(String restaurantId) async {
    try {
      return await _restaurantRepository.getRestaurantById(restaurantId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Выбрать ресторан
  Future<void> selectRestaurant(String restaurantId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _selectedRestaurant = await _restaurantRepository.getRestaurantById(restaurantId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Очистить выбранный ресторан
  void clearSelectedRestaurant() {
    _selectedRestaurant = null;
    notifyListeners();
  }

  // Обновить количество офферов для конкретного ресторана
  Future<void> refreshOfferCount(String restaurantId) async {
    try {
      final count = await _restaurantRepository.getOfferCount(restaurantId);
      _offerCounts[restaurantId] = count;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Очистить ошибку
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}