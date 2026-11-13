import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/features/cats/data/cats_folder.dart';
import 'package:straycats/src/features/cats/data/fake_photo_storage.dart';
import 'package:straycats/src/features/cats/data/local_photo_cache.dart';

void main() {
  late Directory dir;
  late FakePhotoStorage storage;
  late LocalPhotoCache cache;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('cats');
    storage = FakePhotoStorage();
    cache = LocalPhotoCache('u1', CatsFolder(dir: () async => dir), storage);
  });
  tearDown(() => dir.deleteSync(recursive: true));

  test('a photo on the phone is used as it is', () async {
    File('${dir.path}/1.jpg').writeAsBytesSync([1]);
    storage.failWith = StateError('must not be asked');

    final file = await cache.fileFor('1');

    expect(file!.path, '${dir.path}/1.jpg');
  });

  test('a photo from another device is downloaded once and kept', () async {
    storage.remote['2'] = [2, 2];

    final file = await cache.fileFor('2');

    expect(file!.readAsBytesSync(), [2, 2]);
    expect(File('${dir.path}/2.jpg.part').existsSync(), isFalse);
    storage.remote.clear();
    expect(await cache.fileFor('2'), isNotNull);
  });

  test('offline, or not uploaded yet, gives null', () async {
    expect(await cache.fileFor('3'), isNull);

    storage.failWith = const SocketException('offline');
    expect(await cache.fileFor('3'), isNull);
    expect(dir.listSync(), isEmpty);
  });
}
