import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/cat.dart';
import 'package:straycats/cat_store.dart';

void main() {
  test('migrate makes one cat per photo, with names', () {
    final cats = migrate(
      [File('/cats/1000.jpg'), File('/cats/2000.jpg')],
      {'2000.jpg': 'Ciccio', 'gone.jpg': 'Ghost'},
    );

    expect(cats, hasLength(2));
    expect(cats.map((c) => c.name), ['', 'Ciccio']);
    final ciccio = cats[1];
    expect(ciccio.id, '2000');
    expect(ciccio.encounters.single.photo, '2000.jpg');
    expect(
      ciccio.encounters.single.time,
      DateTime.fromMillisecondsSinceEpoch(2000),
    );
    expect(byLastSeen(cats).first, ciccio);
  });

  test('cats survive a round trip through JSON', () {
    final cat = Cat(
      id: '1',
      name: 'Saibo',
      encounters: [
        Encounter(
          id: '5',
          photo: '5.jpg',
          time: DateTime.fromMillisecondsSinceEpoch(5),
          type: EncounterType.earTipped,
        ),
      ],
    );
    final back = Cat.fromJson(
      jsonDecode(jsonEncode(cat.toJson())) as Map<String, dynamic>,
    );
    expect(back.name, 'Saibo');
    expect(back.encounters.single.type, EncounterType.earTipped);
    expect(cat.toJson()['encounters'][0]['type'], 'ear_tipped');
  });

  group('DeviceCatStore', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('cats'));
    tearDown(() => dir.deleteSync(recursive: true));

    test('migrates photos and names.json, keeping both', () async {
      File('${dir.path}/1000.jpg').writeAsBytesSync([1]);
      File('${dir.path}/2000.jpg').writeAsBytesSync([2]);
      final names = File('${dir.path}/names.json')
        ..writeAsStringSync(jsonEncode({'1000.jpg': 'Ninja'}));

      final store = DeviceCatStore(dir: () async => dir);
      final cats = await store.load();

      expect(cats.map((c) => c.name).toSet(), {'Ninja', ''});
      expect(names.existsSync(), isTrue);
      expect(File('${dir.path}/1000.jpg').existsSync(), isTrue);
      expect(File('${dir.path}/cats.json').existsSync(), isTrue);

      // A second load reads cats.json rather than migrating again.
      cats.first.name = 'Renamed';
      await store.save(cats);
      final again = await DeviceCatStore(dir: () async => dir).load();
      expect(again.map((c) => c.name), contains('Renamed'));
    });

    test('sets a corrupt cats.json aside and rebuilds', () async {
      File('${dir.path}/1000.jpg').writeAsBytesSync([1]);
      File('${dir.path}/cats.json').writeAsStringSync('{not json');

      final cats = await DeviceCatStore(dir: () async => dir).load();

      expect(cats, hasLength(1));
      expect(
        dir.listSync().any((f) => f.path.contains('cats.json.bad-')),
        isTrue,
      );
    });
  });
}
