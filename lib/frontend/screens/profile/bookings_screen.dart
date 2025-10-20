import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noleftovers/l10n/app_localizations.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/booking_card.dart';
import '../../../backend/models/booking_model.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  String _selectedFilter = 'all'; // all, pending, cancelled

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

      if (authProvider.currentUser != null) {
        bookingProvider.loadUserBookings(authProvider.currentUser!.id);
      }
    });
  }

  List<BookingModel> _getFilteredBookings(BookingProvider bookingProvider) {
    switch (_selectedFilter) {
      case 'pending':
        return bookingProvider.activeBookings;
      case 'cancelled':
        return bookingProvider.cancelledBookings;
      case 'all':
      default:
        return bookingProvider.bookings;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bookingProvider = Provider.of<BookingProvider>(context);
    final filteredBookings = _getFilteredBookings(bookingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myBookings),
      ),
      body: Column(
        children: [
          // Фильтры
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Text('${l10n.myBookings} (${bookingProvider.bookings.length})'),
                    selected: _selectedFilter == 'all',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedFilter = 'all';
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: Text('${l10n.pending} (${bookingProvider.activeBookings.length})'),
                    selected: _selectedFilter == 'pending',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedFilter = 'pending';
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: Text('${l10n.cancelled} (${bookingProvider.cancelledBookings.length})'),
                    selected: _selectedFilter == 'cancelled',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedFilter = 'cancelled';
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Список бронирований
          Expanded(
            child: bookingProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredBookings.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noBookings,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
                : RefreshIndicator(
              onRefresh: () async {
                final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
                if (authProvider.currentUser != null) {
                  bookingProvider.loadUserBookings(authProvider.currentUser!.id);
                }
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredBookings.length,
                itemBuilder: (context, index) {
                  final booking = filteredBookings[index];
                  return BookingCard(booking: booking);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}