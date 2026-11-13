import 'dart:io';

import 'cats_folder.dart';
import 'fake_photo_storage.dart';
import 'local_photo_cache.dart';

/// Hands back `/cats/<id>.jpg` without touching the disk, for widget tests
/// (the image then shows its placeholder, which is fine).
class FakeLocalPhotoCache extends LocalPhotoCache {
  FakeLocalPhotoCache() : super(CatsFolder(), FakePhotoStorage());

  @override
  Future<File?> fileFor(String photoId) async => File('/cats/$photoId.jpg');
}
