import 'package:cloud_firestore/cloud_firestore.dart';

class OfferModel {
  final String id;
  final String restaurantId;
  final String dishName;
  final String description;
  final double originalPrice;
  final double discountPrice;
  final int availableQuantity;
  final String photoUrl;
  final DateTime createdAt;
  final DateTime expiresAt;

  OfferModel({
    required this.id,
    required this.restaurantId,
    required this.dishName,
    required this.description,
    required this.originalPrice,
    required this.discountPrice,
    required this.availableQuantity,
    required this.photoUrl,
    required this.createdAt,
    required this.expiresAt,
  });

  // Проверка, истек ли оффер
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  // Проверка, доступен ли оффер
  bool get isAvailable => !isExpired && availableQuantity > 0;

  // Процент скидки
  int get discountPercentage {
    if (originalPrice == 0) return 0;
    return (((originalPrice - discountPrice) / originalPrice) * 100).round();
  }

  // Преобразование из Map в OfferModel
  factory OfferModel.fromMap(Map<String, dynamic> map, String id) {
    return OfferModel(
      id: id,
      restaurantId: map['restaurantId'] ?? '',
      dishName: map['dishName'] ?? '',
      description: map['description'] ?? '',
      originalPrice: (map['originalPrice'] ?? 0.0).toDouble(),
      discountPrice: (map['discountPrice'] ?? 0.0).toDouble(),
      availableQuantity: map['availableQuantity'] ?? 0,
      photoUrl: map['photoUrl'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      expiresAt: (map['expiresAt'] as Timestamp).toDate(),
    );
  }

  // Преобразование из OfferModel в Map
  Map<String, dynamic> toMap() {
    return {
      'restaurantId': restaurantId,
      'dishName': dishName,
      'description': description,
      'originalPrice': originalPrice,
      'discountPrice': discountPrice,
      'availableQuantity': availableQuantity,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
    };
  }

  // Копирование с изменениями
  OfferModel copyWith({
    String? id,
    String? restaurantId,
    String? dishName,
    String? description,
    double? originalPrice,
    double? discountPrice,
    int? availableQuantity,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return OfferModel(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      dishName: dishName ?? this.dishName,
      description: description ?? this.description,
      originalPrice: originalPrice ?? this.originalPrice,
      discountPrice: discountPrice ?? this.discountPrice,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
} 