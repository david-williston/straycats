import 'dart:async';
import 'dart:io';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/features/cats/application/cat_importer.dart';
import 'package:straycats/src/features/cats/data/cats_folder.dart';
import 'package:straycats/src/features/cats/data/fake_cat_repository.dart';
import 'package:straycats/src/features/cats/data/firestore_cat_repository.dart';
import 'package:straycats/src/features/cats/data/legacy_cats_reader.dart';
import 'package:straycats/src/features/cats/data/photo_outbox.dart';

void main() {
  late Directory dir;
  late CatsFolder folder;
  late PhotoOutbox outbox;
  late FakeFirebaseFirestore db;
  late FirestoreCatRepository target;

  const json =
      '{"version":1,"cats":['
      '{"id":"1000","name":"Ninja","encounters":['
      '{"id":"1000","photo":"1000.jpg","time":1000},'
      '{"id":"3000","photo":"3000.jpg","time":3000,"type":"fed"}]},'
      '{"id":"2000","name":"","encounters":['
      '{"id":"2000","photo":"2000.jpg","time":2000}]}]}';

  CatImporter importer({Duration? timeout}) => CatImporter(
    folder,
    LegacyCatsReader(folder),
    outbox,
    timeout: timeout ?? const Duration(seconds: 5),
  );

  Future<int> count(String collection) async =>
      (await db.collection('users/u1/$collection').get()).docs.length;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('cats');
    folder = CatsFolder(dir: () async => dir);
    outbox = PhotoOutbox(folder);
    db = FakeFirebaseFirestore();
    target = FirestoreCatRepository(db, 'u1');
    File('${dir.path}/cats.json').writeAsStringSync(json);
    for (final id in ['1000', '3000', '2000']) {
      File('${dir.path}/$id.jpg').writeAsBytesSync([1]);
    }
  });
  tearDown(() => dir.deleteSync(recursive: true));

  test('brings the cats over, queues the photos, and marks it done', () async {
    await importer().run(target);

    expect(await count('cats'), 2);
    expect(await count('encounters'), 3);
    final cats = await target.watchCats().first;
    expect(cats.firstWhere((c) => c.id == '1000').name, 'Ninja');
    expect(await outbox.pending(), ['1000', '2000', '3000']);
    expect(File('${dir.path}/cats.json').existsSync(), isFalse);
    expect(File('${dir.path}/cats.json.imported').existsSync(), isTrue);
    expect(File('${dir.path}/1000.jpg').existsSync(), isTrue);
  });

  test('running twice makes no duplicates', () async {
    await importer().run(target);
    await importer().run(target);

    expect(await count('cats'), 2);
    expect(await count('encounters'), 3);
    expect(await outbox.pending(), hasLength(3));
  });

  test('a run that stopped before the rename can be repeated', () async {
    await importer().run(target);
    // As if the app was killed before cats.json was renamed.
    File('${dir.path}/cats.json.imported').renameSync('${dir.path}/cats.json');

    await importer().run(target);

    expect(await count('cats'), 2);
    expect(await count('encounters'), 3);
  });

  test('a corrupt cats.json stops the import and changes nothing', () async {
    File('${dir.path}/cats.json').writeAsStringSync('{not json');

    await expectLater(
      importer().run(target),
      throwsA(isA<LegacyCatsCorrupt>()),
    );

    expect(await count('cats'), 0);
    expect(await outbox.pending(), isEmpty);
    expect(File('${dir.path}/cats.json').readAsStringSync(), '{not json');
    expect(File('${dir.path}/cats.json.imported').existsSync(), isFalse);
  });

  test('offline: times out, keeps cats.json, and a retry works', () async {
    final offline = FakeCatRepository()..importGate = Completer<void>();

    await expectLater(
      importer(timeout: const Duration(milliseconds: 20)).run(offline),
      throwsA(isA<ImportOffline>()),
    );

    expect(File('${dir.path}/cats.json').existsSync(), isTrue);
    expect(File('${dir.path}/cats.json.imported').existsSync(), isFalse);

    await importer().run(target);
    expect(await count('cats'), 2);
    expect(File('${dir.path}/cats.json.imported').existsSync(), isTrue);
  });

  test('a photo that is not on the phone is not queued', () async {
    File('${dir.path}/3000.jpg').deleteSync();

    await importer().run(target);

    expect(await outbox.pending(), ['1000', '2000']);
    expect(await count('encounters'), 3);
  });

  test('with nothing to import, does nothing', () async {
    File('${dir.path}/cats.json').deleteSync();
    for (final f in dir.listSync()) {
      f.deleteSync();
    }
    final repo = FakeCatRepository();

    await importer().run(repo);

    expect(repo.imported, isEmpty);
    expect(db.dump().contains('users'), isFalse);
  });
}
