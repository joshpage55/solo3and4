# Rick & Morty Favorites

Browse Rick & Morty characters from a live API and save your favorites with optional notes so they stay available offline after you close the app.

## API

**Rick and Morty API**

- Base endpoint: `https://rickandmortyapi.com/api/character`
- Search example: `https://rickandmortyapi.com/api/character?name=rick`
- Paginated browse: `https://rickandmortyapi.com/api/character?page=1`

No API key is required.

## Storage strategy

| Storage | What is saved | Why |
|--------|----------------|-----|
| **SQLite** (`sqflite`) | Saved favorite characters (id, name, status, species, image URL, note, saved timestamp) | Structured offline data that users browse, delete, and sort |
| **shared_preferences** | Last search query, favorite sort order | Lightweight settings that should restore instantly on launch without SQL queries |

## Data format

Each saved favorite is one row in the `saved_characters` table:

| Column | Type | Description |
|--------|------|-------------|
| `id` | INTEGER (PK) | Character ID from the API |
| `name` | TEXT | Character name |
| `status` | TEXT | Alive / Dead / unknown |
| `species` | TEXT | e.g. Human, Alien |
| `imageUrl` | TEXT | Portrait image URL |
| `note` | TEXT | Optional user note (episode memory) |
| `savedAt` | INTEGER | Unix milliseconds when saved |

## How to run

1. Install [Flutter](https://docs.flutter.dev/get-started/install) (stable channel).
2. From this folder:

```bash
cd rick_morty_favorites
flutter pub get
flutter run
```

3. Choose a connected device or simulator when prompted.

**Android:** `INTERNET` permission is already declared in `android/app/src/main/AndroidManifest.xml`.

## How to test persistence

1. Launch the app and go to **Browse**.
2. Tap **Browse all characters** (or search for a name).
3. Tap the bookmark icon on at least 5 characters and save them.
4. Open **Favorites** and confirm they appear.
5. Fully close/kill the app (swipe away from recents).
6. Reopen the app → **Favorites** should still list your saved characters.
7. Delete one item, then use **Clear all** to wipe the list.

## Edge cases handled

1. **Empty API results** — Searching for a name that does not exist (API returns 404) shows a friendly “No characters found” screen with a **Clear search** action instead of crashing.
2. **Network / server failure** — Failed requests show an error message and a working **Retry** button. A **Simulate error** toggle on the Browse tab lets you demo this for your video without disconnecting Wi‑Fi.

## Demo video checklist

Your recording should show:

- [ ] App launch with persisted favorites from a previous session
- [ ] API fetch with loading spinner, then results
- [ ] Error state + Retry (use **Simulate error**, then turn it off and tap **Retry**)
- [ ] Saving a character from Browse
- [ ] Favorites screen showing the saved item
- [ ] Deleting one item and using **Clear all**
- [ ] Kill and reopen the app — favorites still present

## AI tools used

This project was built with **Cursor** (AI-assisted coding). AI was used to scaffold the Flutter project structure, model/service/screen files, and this README. All code was reviewed and can be explained line-by-line: HTTP parsing, SQLite schema, shared_preferences keys, and UI state handling (loading / error / empty / success).

## Project structure

```
lib/
  main.dart                 # App shell + bottom navigation
  models/                   # Typed API and SQLite models
  services/                 # API, database, preferences
  screens/                  # Browse + Favorites tabs
  widgets/                  # Reusable list cards
```

## License

Educational project for CPSC 4150 — Solo 3+4.
