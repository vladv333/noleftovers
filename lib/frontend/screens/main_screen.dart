import 'package:flutter/material.dart';
import 'package:noleftovers/l10n/app_localizations.dart';
import 'restaurants/restaurants_list_screen.dart';
import 'map/map_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _screens = [
      const RestaurantsListScreen(showAppBar: false),
      const MapScreen(showAppBar: false),
      const ProfileScreen(showAppBar: false),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(l10n)),
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.restaurant),
            label: l10n.restaurants,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map),
            label: l10n.map,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }

  String _getTitle(AppLocalizations l10n) {
    switch (_currentIndex) {
      case 0:
        return l10n.restaurants;
      case 1:
        return l10n.map;
      case 2:
        return l10n.profile;
      default:
        return l10n.appTitle;
    }
  }
}