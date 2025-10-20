import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../backend/models/booking_model.dart';
import '../../backend/repositories/booking_repository.dart';

class BookingProvider with ChangeNotifier {
  final BookingRepository _bookingRepository = BookingRepository();

  List<BookingModel> _bookings = [];
  BookingModel? _selectedBooking;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  StreamSubscription? _bookingsSubscription;

  List<BookingModel> get bookings => _bookings;
  BookingModel? get selectedBooking => _selectedBooking;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // Получить только активные бронирования (pending)
  List<BookingModel> get activeBookings {
    return _bookings.where((b) => b.status == BookingStatus.pending).toList();
  }

  // Получить завершенные бронирования
  List<BookingModel> get completedBookings {
    return _bookings.where((b) => b.status == BookingStatus.completed).toList();
  }

  // Получить отмененные бронирования
  List<BookingModel> get cancelledBookings {
    return _bookings.where((b) => b.status == BookingStatus.cancelled).toList();
  }

  // Загрузить бронирования пользователя
  void loadUserBookings(String userId) {
    // Отменяем предыдущую подписку если есть
    _bookingsSubscription?.cancel();

    _isLoading = true;
    notifyListeners();

    _bookingsSubscription = _bookingRepository.getUserBookings(userId).listen(
          (bookings) {
        _bookings = bookings;
        _isLoading = false;
        print('Loaded ${bookings.length} bookings'); // Debug
        print('Active: ${activeBookings.length}, Cancelled: ${cancelledBookings.length}'); // Debug
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        print('Error loading bookings: $error'); // Debug
        notifyListeners();
      },
    );
  }

  // Создать бронирование
  Future<bool> createBooking({
    required String userId,
    required String offerId,
    required String restaurantId,
    required DateTime pickupTime,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      final booking = await _bookingRepository.createBooking(
        userId: userId,
        offerId: offerId,
        restaurantId: restaurantId,
        pickupTime: pickupTime,
      );

      // Добавляем новое бронирование в локальный список
      _bookings.insert(0, booking);
      print('Local update: Added new booking ${booking.id}'); // Debug

      _successMessage = 'Booking created successfully';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Отменить бронирование
  Future<bool> cancelBooking(String bookingId, String offerId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      await _bookingRepository.cancelBooking(bookingId, offerId);

      // Принудительно обновляем локальный список
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(status: BookingStatus.cancelled);
        print('Local update: Booking ${bookingId} status changed to cancelled'); // Debug
      }

      _successMessage = 'Booking cancelled successfully';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Завершить бронирование
  Future<bool> completeBooking(String bookingId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      await _bookingRepository.completeBooking(bookingId);

      _successMessage = 'Booking completed';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Выбрать бронирование
  Future<void> selectBooking(String bookingId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _selectedBooking = await _bookingRepository.getBookingById(bookingId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Очистить выбранное бронирование
  void clearSelectedBooking() {
    _selectedBooking = null;
    notifyListeners();
  }

  // Очистить бронирования
  void clearBookings() {
    _bookingsSubscription?.cancel();
    _bookings = [];
    notifyListeners();
  }

  // Очистить сообщения
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _bookingsSubscription?.cancel();
    super.dispose();
  }
}