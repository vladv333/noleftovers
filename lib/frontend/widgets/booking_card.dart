import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:noleftovers/l10n/app_localizations.dart';
import '../../backend/models/booking_model.dart';
import '../../backend/models/restaurant_model.dart';
import '../../backend/models/offer_model.dart';
import '../../backend/repositories/restaurant_repository.dart';
import '../../backend/repositories/offer_repository.dart';
import '../providers/booking_provider.dart';
import '../providers/restaurant_provider.dart';

class BookingCard extends StatefulWidget {
  final BookingModel booking;

  const BookingCard({
    super.key,
    required this.booking,
  });

  @override
  State<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  final OfferRepository _offerRepository = OfferRepository();

  RestaurantModel? restaurant;
  OfferModel? offer;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    restaurant = await _restaurantRepository.getRestaurantById(widget.booking.restaurantId);
    offer = await _offerRepository.getOfferById(widget.booking.offerId);

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _handleCancelBooking() async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.cancelBooking),
          content: Text(l10n.areYouSure),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.no),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                l10n.yes,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    print('Cancelling booking: ${widget.booking.id}'); // Debug

    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final success = await bookingProvider.cancelBooking(
      widget.booking.id,
      widget.booking.offerId,
    );

    print('Cancel booking result: $success'); // Debug

    if (!mounted) return;

    if (success) {
      // Обновляем количество офферов для ресторана
      final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
      restaurantProvider.refreshOfferCount(widget.booking.restaurantId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.bookingCancelled),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingProvider.errorMessage ?? l10n.error),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getStatusText(BookingStatus status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case BookingStatus.pending:
        return l10n.pending;
      case BookingStatus.completed:
        return l10n.completed;
      case BookingStatus.cancelled:
        return l10n.cancelled;
    }
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (restaurant == null || offer == null) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ресторан
            Row(
              children: [
                Icon(Icons.restaurant, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    restaurant!.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Оффер
            Text(
              offer!.dishName,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            // Время получения
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${l10n.pickupTime}: ${DateFormat('dd.MM.yyyy HH:mm').format(widget.booking.pickupTime)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Статус
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(widget.booking.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(widget.booking.status),
                    style: TextStyle(
                      color: _getStatusColor(widget.booking.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                // Кнопка отмены (только для pending)
                if (widget.booking.status == BookingStatus.pending)
                  OutlinedButton(
                    onPressed: _handleCancelBooking,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: Text(l10n.cancel),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}