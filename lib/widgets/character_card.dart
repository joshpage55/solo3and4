import 'package:flutter/material.dart';

import '../models/rick_morty_character.dart';

class CharacterCard extends StatelessWidget {
  const CharacterCard({
    super.key,
    required this.character,
    required this.isSaved,
    required this.onSave,
  });

  final RickMortyCharacter character;
  final bool isSaved;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                character.imageUrl,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                semanticLabel: '${character.name} portrait',
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 72,
                  height: 72,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    character.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text('${character.status} · ${character.species}'),
                ],
              ),
            ),
            IconButton(
              onPressed: isSaved ? null : onSave,
              tooltip: isSaved ? 'Already saved' : 'Save to favorites',
              icon: Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_add_outlined,
                color: isSaved ? Colors.grey : Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
