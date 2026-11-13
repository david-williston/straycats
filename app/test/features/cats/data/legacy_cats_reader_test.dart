import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/features/cats/data/cats_folder.dart';
import 'package:straycats/src/features/cats/data/legacy_cats_reader.dart';

import '../../../helpers.dart';

void main() {
  late Directory dir;
  late LegacyCatsReader reader;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('cats');
    reader = LegacyCatsReader(CatsFolder(dir: () async => dir));
  });
  tearDown(() => dir.deleteSync(recursive: true));

  test('reads the cats in cats.json', () async {
    final cats = [
      cat('1', 'Ninja', [1000]),
      cat('2', '', [2000]),
    ];
    File('${dir.path}/cats.json').writeAsStringSync(
      jsonEncode({
        'version': 1,
        'cats': [for (final c in cats) c.toJson()],
      }),
    );

    expect(await reader.read(), cats);
  });

  test('builds a cat from each photo when there is no cats.json', () async {
    File('${dir.path}/1000.jpg').writeAsBytesSync([1]);
    File('${dir.path}/2000.jpg').writeAsBytesSync([2]);

    final cats = await reader.read();

    expect(cats, hasLength(2));
    expect(cats!.every((c) => c.name.isEmpty), isTrue);
    expect(cats.map((c) => c.encounters.single.photoId).toSet(), {
      '1000',
      '2000',
    });
  });

  test('an empty folder has nothing to import', () async {
    expect(await reader.read(), isNull);
  });

  test('a corrupt cats.json throws and is left alone', () async {
    File('${dir.path}/1000.jpg').writeAsBytesSync([1]);
    File('${dir.path}/cats.json').writeAsStringSync('{not json');

    await expectLater(reader.read(), throwsA(isA<LegacyCatsCorrupt>()));

    expect(File('${dir.path}/cats.json').readAsStringSync(), '{not json');
    expect(dir.listSync().length, 2);
  });

  test('marking it imported renames cats.json and ends the import', () async {
    File('${dir.path}/1000.jpg').writeAsBytesSync([1]);
    File('${dir.path}/cats.json').writeAsStringSync('{"cats": []}');

    await reader.markImported();

    expect(File('${dir.path}/cats.json').existsSync(), isFalse);
    expect(File('${dir.path}/cats.json.imported').existsSync(), isTrue);
    expect(await reader.read(), isNull);
  });

  test('a folder that cannot be read throws', () async {
    final broken = LegacyCatsReader(
      CatsFolder(dir: () async => throw const FileSystemException('no')),
    );
    await expectLater(broken.read(), throwsA(isA<FileSystemException>()));
  });
}
