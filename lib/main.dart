import 'package:flutter/material.dart';

import 'screens/browse_screen.dart';
import 'screens/favorites_screen.dart';
import 'services/database_helper.dart';
import 'services/preferences_service.dart';
import 'services/rick_morty_api.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RickMortyFavoritesApp());
}

class RickMortyFavoritesApp extends StatelessWidget {
  const RickMortyFavoritesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rick & Morty Favorites',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = RickMortyApi();
  final _database = DatabaseHelper.instance;
  final _preferences = PreferencesService();
  final _favoritesKey = GlobalKey<FavoritesScreenState>();

  int _selectedIndex = 0;
  int _favoriteCount = 0;

  @override
  void initState() {
    super.initState();
    _loadFavoriteCount();
  }

  Future<void> _loadFavoriteCount() async {
    final count = await _database.savedCharacterCount();
    if (!mounted) return;
    setState(() {
      _favoriteCount = count;
    });
  }

  void _onFavoriteSaved() {
    _loadFavoriteCount();
    _favoritesKey.currentState?.loadFavorites();
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Browse Characters' : 'My Favorites'),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          BrowseScreen(
            api: _api,
            database: _database,
            preferences: _preferences,
            onFavoriteSaved: _onFavoriteSaved,
          ),
          FavoritesScreen(
            key: _favoritesKey,
            database: _database,
            preferences: _preferences,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 1) {
            _favoritesKey.currentState?.loadFavorites();
          }
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Browse',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _favoriteCount > 0,
              label: Text('$_favoriteCount'),
              child: const Icon(Icons.bookmark_outline),
            ),
            selectedIcon: Badge(
              isLabelVisible: _favoriteCount > 0,
              label: Text('$_favoriteCount'),
              child: const Icon(Icons.bookmark),
            ),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
