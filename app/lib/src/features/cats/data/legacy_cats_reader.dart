import 'dart:convert';
import 'dart:io';

import '../domain/cat.dart';
import '../domain/encounter.dart';
import 'cats_folder.dart';
import 'photo_files.dart';

/// `cats.json` exists but cannot be read. The import stops rather than
/// importing a guess, and leaves the file alone.
class LegacyCatsCorrupt implements Exception {
  const LegacyCatsCorrupt(this.cause);

  final Object cause;

  @override
  String toString() => 'LegacyCatsCorrupt: $cause';
}

/// Reads the cats the app kept in `cats.json` before Firebase. Used only by
/// the one-time import; `cats.json.imported` marks it done.
class LegacyCatsReader {
  LegacyCatsReader(this._folder);

  final CatsFolder _folder;

  /// The legacy cats, or null when there is nothing to import. With no
  /// `cats.json` (and no earlier import) cats are rebuilt from the photos,
  /// each photo its own cat with one encounter. Throws [LegacyCatsCorrupt]
  /// for a `cats.json` that cannot be parsed.
  Future<List<Cat>?> read() async {
    final dir = await _folder.open();
    final file = File('${dir.path}/cats.json');
    if (file.existsSync()) {
      try {
        final json = jsonDecode(await file.readAsString());
        return [
          for (final c
              in (json as Map<String, dynamic>)['cats'] as List<dynamic>)
            Cat.fromJson(c as Map<String, dynamic>),
        ];
      } catch (e) {
        throw LegacyCatsCorrupt(e);
      }
    }
    if (File('${dir.path}/cats.json.imported').existsSync()) return null;
    final photos = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.jpg'))
        .toList();
    return photos.isEmpty ? null : catsFromPhotos(photos);
  }

  /// Renames `cats.json` to `cats.json.imported`: the backup and the done
  /// marker.
  Future<void> markImported() async {
    final dir = await _folder.open();
    final file = File('${dir.path}/cats.json');
    final done = '${dir.path}/cats.json.imported';
    if (file.existsSync()) {
      await file.rename(done);
    } else {
      await File(done).writeAsString('');
    }
  }
}

/// One cat per photo, each with one encounter.
List<Cat> catsFromPhotos(List<File> photos) => [
  for (final photo in photos)
    Cat(
      id: photoName(photo).split('.').first,
      encounters: [
        Encounter(
          id: photoName(photo).split('.').first,
          photoId: photoName(photo).split('.').first,
          time: photoTime(photo),
        ),
      ],
    ),
];
