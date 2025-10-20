import 'package:noleftovers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../restaurants/restaurant_detail_screen.dart';

class MapScreen extends StatefulWidget {
  final bool showAppBar;

  const MapScreen({
    super.key,
    this.showAppBar = true,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
      if (restaurantProvider.restaurants.isEmpty) {
        restaurantProvider.loadRestaurants();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final restaurantProvider = Provider.of<RestaurantProvider>(context);

    final body = restaurantProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(
          AppConstants.defaultLatitude,
          AppConstants.defaultLongitude,
        ),
        initialZoom: AppConstants.defaultZoom,
        minZoom: 10,
        maxZoom: 18,
      ),
      children: [
        TileLayer(
          urlTemplate: AppConstants.osmTileUrl,
          userAgentPackageName: AppConstants.osmUserAgent,
        ),
        MarkerLayer(
          markers: restaurantProvider.restaurants.map((restaurant) {
            return Marker(
              point: LatLng(restaurant.latitude, restaurant.longitude),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () {
                  _showRestaurantBottomSheet(context, restaurant.id);
                },
                child: Icon(
                  Icons.location_on,
                  color: Theme.of(context).primaryColor,
                  size: 40,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );

    if (!widget.showAppBar) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.map),
        automaticallyImplyLeading: false,
      ),
      body: body,
    );
  }

  void _showRestaurantBottomSheet(BuildContext context, String restaurantId) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
    final restaurant = restaurantProvider.restaurants.firstWhere((r) => r.id == restaurantId);
    final offerCount = restaurantProvider.getOfferCount(restaurantId);
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                restaurant.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                restaurant.address,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '$offerCount ${l10n.offers}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Закрываем bottom sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RestaurantDetailScreen(restaurant: restaurant),
                    ),
                  );
                },
                child: Text(l10n.bookNow),
              ),
            ],
          ),
        );
      },
    );
  }
}