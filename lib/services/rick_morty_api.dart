import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/rick_morty_character.dart';

class RickMortyApiException implements Exception {
  RickMortyApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class RickMortyApi {
  RickMortyApi({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl = 'https://rickandmortyapi.com/api/character';

  final http.Client _client;

  Future<CharacterListResponse> fetchCharacters({
    String? name,
    int page = 1,
  }) async {
    final query = <String, String>{'page': '$page'};
    if (name != null && name.trim().isNotEmpty) {
      query['name'] = name.trim();
    }

    final uri = Uri.parse(_baseUrl).replace(queryParameters: query);
    final response = await _client.get(uri);

    if (response.statusCode == 404) {
      return const CharacterListResponse(results: [], hasNextPage: false);
    }

    if (response.statusCode != 200) {
      throw RickMortyApiException(
        'Could not load characters (HTTP ${response.statusCode}).',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return CharacterListResponse.fromJson(json);
  }

  void dispose() {
    _client.close();
  }
}
