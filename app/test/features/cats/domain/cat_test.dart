import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/features/cats/domain/cat.dart';
import 'package:straycats/src/features/cats/domain/encounter.dart';
import 'package:straycats/src/features/cats/domain/encounter_type.dart';

import '../../../helpers.dart';

void main() {
  test('cats survive a round trip through JSON', () {
    final cat = Cat(
      id: '1',
      name: 'Saibo',
      encounters: [
        Encounter(
          id: '5',
          photoId: '5',
          time: DateTime.fromMillisecondsSinceEpoch(5),
          type: EncounterType.earTipped,
        ),
      ],
    );
    final back = Cat.fromJson(
      jsonDecode(jsonEncode(cat.toJson())) as Map<String, dynamic>,
    );
    expect(back, cat);
    expect(back.name, 'Saibo');
    expect(back.encounters.single.type, EncounterType.earTipped);
    expect(cat.toJson()['encounters'][0]['type'], 'ear_tipped');
  });

  test('the legacy cats.json names the photo by file', () {
    final e = Encounter.fromJson({'id': '5', 'photo': '5.jpg', 'time': 5});
    expect(e.photoId, '5');
    expect(e.photoFile, '5.jpg');
    expect(e.toJson()['photo'], '5.jpg');
  });

  test('copyWith changes only what it is given', () {
    final original = cat('1', 'Ciccio', [1000]);
    final renamed = original.copyWith(name: 'Ninja');
    expect(renamed.name, 'Ninja');
    expect(renamed.id, '1');
    expect(renamed.encounters, original.encounters);
    expect(original.name, 'Ciccio');
    expect(original.copyWith(), original);
  });

  test('history is newest first, and cats sort by last seen', () {
    final a = cat('1', 'A', [1000, 3000]);
    final b = cat('2', 'B', [2000]);
    expect(a.history.map((e) => e.photoId), ['3000', '1000']);
    expect(a.latest!.photoId, '3000');
    expect(byLastSeen([b, a]), [a, b]);
    expect(const Cat(id: '3').latest, isNull);
  });

  test('an unknown encounter type reads as none', () {
    expect(EncounterType.parse('nonsense'), isNull);
    expect(EncounterType.parse('ear_tipped'), EncounterType.earTipped);
  });
}
