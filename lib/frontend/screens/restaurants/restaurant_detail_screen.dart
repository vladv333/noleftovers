import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:noleftovers/l10n/app_localizations.dart';
import '../../../backend/models/restaurant_model.dart';
import '../../providers/offer_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../widgets/offer_card.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final RestaurantModel restaurant;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurant,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final offerProvider = Provider.of<OfferProvider>(context, listen: false);
      offerProvider.loadOffersByRestaurant(widget.restaurant.id);
    });
  }

  Future<void> _showBookingDialog(String offerId) async {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);

    print('Booking dialog opened for offer: $offerId'); // Debug

    if (authProvider.currentUser == null) {
      print('User not logged in'); // Debug
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseLogin),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Выбираем время
    final now = DateTime.now();
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: now.hour + 1, minute: 0),
      helpText: l10n.selectPickupTime,
    );

    if (selectedTime == null) {
      print('Time not selected'); // Debug
      return;
    }

    // Создаем DateTime для выбранного времени
    final pickupTime = DateTime(
      now.year,
      now.month,
      now.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    print('Selected pickup time: $pickupTime'); // Debug

    // Показываем подтверждение
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.confirm),
          content: Text(
            '${l10n.pickupTime}: ${DateFormat('HH:mm').format(pickupTime)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      print('Booking not confirmed'); // Debug
      return;
    }

    if (!mounted) return;

    print('Creating booking...'); // Debug

    // Создаем бронирование
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final success = await bookingProvider.createBooking(
      userId: authProvider.currentUser!.id,
      offerId: offerId,
      restaurantId: widget.restaurant.id,
      pickupTime: pickupTime,
    );

    if (!mounted) return;

    if (success) {
      print('Booking created successfully'); // Debug
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.bookingCreated),
          backgroundColor: Colors.green,
        ),
      );

      // Обновляем список офферов
      final offerProvider = Provider.of<OfferProvider>(context, listen: false);
      offerProvider.loadOffersByRestaurant(widget.restaurant.id);

      // Обновляем количество офферов в списке ресторанов
      final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
      restaurantProvider.refreshOfferCount(widget.restaurant.id);
    } else {
      print('Booking failed: ${bookingProvider.errorMessage}'); // Debug
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingProvider.errorMessage ?? l10n.error),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final offerProvider = Provider.of<OfferProvider>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar с фото ресторана
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.restaurant.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ],
                ),
              ),
              background: widget.restaurant.photoUrl.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: widget.restaurant.photoUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.restaurant, size: 64),
                ),
              )
                  : Container(
                color: Colors.grey[300],
                child: const Icon(Icons.restaurant, size: 64),
              ),
            ),
          ),

          // Информация о ресторане
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Описание
                  Text(
                    l10n.description,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.restaurant.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  // Адрес
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.restaurant.address,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Часы работы
                  Text(
                    l10n.openingHours,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...widget.restaurant.openingHours.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              entry.key,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            entry.value,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

                  // Заголовок офферов
                  Text(
                    l10n.offers,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Список офферов
          offerProvider.isLoading
              ? const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            ),
          )
              : offerProvider.offers.isEmpty
              ? SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2,
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
              ),
            ),
          )
              : SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final offer = offerProvider.offers[index];
                  return GestureDetector(
                    onTap: () {
                      print('Offer tapped: ${offer.id}'); // Debug
                      if (offer.isAvailable) {
                        _showBookingDialog(offer.id);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.noOffersAvailable),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                    child: OfferCard(
                      offer: offer,
                      onTap: null, // Убираем onTap из OfferCard
                    ),
                  );
                },
                childCount: offerProvider.offers.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}