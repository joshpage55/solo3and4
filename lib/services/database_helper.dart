import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/saved_character.dart';

enum FavoriteSortOrder { name, savedAt }

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const _databaseName = 'rick_morty_favorites.db';
  static const _tableName = 'saved_characters';

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = kIsWeb
        ? _databaseName
        : join(await getDatabasesPath(), _databaseName);

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            status TEXT NOT NULL,
            species TEXT NOT NULL,
            imageUrl TEXT NOT NULL,
            note TEXT NOT NULL DEFAULT '',
            savedAt INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<SavedCharacter>> getAllSavedCharacters({
    FavoriteSortOrder sortOrder = FavoriteSortOrder.savedAt,
  }) async {
    final db = await database;
    final orderBy = sortOrder == FavoriteSortOrder.name
        ? 'name COLLATE NOCASE ASC'
        : 'savedAt DESC';

    final maps = await db.query(_tableName, orderBy: orderBy);
    return maps.map(SavedCharacter.fromMap).toList();
  }

  Future<SavedCharacter?> getSavedCharacter(int id) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return SavedCharacter.fromMap(maps.first);
  }

  Future<void> insertSavedCharacter(SavedCharacter character) async {
    final db = await database;
    await db.insert(
      _tableName,
      character.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteSavedCharacter(int id) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAllSavedCharacters() async {
    final db = await database;
    await db.delete(_tableName);
  }

  Future<int> savedCharacterCount() async {
    final db = await database;
    final result = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_tableName'),
    );
    return result ?? 0;
  }
}
