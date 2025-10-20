import 'package:flutter/foundation.dart';
import '../../backend/models/offer_model.dart';
import '../../backend/repositories/offer_repository.dart';

class OfferProvider with ChangeNotifier {
  final OfferRepository _offerRepository = OfferRepository();

  List<OfferModel> _offers = [];
  OfferModel? _selectedOffer;
  bool _isLoading = false;
  String? _errorMessage;

  List<OfferModel> get offers => _offers;
  OfferModel? get selectedOffer => _selectedOffer;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Загрузить офферы по ресторану
  void loadOffersByRestaurant(String restaurantId) {
    _isLoading = true;
    notifyListeners();

    _offerRepository.getOffersByRestaurant(restaurantId).listen(
          (offers) {
        _offers = offers;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Загрузить все активные офферы
  void loadAllActiveOffers() {
    _isLoading = true;
    notifyListeners();

    _offerRepository.getAllActiveOffers().listen(
          (offers) {
        _offers = offers;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Получить оффер по ID (синхронный метод для виджетов)
  Future<OfferModel?> getOfferById(String offerId) async {
    try {
      return await _offerRepository.getOfferById(offerId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Выбрать оффер
  Future<void> selectOffer(String offerId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _selectedOffer = await _offerRepository.getOfferById(offerId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Очистить выбранный оффер
  void clearSelectedOffer() {
    _selectedOffer = null;
    notifyListeners();
  }

  // Очистить офферы
  void clearOffers() {
    _offers = [];
    notifyListeners();
  }

  // Очистить ошибку
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}