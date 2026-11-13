import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/features/cats/data/cats_folder.dart';
import 'package:straycats/src/features/cats/data/device_photo_repository.dart';
import 'package:straycats/src/features/cats/data/image_picker_service.dart';

class FakeImagePickerService implements ImagePickerService {
  FakeImagePickerService(this.path);

  final String? path;

  @override
  Future<String?> takePhoto() async => path;
}

void main() {
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('cats'));
  tearDown(() => dir.deleteSync(recursive: true));

  DevicePhotoRepository repo(String? shot) => DevicePhotoRepository(
    CatsFolder(dir: () async => dir),
    FakeImagePickerService(shot),
  );

  test('keeps a taken photo as <millis>.jpg in the cats folder', () async {
    final shot = File('${dir.path}/camera-cache.jpg')..writeAsBytesSync([7]);
    final photos = repo(shot.path);

    final kept = await photos.takePhoto();

    expect(kept, isNotNull);
    expect(kept!.parent.path, dir.path);
    expect(RegExp(r'^\d+\.jpg$').hasMatch(kept.uri.pathSegments.last), isTrue);
    expect(kept.readAsBytesSync(), [7]);
    expect(photos.photoFile('5.jpg').path, '${dir.path}/5.jpg');
  });

  test('a cancelled camera gives no photo', () async {
    expect(await repo(null).takePhoto(), isNull);
  });

  test(
    'discard deletes the photo, and is fine if it is already gone',
    () async {
      final shot = File('${dir.path}/1.jpg')..writeAsBytesSync([1]);
      final photos = repo(null);
      await photos.discard(shot);
      expect(shot.existsSync(), isFalse);
      await photos.discard(shot);
    },
  );
}
