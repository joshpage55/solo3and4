import 'package:shared_preferences/shared_preferences.dart';

import 'database_helper.dart';

class PreferencesService {
  static const _lastSearchQueryKey = 'last_search_query';
  static const _sortOrderKey = 'favorite_sort_order';

  Future<String> getLastSearchQuery() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSearchQueryKey) ?? '';
  }

  Future<void> setLastSearchQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSearchQueryKey, query);
  }

  Future<FavoriteSortOrder> getFavoriteSortOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_sortOrderKey);
    if (value == FavoriteSortOrder.name.name) {
      return FavoriteSortOrder.name;
    }
    return FavoriteSortOrder.savedAt;
  }

  Future<void> setFavoriteSortOrder(FavoriteSortOrder sortOrder) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sortOrderKey, sortOrder.name);
  }
}
