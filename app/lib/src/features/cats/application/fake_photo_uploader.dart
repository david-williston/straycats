import 'dart:io';

import '../data/cats_folder.dart';
import '../data/fake_photo_storage.dart';
import '../data/photo_outbox.dart';
import 'photo_uploader.dart';

/// Does no file or network work, for tests: [enqueue] only records the id in
/// [enqueued]; [pending] is what [pendingCount] reports, and a [drain] leaves
/// [pendingAfterDrain] of them.
class FakePhotoUploader extends PhotoUploader {
  FakePhotoUploader()
    : super(
        'test-uid',
        () => 'test-uid',
        _folder,
        PhotoOutbox(_folder),
        FakePhotoStorage(),
      );

  static final _folder = CatsFolder(dir: () async => Directory('/nonexistent'));

  final enqueued = <String>[];
  bool started = false;
  int pending = 0;
  int pendingAfterDrain = 0;
  int drains = 0;

  @override
  void start() => started = true;

  @override
  void stop() => started = false;

  @override
  Future<void> enqueue(String photoId) async => enqueued.add(photoId);

  @override
  Future<int> pendingCount() async => pending;

  @override
  Future<void> drain() async {
    drains++;
    pending = pendingAfterDrain;
  }
}
