import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantModel {
  final String id;
  final String name;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final String photoUrl;
  final Map<String, String> openingHours; // {'monday': '9:00-18:00', ...}
  final DateTime createdAt;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.photoUrl,
    required this.openingHours,
    required this.createdAt,
  });

  // Преобразование из Map в RestaurantModel
  factory RestaurantModel.fromMap(Map<String, dynamic> map, String id) {
    return RestaurantModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      address: map['address'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      photoUrl: map['photoUrl'] ?? '',
      openingHours: Map<String, String>.from(map['openingHours'] ?? {}),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Преобразование из RestaurantModel в Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'photoUrl': photoUrl,
      'openingHours': openingHours,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Копирование с изменениями
  RestaurantModel copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    String? photoUrl,
    Map<String, String>? openingHours,
    DateTime? createdAt,
  }) {
    return RestaurantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      photoUrl: photoUrl ?? this.photoUrl,
      openingHours: openingHours ?? this.openingHours,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}