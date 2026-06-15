import 'package:flutter/material.dart';

import '../models/saved_character.dart';
import '../services/database_helper.dart';
import '../services/preferences_service.dart';
import '../widgets/saved_character_tile.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({
    super.key,
    required this.database,
    required this.preferences,
  });

  final DatabaseHelper database;
  final PreferencesService preferences;

  @override
  State<FavoritesScreen> createState() => FavoritesScreenState();
}

class FavoritesScreenState extends State<FavoritesScreen> {
  List<SavedCharacter> _savedCharacters = [];
  FavoriteSortOrder _sortOrder = FavoriteSortOrder.savedAt;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> loadFavorites() async {
    await _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    final sortOrder = await widget.preferences.getFavoriteSortOrder();
    final saved = await widget.database.getAllSavedCharacters(
      sortOrder: sortOrder,
    );

    if (!mounted) return;

    setState(() {
      _sortOrder = sortOrder;
      _savedCharacters = saved;
      _isLoading = false;
    });
  }

  Future<void> _changeSortOrder(FavoriteSortOrder sortOrder) async {
    if (sortOrder == _sortOrder) {
      return;
    }

    await widget.preferences.setFavoriteSortOrder(sortOrder);
    await _loadFavorites();
  }

  Future<void> _deleteCharacter(SavedCharacter character) async {
    await widget.database.deleteSavedCharacter(character.id);
    await _loadFavorites();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed ${character.name} from favorites')),
    );
  }

  Future<void> _clearAll() async {
    if (_savedCharacters.isEmpty) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear all favorites?'),
          content: const Text(
            'This removes every saved character from local storage. This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Clear all'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await widget.database.clearAllSavedCharacters();
    await _loadFavorites();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All favorites cleared')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: SegmentedButton<FavoriteSortOrder>(
                  segments: const [
                    ButtonSegment(
                      value: FavoriteSortOrder.savedAt,
                      label: Text('Recent'),
                      icon: Icon(Icons.schedule),
                    ),
                    ButtonSegment(
                      value: FavoriteSortOrder.name,
                      label: Text('Name'),
                      icon: Icon(Icons.sort_by_alpha),
                    ),
                  ],
                  selected: {_sortOrder},
                  onSelectionChanged: (selection) {
                    _changeSortOrder(selection.first);
                  },
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _savedCharacters.isEmpty ? null : _clearAll,
                child: const Text('Clear all'),
              ),
            ],
          ),
        ),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading saved favorites...'),
          ],
        ),
      );
    }

    if (_savedCharacters.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bookmark_border,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'No favorites yet',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Browse characters and tap the bookmark icon to save them offline.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _savedCharacters.length,
        itemBuilder: (context, index) {
          final character = _savedCharacters[index];
          return SavedCharacterTile(
            character: character,
            onDelete: () => _deleteCharacter(character),
          );
        },
      ),
    );
  }
}
