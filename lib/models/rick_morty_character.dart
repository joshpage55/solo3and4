class RickMortyCharacter {
  const RickMortyCharacter({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.imageUrl,
  });

  final int id;
  final String name;
  final String status;
  final String species;
  final String imageUrl;

  factory RickMortyCharacter.fromJson(Map<String, dynamic> json) {
    return RickMortyCharacter(
      id: json['id'] as int,
      name: json['name'] as String,
      status: json['status'] as String,
      species: json['species'] as String,
      imageUrl: json['image'] as String,
    );
  }
}

class CharacterListResponse {
  const CharacterListResponse({
    required this.results,
    required this.hasNextPage,
  });

  final List<RickMortyCharacter> results;
  final bool hasNextPage;

  factory CharacterListResponse.fromJson(Map<String, dynamic> json) {
    final info = json['info'] as Map<String, dynamic>;
    final rawResults = json['results'] as List<dynamic>;

    return CharacterListResponse(
      results: rawResults
          .map((item) => RickMortyCharacter.fromJson(item as Map<String, dynamic>))
          .toList(),
      hasNextPage: info['next'] != null,
    );
  }
}
