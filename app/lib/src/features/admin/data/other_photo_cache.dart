import 'dart:developer' as developer;
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../cats/data/photo_storage.dart';

part 'other_photo_cache.g.dart';

/// Other people's photos, `<cache>/admin/{ownerUid}/{photoId}.jpg`. Kept apart
/// from the person's own photo store (`<documents>/cats/`, which is the upload
/// outbox and is never evicted): the system may clear this folder, photo ids
/// can collide between people, and [clear] empties it.
class OtherPhotoCache {
  OtherPhotoCache(this._root, this._storage);

  final Future<Directory> Function() _root;
  final PhotoStorage _storage;

  static Future<Directory> _cacheAdmin() async =>
      Directory('${(await getApplicationCacheDirectory()).path}/admin');

  static OtherPhotoCache onDevice(PhotoStorage storage) =>
      OtherPhotoCache(_cacheAdmin, storage);

  /// The photo of [ownerUid], fetched the first time. Null if it is not there
  /// and cannot be fetched.
  Future<File?> fileFor(String ownerUid, String photoId) async {
    final root = await _root();
    final dir = await Directory('${root.path}/$ownerUid')
        .create(recursive: true);
    final file = File('${dir.path}/$photoId.jpg');
    if (file.existsSync()) return file;
    final part = File('${file.path}.part');
    try {
      if (!await _storage.downloadOwned(ownerUid, photoId, part)) return null;
      await part.rename(file.path);
      return file;
    } catch (e) {
      developer.log(
        'Could not fetch photo $photoId of $ownerUid: $e',
        name: 'straycats',
      );
      if (part.existsSync()) part.deleteSync();
      return null;
    }
  }

  /// Deletes every cached photo of other people.
  Future<void> clear() async {
    final root = await _root();
    if (root.existsSync()) await root.delete(recursive: true);
  }
}

@Riverpod(keepAlive: true)
OtherPhotoCache otherPhotoCache(Ref ref) =>
    OtherPhotoCache.onDevice(ref.watch(photoStorageProvider));

/// The file for a photo owned by [ownerUid], or null for the placeholder.
@riverpod
Future<File?> ownerPhotoFile(Ref ref, String ownerUid, String photoId) =>
    ref.watch(otherPhotoCacheProvider).fileFor(ownerUid, photoId);
