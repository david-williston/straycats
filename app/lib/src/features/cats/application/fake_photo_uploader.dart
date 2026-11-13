import '../data/cats_folder.dart';
import '../data/fake_photo_storage.dart';
import '../data/photo_outbox.dart';
import 'photo_uploader.dart';

/// Does no file or network work, for tests: [enqueue] only records the id in
/// [enqueued].
class FakePhotoUploader extends PhotoUploader {
  FakePhotoUploader()
    : super(CatsFolder(), PhotoOutbox(CatsFolder()), FakePhotoStorage());

  final enqueued = <String>[];
  bool started = false;

  @override
  void start() => started = true;

  @override
  void stop() => started = false;

  @override
  Future<void> enqueue(String photoId) async => enqueued.add(photoId);

  @override
  Future<void> drain() async {}
}
