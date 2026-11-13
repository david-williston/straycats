import 'dart:io';

import 'photo_storage.dart';

/// Remote photos in memory, for tests. [uploaded] lists the ids uploaded;
/// [failWith] makes every call throw, as without a connection.
class FakePhotoStorage implements PhotoStorage {
  final uploaded = <String>[];

  /// The same uploads as `'$uid/$photoId'`.
  final uploadedBy = <String>[];

  /// Photos by id (the same for every uid; tests use one uid at a time).
  final remote = <String, List<int>>{};
  Object? failWith;

  /// Other people's photos by `'$ownerUid/$photoId'`, and the downloads made.
  final remoteOwned = <String, List<int>>{};
  final downloadedOwned = <String>[];

  @override
  Future<void> upload(String uid, String photoId, File file) async {
    final error = failWith;
    if (error != null) throw error;
    uploaded.add(photoId);
    uploadedBy.add('$uid/$photoId');
    remote[photoId] = file.readAsBytesSync();
  }

  @override
  Future<bool> download(String uid, String photoId, File to) async {
    final error = failWith;
    if (error != null) throw error;
    final bytes = remote[photoId];
    if (bytes == null) return false;
    to.writeAsBytesSync(bytes);
    return true;
  }

  @override
  Future<bool> downloadOwned(String ownerUid, String photoId, File to) async {
    final error = failWith;
    if (error != null) throw error;
    downloadedOwned.add('$ownerUid/$photoId');
    final bytes = remoteOwned['$ownerUid/$photoId'];
    if (bytes == null) return false;
    to.writeAsBytesSync(bytes);
    return true;
  }
}
