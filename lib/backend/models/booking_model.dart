import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  pending,
  completed,
  cancelled,
}

class BookingModel {
  final String id;
  final String userId;
  final String offerId;
  final String restaurantId;
  final DateTime pickupTime;
  final BookingStatus status;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.offerId,
    required this.restaurantId,
    required this.pickupTime,
    required this.status,
    required this.createdAt,
  });

  // Преобразование строки в enum
  static BookingStatus _statusFromString(String status) {
    switch (status) {
      case 'pending':
        return BookingStatus.pending;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }

  // Преобразование enum в строку
  static String _statusToString(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.completed:
        return 'completed';
      case BookingStatus.cancelled:
        return 'cancelled';
    }
  }

  // Преобразование из Map в BookingModel
  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    return BookingModel(
      id: id,
      userId: map['userId'] ?? '',
      offerId: map['offerId'] ?? '',
      restaurantId: map['restaurantId'] ?? '',
      pickupTime: (map['pickupTime'] as Timestamp).toDate(),
      status: _statusFromString(map['status'] ?? 'pending'),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Преобразование из BookingModel в Map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'offerId': offerId,
      'restaurantId': restaurantId,
      'pickupTime': Timestamp.fromDate(pickupTime),
      'status': _statusToString(status),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Копирование с изменениями
  BookingModel copyWith({
    String? id,
    String? userId,
    String? offerId,
    String? restaurantId,
    DateTime? pickupTime,
    BookingStatus? status,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      offerId: offerId ?? this.offerId,
      restaurantId: restaurantId ?? this.restaurantId,
      pickupTime: pickupTime ?? this.pickupTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}