import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noleftovers/l10n/app_localizations.dart';
import '../../providers/restaurant_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/restaurant_card.dart';
import '../main_screen.dart';

class RestaurantsListScreen extends StatefulWidget {
  final bool showAppBar;

  const RestaurantsListScreen({
    super.key,
    this.showAppBar = true,
  });

  @override
  State<RestaurantsListScreen> createState() => _RestaurantsListScreenState();
}

class _RestaurantsListScreenState extends State<RestaurantsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
      restaurantProvider.loadRestaurants();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final authProvider = Provider.of<AppAuthProvider>(context);

    final body = restaurantProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : restaurantProvider.restaurants.isEmpty
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noOffersAvailable,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    )
        : RefreshIndicator(
      onRefresh: () async {
        restaurantProvider.loadRestaurants();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: restaurantProvider.restaurants.length,
        itemBuilder: (context, index) {
          final restaurant = restaurantProvider.restaurants[index];
          final offerCount = restaurantProvider.getOfferCount(restaurant.id);

          return RestaurantCard(
            restaurant: restaurant,
            offerCount: offerCount,
          );
        },
      ),
    );

    if (!widget.showAppBar) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.restaurants),
        automaticallyImplyLeading: false,
      ),
      body: body,
    );
  }
}