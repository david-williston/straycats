import 'dart:io';

import 'photo_repository.dart';

/// A fake camera and photo folder, for tests: [takePhoto] hands back
/// [nextPhoto], and [discard] is recorded in [discarded].
class FakePhotoRepository implements PhotoRepository {
  FakePhotoRepository({this.nextPhoto});

  File? nextPhoto;
  final discarded = <File>[];

  @override
  Future<File?> takePhoto() async => nextPhoto;

  @override
  Future<void> discard(File photo) async => discarded.add(photo);

  @override
  File photoFile(String name) => File('/cats/$name');
}
