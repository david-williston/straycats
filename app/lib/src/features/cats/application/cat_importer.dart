import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/cat_repository.dart';
import '../data/cats_folder.dart';
import '../data/legacy_cats_reader.dart';
import '../data/photo_outbox.dart';

part 'cat_importer.g.dart';

/// The server did not acknowledge the import in time (offline). The queued
/// write still syncs later, and a retry writes the same data again.
class ImportOffline implements Exception {
  const ImportOffline();
}

/// The one-time move of the cats kept before Firebase (`cats.json` and the
/// photos in the cats folder) into Firestore and the upload outbox.
///
/// Idempotent: the documents keep the ids from the file, so running again
/// rewrites the same documents. `cats.json` is renamed to
/// `cats.json.imported` only after the server acknowledged, so the import
/// never runs again.
class CatImporter {
  CatImporter(
    this._folder,
    this._reader,
    this._outbox, {
    this.timeout = const Duration(seconds: 30),
  });

  final CatsFolder _folder;
  final LegacyCatsReader _reader;
  final PhotoOutbox _outbox;
  final Duration timeout;

  /// Storage rejects photos this large or larger.
  static const _maxPhotoBytes = 10 * 1024 * 1024;

  /// Throws [LegacyCatsCorrupt] (nothing is imported or renamed) or
  /// [ImportOffline].
  Future<void> run(CatRepository target) async {
    final cats = await _reader.read();
    if (cats == null) return;
    final dir = await _folder.open();
    for (final cat in cats) {
      for (final e in cat.encounters) {
        final photo = File('${dir.path}/${e.photoFile}');
        if (!photo.existsSync()) continue;
        if (photo.lengthSync() >= _maxPhotoBytes) {
          developer.log(
            'Photo ${e.photoId} is too big for Storage',
            name: 'straycats',
          );
        }
        await _outbox.enqueue(e.photoId);
      }
    }
    await target
        .importCats(cats)
        .timeout(timeout, onTimeout: () => throw const ImportOffline());
    await _reader.markImported();
  }
}

@Riverpod(keepAlive: true)
CatImporter catImporter(Ref ref) {
  final folder = ref.watch(catsFolderProvider);
  return CatImporter(folder, LegacyCatsReader(folder), PhotoOutbox(folder));
}
