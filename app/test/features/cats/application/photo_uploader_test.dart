import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/features/cats/application/photo_uploader.dart';
import 'package:straycats/src/features/cats/data/cats_folder.dart';
import 'package:straycats/src/features/cats/data/fake_photo_storage.dart';
import 'package:straycats/src/features/cats/data/photo_outbox.dart';

void main() {
  late Directory dir;
  late PhotoOutbox outbox;
  late FakePhotoStorage storage;
  late PhotoUploader uploader;
  String? signedIn = 'u1';
  setUp(() {
    signedIn = 'u1';
    dir = Directory.systemTemp.createTempSync('cats');
    final folder = CatsFolder(dir: () async => dir);
    outbox = PhotoOutbox(folder);
    storage = FakePhotoStorage();
    uploader = PhotoUploader(
      'u1',
      () => signedIn,
      folder,
      outbox,
      storage,
      interval: null,
    );
  });
  tearDown(() => dir.deleteSync(recursive: true));

  void photo(String id) => File('${dir.path}/$id.jpg').writeAsBytesSync([7]);

  test('uploads every queued photo and clears its marker', () async {
    photo('1');
    photo('2');
    await outbox.enqueue('1');
    await outbox.enqueue('2');

    await uploader.drain();

    expect(storage.uploaded, ['1', '2']);
    expect(await outbox.pending(), isEmpty);
    expect(File('${dir.path}/1.jpg').existsSync(), isTrue);
  });

  test('a failure keeps the marker, and the next try uploads it', () async {
    photo('1');
    await outbox.enqueue('1');
    storage.failWith = const SocketException('offline');

    await uploader.drain();
    expect(await outbox.pending(), ['1']);
    expect(storage.uploaded, isEmpty);

    storage.failWith = null;
    await uploader.drain();
    expect(storage.uploaded, ['1']);
    expect(await outbox.pending(), isEmpty);
  });

  test('a failure stops the run, so later photos wait', () async {
    photo('1');
    photo('2');
    await outbox.enqueue('1');
    await outbox.enqueue('2');
    storage.failWith = const SocketException('offline');

    await uploader.drain();

    expect(await outbox.pending(), ['1', '2']);
  });

  test('a marker whose photo is gone is dropped', () async {
    photo('2');
    await outbox.enqueue('1');
    await outbox.enqueue('2');

    await uploader.drain();

    expect(storage.uploaded, ['2']);
    expect(await outbox.pending(), isEmpty);
  });

  test('enqueue writes the marker and uploads in the background', () async {
    photo('9');

    await uploader.enqueue('9');
    expect(await outbox.pending(), ['9']);
    await uploader.drain();

    expect(storage.uploaded, ['9']);
    expect(await outbox.pending(), isEmpty);
  });

  test('overlapping drains share one run', () async {
    photo('1');
    await outbox.enqueue('1');

    await Future.wait([uploader.drain(), uploader.drain()]);

    expect(storage.uploaded, ['1']);
  });

  test('uploads under the uid whose folder the photo came from', () async {
    photo('1');
    await outbox.enqueue('1');

    await uploader.drain();

    expect(storage.uploadedBy, ['u1/1']);
  });

  test(
    'another account signed in: nothing uploads, and stays queued',
    () async {
      photo('1');
      await outbox.enqueue('1');
      signedIn = 'u2';

      await uploader.drain();

      expect(storage.uploaded, isEmpty);
      expect(await outbox.pending(), ['1']);

      signedIn = null; // signed out
      await uploader.drain();
      expect(storage.uploaded, isEmpty);

      signedIn = 'u1'; // the account signs in again
      await uploader.drain();
      expect(storage.uploadedBy, ['u1/1']);
      expect(await outbox.pending(), isEmpty);
    },
  );

  test('counts the photos still waiting', () async {
    photo('1');
    await outbox.enqueue('1');
    await outbox.enqueue('2');

    expect(await uploader.pendingCount(), 2);
  });
}
