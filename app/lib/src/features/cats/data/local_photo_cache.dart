import 'dart:developer' as developer;
import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'cats_folder.dart';
import 'photo_storage.dart';

part 'local_photo_cache.g.dart';

/// Finds a photo on this phone, fetching it from Storage the first time it
/// is wanted on a phone that did not take it.
class LocalPhotoCache {
  LocalPhotoCache(this._folder, this._storage);

  final CatsFolder _folder;
  final PhotoStorage _storage;

  /// The local file, or null when it is not here and cannot be fetched
  /// (offline, or not uploaded yet from another device).
  Future<File?> fileFor(String photoId) async {
    final dir = await _folder.open();
    final file = File('${dir.path}/$photoId.jpg');
    if (file.existsSync()) return file;
    final part = File('${file.path}.part');
    try {
      if (!await _storage.download(photoId, part)) return null;
      await part.rename(file.path);
      return file;
    } catch (e) {
      developer.log('Could not fetch photo $photoId: $e', name: 'straycats');
      if (part.existsSync()) part.deleteSync();
      return null;
    }
  }
}

@Riverpod(keepAlive: true)
LocalPhotoCache localPhotoCache(Ref ref) => LocalPhotoCache(
  ref.watch(catsFolderProvider),
  ref.watch(photoStorageProvider),
);

/// The file for an encounter's photo, or null for the placeholder.
@riverpod
Future<File?> photoFile(Ref ref, String photoId) =>
    ref.watch(localPhotoCacheProvider).fileFor(photoId);
