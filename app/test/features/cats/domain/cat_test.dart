import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/features/cats/domain/cat.dart';
import 'package:straycats/src/features/cats/domain/encounter.dart';
import 'package:straycats/src/features/cats/domain/encounter_details.dart';

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
          details: EncounterDetails(
            activity: Activity.eating,
            conditions: [Condition.thin, Condition.earTipped],
            care: [Care.fed, Care.gaveWater],
            note: 'Only eats if you sit with her',
          ),
        ),
      ],
    );
    final back = Cat.fromJson(
      jsonDecode(jsonEncode(cat.toJson())) as Map<String, dynamic>,
    );
    expect(back, cat);
    expect(back.name, 'Saibo');
    expect(back.encounters.single.details.conditions, [
      Condition.thin,
      Condition.earTipped,
    ]);
    final json = cat.toJson()['encounters'][0] as Map<String, dynamic>;
    expect(json['activity'], 'eating');
    expect(json['conditions'], ['thin', 'ear_tipped']);
    expect(json['care'], ['fed', 'gave_water']);
    expect(json.containsKey('type'), isFalse);
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

  test('an old single type maps onto the new fields', () {
    EncounterDetails old(String? type) =>
        EncounterDetails.fromStored(legacyType: type);
    expect(old('fed').care, [Care.fed]);
    expect(old('fed').conditions, isEmpty);
    expect(old('unwell').conditions, [Condition.unwellOrInjured]);
    expect(old('kittens').conditions, [Condition.withKittens]);
    expect(old('ear_tipped').conditions, [Condition.earTipped]);
    expect(old('seen').isEmpty, isTrue);
    expect(old('nonsense').isEmpty, isTrue);
    expect(old(null).isEmpty, isTrue);
  });

  test('the legacy cats.json type still reads', () {
    final e = Encounter.fromJson({
      'id': '5',
      'photo': '5.jpg',
      'time': 5,
      'type': 'kittens',
    });
    expect(e.details.conditions, [Condition.withKittens]);
  });

  test('stored codes are parsed in a stable order, unknown ones dropped', () {
    final d = EncounterDetails.fromStored(
      activity: 'walking_by',
      conditions: ['limping', 'bogus', 'healthy', 'limping'],
      care: ['gave_medicine', 'fed'],
      note: 'hi',
      legacyType: 'fed',
    );
    expect(d.activity, Activity.walkingBy);
    expect(d.conditions, [Condition.healthy, Condition.limping]);
    expect(d.care, [Care.fed, Care.gaveMedicine]);
    expect(Activity.parse('nonsense'), isNull);
  });

  test('only filled-in details are stored, and the note is trimmed', () {
    expect(const EncounterDetails().toStored(), isEmpty);
    expect(const EncounterDetails(note: '  \n').isEmpty, isTrue);
    expect(const EncounterDetails(note: ' hi ').toStored(), {'note': 'hi'});
  });
}
