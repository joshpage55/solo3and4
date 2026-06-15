import 'package:flutter_test/flutter_test.dart';
import 'package:rick_morty_favorites/models/rick_morty_character.dart';
import 'package:rick_morty_favorites/models/saved_character.dart';

void main() {
  test('RickMortyCharacter parses API JSON', () {
    final character = RickMortyCharacter.fromJson({
      'id': 1,
      'name': 'Rick Sanchez',
      'status': 'Alive',
      'species': 'Human',
      'image': 'https://example.com/rick.png',
    });

    expect(character.id, 1);
    expect(character.name, 'Rick Sanchez');
    expect(character.imageUrl, 'https://example.com/rick.png');
  });

  test('SavedCharacter round-trips through map storage', () {
    final character = RickMortyCharacter.fromJson({
      'id': 2,
      'name': 'Morty Smith',
      'status': 'Alive',
      'species': 'Human',
      'image': 'https://example.com/morty.png',
    });

    final saved = SavedCharacter.fromCharacter(
      character: character,
      note: 'Pilot episode',
    );
    final restored = SavedCharacter.fromMap(saved.toMap());

    expect(restored.id, 2);
    expect(restored.name, 'Morty Smith');
    expect(restored.note, 'Pilot episode');
  });
}
