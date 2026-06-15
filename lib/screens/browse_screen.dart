import 'package:flutter/material.dart';

import '../models/rick_morty_character.dart';
import '../models/saved_character.dart';
import '../services/database_helper.dart';
import '../services/preferences_service.dart';
import '../services/rick_morty_api.dart';
import '../widgets/character_card.dart';

enum BrowseState { initial, loading, success, error }

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({
    super.key,
    required this.api,
    required this.database,
    required this.preferences,
    required this.onFavoriteSaved,
  });

  final RickMortyApi api;
  final DatabaseHelper database;
  final PreferencesService preferences;
  final VoidCallback onFavoriteSaved;

  @override
  State<BrowseScreen> createState() => BrowseScreenState();
}

class BrowseScreenState extends State<BrowseScreen> {
  final _searchController = TextEditingController();
  final _savedIds = <int>{};

  BrowseState _state = BrowseState.initial;
  List<RickMortyCharacter> _characters = [];
  String? _errorMessage;
  bool _hasNextPage = false;
  int _currentPage = 1;
  bool _simulateError = false;

  @override
  void initState() {
    super.initState();
    _loadPreferencesAndSavedIds();
  }

  Future<void> _loadPreferencesAndSavedIds() async {
    final lastQuery = await widget.preferences.getLastSearchQuery();
    if (lastQuery.isNotEmpty) {
      _searchController.text = lastQuery;
    }
    await _refreshSavedIds();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _refreshSavedIds() async {
    final saved = await widget.database.getAllSavedCharacters();
    _savedIds
      ..clear()
      ..addAll(saved.map((item) => item.id));
  }

  Future<void> fetchCharacters({bool resetPage = true}) async {
    if (resetPage) {
      _currentPage = 1;
    }

    setState(() {
      _state = BrowseState.loading;
      _errorMessage = null;
    });

    if (_simulateError) {
      setState(() {
        _state = BrowseState.error;
        _errorMessage =
            'Simulated network error. Tap Retry to fetch real data again.';
      });
      return;
    }

    try {
      final query = _searchController.text.trim();
      await widget.preferences.setLastSearchQuery(query);

      final response = await widget.api.fetchCharacters(
        name: query.isEmpty ? null : query,
        page: _currentPage,
      );

      if (!mounted) return;

      setState(() {
        _characters = response.results;
        _hasNextPage = response.hasNextPage;
        _state = BrowseState.success;
      });
    } on RickMortyApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _state = BrowseState.error;
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _state = BrowseState.error;
        _errorMessage =
            'Something went wrong while loading characters. Check your connection and try again.';
      });
    }
  }

  Future<void> _loadNextPage() async {
    if (!_hasNextPage || _state == BrowseState.loading) {
      return;
    }

    setState(() {
      _state = BrowseState.loading;
    });

    try {
      final query = _searchController.text.trim();
      final response = await widget.api.fetchCharacters(
        name: query.isEmpty ? null : query,
        page: _currentPage + 1,
      );

      if (!mounted) return;

      setState(() {
        _currentPage += 1;
        _characters = [..._characters, ...response.results];
        _hasNextPage = response.hasNextPage;
        _state = BrowseState.success;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _state = BrowseState.error;
        _errorMessage = 'Could not load the next page. Pull to refresh and try again.';
      });
    }
  }

  Future<void> _saveCharacter(RickMortyCharacter character) async {
    final note = await _promptForNote(character.name);
    if (note == null) {
      return;
    }

    final saved = SavedCharacter.fromCharacter(
      character: character,
      note: note,
    );
    await widget.database.insertSavedCharacter(saved);
    await _refreshSavedIds();
    widget.onFavoriteSaved();

    if (!mounted) return;

    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${character.name} saved to favorites')),
    );
  }

  Future<String?> _promptForNote(String characterName) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Save $characterName'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Episode note (optional)',
              hintText: 'e.g. Best in Pickle Rick',
            ),
            maxLines: 2,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    return result ?? '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search characters',
                    hintText: 'Try Rick, Morty, Summer...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => fetchCharacters(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: fetchCharacters,
                child: const Text('Search'),
              ),
            ],
          ),
        ),
        SwitchListTile(
          title: const Text('Simulate error (for demo video)'),
          subtitle: const Text('Turn off, then tap Retry to recover'),
          value: _simulateError,
          onChanged: (value) {
            setState(() {
              _simulateError = value;
            });
            if (value) {
              fetchCharacters();
            }
          },
        ),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case BrowseState.initial:
        return _EmptyPrompt(
          icon: Icons.travel_explore,
          title: 'Discover characters',
          message:
              'Search the Rick & Morty API or tap Search with an empty field to browse everyone.',
          actionLabel: 'Browse all characters',
          onAction: fetchCharacters,
        );
      case BrowseState.loading:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading characters...'),
            ],
          ),
        );
      case BrowseState.error:
        return _EmptyPrompt(
          icon: Icons.cloud_off,
          title: 'Could not load characters',
          message: _errorMessage ?? 'Unknown error',
          actionLabel: 'Retry',
          onAction: () {
            if (_simulateError) {
              setState(() {
                _simulateError = false;
              });
            }
            fetchCharacters();
          },
        );
      case BrowseState.success:
        if (_characters.isEmpty) {
          return _EmptyPrompt(
            icon: Icons.person_search,
            title: 'No characters found',
            message:
                'The API returned an empty list for "${_searchController.text.trim()}". Try another name.',
            actionLabel: 'Clear search',
            onAction: () {
              _searchController.clear();
              fetchCharacters();
            },
          );
        }

        return RefreshIndicator(
          onRefresh: () => fetchCharacters(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _characters.length + (_hasNextPage ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _characters.length) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: OutlinedButton(
                    onPressed: _loadNextPage,
                    child: const Text('Load more'),
                  ),
                );
              }

              final character = _characters[index];
              return CharacterCard(
                character: character,
                isSaved: _savedIds.contains(character.id),
                onSave: () => _saveCharacter(character),
              );
            },
          ),
        );
    }
  }
}

class _EmptyPrompt extends StatelessWidget {
  const _EmptyPrompt({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
