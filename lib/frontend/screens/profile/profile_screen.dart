import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noleftovers/l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/language_selector.dart';
import '../auth/login_screen.dart';
import 'bookings_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool showAppBar;

  const ProfileScreen({
    super.key,
    this.showAppBar = true,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    await authProvider.signOut();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  Future<void> _handleDeleteAccount() async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deleteAccount),
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

    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final success = await authProvider.deleteAccount();

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? l10n.error),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AppAuthProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final body = SingleChildScrollView(
      child: Column(
        children: [
          // Шапка профиля
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: Theme.of(context).primaryColor,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Контент
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Кнопка "Мои бронирования"
                Card(
                  child: ListTile(
                    leading: Icon(Icons.receipt_long, color: Theme.of(context).primaryColor),
                    title: Text(l10n.myBookings),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (bookingProvider.activeBookings.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${bookingProvider.activeBookings.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BookingsScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Настройки
                Text(
                  l10n.changeLanguage,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: LanguageSelector(),
                  ),
                ),
                const SizedBox(height: 24),

                // Выход и удаление аккаунта
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text(l10n.logout),
                  onTap: _handleLogout,
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: Text(
                    l10n.deleteAccount,
                    style: const TextStyle(color: Colors.red),
                  ),
                  onTap: _handleDeleteAccount,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (!widget.showAppBar) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        automaticallyImplyLeading: false,
      ),
      body: body,
    );
  }
}