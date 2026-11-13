import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/firebase_providers.dart';
import '../../auth/data/auth_repository.dart';

part 'photo_storage.g.dart';

/// The remote photos, `users/{uid}/photos/{photoId}.jpg`. Photos are private:
/// they are read only through the owner-checked Storage API, never through a
/// download URL.
abstract class PhotoStorage {
  /// Uploads [photoId] under [uid]. Throws unless [uid] is the signed-in
  /// user, so a photo never goes up under another account.
  Future<void> upload(String uid, String photoId, File file);

  /// Saves [uid]'s photo to [to]. Throws unless [uid] is the signed-in user.
  /// False if there is no such photo.
  Future<bool> download(String uid, String photoId, File to);

  /// Saves a photo of another person, [ownerUid]'s, to [to]. Only an admin
  /// is allowed to (the Storage rules decide). False if there is no such photo.
  Future<bool> downloadOwned(String ownerUid, String photoId, File to);
}

class FirebasePhotoStorage implements PhotoStorage {
  /// [_uid] is read at each call, to check who is signed in.
  FirebasePhotoStorage(this._storage, this._uid);

  final FirebaseStorage _storage;
  final String? Function() _uid;

  Reference _ref(String uid, String photoId) {
    if (_uid() != uid) throw StateError('Not signed in as $uid');
    return _owned(uid, photoId);
  }

  Reference _owned(String ownerUid, String photoId) =>
      _storage.ref('users/$ownerUid/photos/$photoId.jpg');

  @override
  Future<void> upload(String uid, String photoId, File file) async {
    await _ref(
      uid,
      photoId,
    ).putFile(file, SettableMetadata(contentType: 'image/jpeg'));
  }

  @override
  Future<bool> download(String uid, String photoId, File to) =>
      _write(_ref(uid, photoId), to);

  @override
  Future<bool> downloadOwned(String ownerUid, String photoId, File to) =>
      _write(_owned(ownerUid, photoId), to);

  Future<bool> _write(Reference ref, File to) async {
    try {
      await ref.writeToFile(to);
      return true;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') return false;
      rethrow;
    }
  }
}

@Riverpod(keepAlive: true)
PhotoStorage photoStorage(Ref ref) {
  final auth = ref.watch(authRepositoryProvider);
  return FirebasePhotoStorage(
    ref.watch(firebaseStorageProvider),
    () => auth.uid,
  );
}
