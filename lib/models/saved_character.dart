import 'rick_morty_character.dart';

class SavedCharacter {
  const SavedCharacter({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.imageUrl,
    required this.note,
    required this.savedAt,
  });

  final int id;
  final String name;
  final String status;
  final String species;
  final String imageUrl;
  final String note;
  final DateTime savedAt;

  factory SavedCharacter.fromCharacter({
    required RickMortyCharacter character,
    String note = '',
  }) {
    return SavedCharacter(
      id: character.id,
      name: character.name,
      status: character.status,
      species: character.species,
      imageUrl: character.imageUrl,
      note: note,
      savedAt: DateTime.now(),
    );
  }

  factory SavedCharacter.fromMap(Map<String, dynamic> map) {
    return SavedCharacter(
      id: map['id'] as int,
      name: map['name'] as String,
      status: map['status'] as String,
      species: map['species'] as String,
      imageUrl: map['imageUrl'] as String,
      note: map['note'] as String? ?? '',
      savedAt: DateTime.fromMillisecondsSinceEpoch(map['savedAt'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'species': species,
      'imageUrl': imageUrl,
      'note': note,
      'savedAt': savedAt.millisecondsSinceEpoch,
    };
  }

  SavedCharacter copyWith({String? note}) {
    return SavedCharacter(
      id: id,
      name: name,
      status: status,
      species: species,
      imageUrl: imageUrl,
      note: note ?? this.note,
      savedAt: savedAt,
    );
  }
}
