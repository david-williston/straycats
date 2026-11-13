import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/features/cats/data/cats_folder.dart';
import 'package:straycats/src/features/cats/data/device_cat_repository.dart';

import '../../../helpers.dart';

void main() {
  late Directory dir;
  late DeviceCatRepository repo;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('cats');
    repo = DeviceCatRepository(CatsFolder(dir: () async => dir));
  });
  tearDown(() => dir.deleteSync(recursive: true));

  test('saved cats are loaded again', () async {
    final cats = [
      cat('1', 'Ninja', [1000]),
      cat('2', '', [2000]),
    ];
    await repo.saveCats(cats);

    final again = await DeviceCatRepository(CatsFolder(dir: () async => dir))
        .loadCats();
    expect(again, cats);
  });

  test('builds a cat from each photo when there is no cats.json', () async {
    File('${dir.path}/1000.jpg').writeAsBytesSync([1]);
    File('${dir.path}/2000.jpg').writeAsBytesSync([2]);

    final cats = await repo.loadCats();

    expect(cats, hasLength(2));
    expect(cats.every((c) => c.name.isEmpty), isTrue);
    expect(File('${dir.path}/1000.jpg').existsSync(), isTrue);
    expect(File('${dir.path}/cats.json').existsSync(), isTrue);
  });

  test('sets a corrupt cats.json aside and rebuilds', () async {
    File('${dir.path}/1000.jpg').writeAsBytesSync([1]);
    File('${dir.path}/cats.json').writeAsStringSync('{not json');

    final cats = await repo.loadCats();

    expect(cats, hasLength(1));
    expect(
      dir.listSync().any((f) => f.path.contains('cats.json.bad-')),
      isTrue,
    );
  });

  test('a folder that cannot be read throws, and saves nothing', () async {
    final broken = DeviceCatRepository(
      CatsFolder(dir: () async => throw const FileSystemException('no')),
    );
    await expectLater(broken.loadCats(), throwsA(isA<FileSystemException>()));
  });
}
