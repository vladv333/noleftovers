import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:noleftovers/l10n/app_localizations.dart';
import '../../backend/models/restaurant_model.dart';
import '../screens/restaurants/restaurant_detail_screen.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;
  final int offerCount;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.offerCount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RestaurantDetailScreen(restaurant: restaurant),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Фото ресторана
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: restaurant.photoUrl.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: restaurant.photoUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.restaurant, size: 64),
                ),
              )
                  : Container(
                height: 200,
                color: Colors.grey[300],
                child: const Icon(Icons.restaurant, size: 64),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Название ресторана
                  Text(
                    restaurant.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Адрес
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restaurant.address,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Количество офферов
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: offerCount > 0
                          ? Theme.of(context).primaryColor.withOpacity(0.1)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_offer,
                          size: 16,
                          color: offerCount > 0
                              ? Theme.of(context).primaryColor
                              : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$offerCount ${l10n.offers}',
                          style: TextStyle(
                            color: offerCount > 0
                                ? Theme.of(context).primaryColor
                                : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}