import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/features/cats/domain/cat.dart';
import 'package:straycats/src/features/cats/domain/life.dart';
import 'package:straycats/src/features/cats/domain/life_event.dart';
import 'package:straycats/src/features/cats/domain/partial_date.dart';

import '../../../helpers.dart';

final _now = DateTime(2026, 11, 13);

LifeEvent ev(
  LifeEventType type,
  PartialDate on, {
  String id = '',
  int created = 0,
}) => LifeEvent(
  id: id.isEmpty ? '${type.name}-${on.stored}-$created' : id,
  type: type,
  on: on,
  createdAt: DateTime.fromMillisecondsSinceEpoch(created),
);

LifeView life(List<LifeEvent> events, [List<DateTime> sightings = const []]) =>
    lifeOf(events, sightings, now: _now);

void main() {
  test('once-only is a property of the type', () {
    expect(LifeEventType.values.where((t) => t.onceOnly).toSet(), {
      LifeEventType.born,
      LifeEventType.sterilised,
      LifeEventType.died,
    });
  });

  test('a cat with nothing in its story has no state', () {
    final v = life([], [DateTime(2026, 1, 1)]);
    expect(v.state, LifeState.known);
    expect(v.conflicts, isEmpty);
    expect(v.nudge, isNull);
    expect(v.stateEvent, isNull);
  });

  test('born and sterilised alone say nothing about state', () {
    final v = life([
      ev(LifeEventType.born, const PartialDate.year(2019, around: true)),
      ev(LifeEventType.sterilised, const PartialDate.year(2021)),
    ]);
    expect(v.state, LifeState.known);
    expect(v.conflicts, isEmpty);
    expect(v.events, hasLength(2));
  });

  test('events come back sorted by start, ties by creation', () {
    final late = ev(
      LifeEventType.missing,
      const PartialDate.day(2025, 5, 5),
      created: 9,
    );
    final early = ev(
      LifeEventType.missing,
      const PartialDate.day(2025, 5, 5),
      created: 1,
    );
    final first = ev(LifeEventType.born, const PartialDate.year(2019));
    final v = life([late, first, early]);
    expect(v.events, [first, early, late]);
  });

  group('state', () {
    test('missing shows as missing, since its date', () {
      final m = ev(LifeEventType.missing, const PartialDate.day(2026, 11, 3));
      final v = life([m]);
      expect(v.state, LifeState.missing);
      expect(v.stateEvent, m);
    });

    test('missing then found: found for 30 days, then nothing', () {
      final events = [
        ev(LifeEventType.missing, const PartialDate.day(2026, 10, 1)),
        ev(LifeEventType.found, const PartialDate.day(2026, 11, 12)),
      ];
      expect(life(events).state, LifeState.found);
      final old = [
        ev(LifeEventType.missing, const PartialDate.day(2026, 8, 1)),
        ev(LifeEventType.found, const PartialDate.day(2026, 9, 1)),
      ];
      expect(life(old).state, LifeState.known);
    });

    test('found then missing again is missing', () {
      final v = life([
        ev(LifeEventType.found, const PartialDate.day(2026, 11, 1)),
        ev(LifeEventType.missing, const PartialDate.day(2026, 11, 5)),
      ]);
      expect(v.state, LifeState.missing);
    });

    test('the same day is settled by creation order', () {
      final v = life([
        ev(LifeEventType.found, const PartialDate.day(2026, 11, 5), created: 2),
        ev(
          LifeEventType.missing,
          const PartialDate.day(2026, 11, 5),
          created: 1,
        ),
      ]);
      expect(v.state, LifeState.found);
    });

    test('a death means remembered, whatever comes after', () {
      final v = life([
        ev(LifeEventType.died, const PartialDate.day(2026, 3, 1)),
        ev(LifeEventType.missing, const PartialDate.day(2026, 6, 1)),
      ]);
      expect(v.state, LifeState.remembered);
    });

    test('a single death has no conflict', () {
      final v = life([
        ev(LifeEventType.died, const PartialDate.day(2026, 3, 1)),
      ]);
      expect(v.state, LifeState.remembered);
      expect(v.conflicts, isEmpty);
    });
  });

  group('conflicts between once-only entries', () {
    test('two different deaths: both kept, one conflict', () {
      final a = ev(LifeEventType.died, const PartialDate.year(2024));
      final b = ev(LifeEventType.died, const PartialDate.day(2025, 2, 2));
      final v = life([a, b]);
      expect(v.events, hasLength(2));
      expect(v.conflicts, hasLength(1));
      final c = v.conflicts.single;
      expect(c.kind, ConflictKind.duplicate);
      expect(c.type, LifeEventType.died);
      expect(c.events, [a, b]);
      expect(v.inConflict(a) && v.inConflict(b), isTrue);
      expect(v.state, LifeState.remembered);
    });

    test('overlapping periods agree: no conflict', () {
      expect(
        life([
          ev(LifeEventType.sterilised, const PartialDate.year(2024)),
          ev(LifeEventType.sterilised, const PartialDate.month(2024, 5)),
        ]).conflicts,
        isEmpty,
      );
      expect(
        life([
          ev(LifeEventType.sterilised, const PartialDate.day(2024, 5, 1)),
          ev(LifeEventType.sterilised, const PartialDate.day(2024, 5, 1)),
        ]).conflicts,
        isEmpty,
      );
    });

    test('two births in different years conflict; sterilised too', () {
      final v = life([
        ev(LifeEventType.born, const PartialDate.year(2018)),
        ev(LifeEventType.born, const PartialDate.year(2019, around: true)),
        ev(LifeEventType.sterilised, const PartialDate.year(2020)),
        ev(LifeEventType.sterilised, const PartialDate.year(2022)),
      ]);
      expect(v.conflicts.map((c) => c.type), [
        LifeEventType.born,
        LifeEventType.sterilised,
      ]);
    });

    test('missing and found repeat freely', () {
      final v = life([
        ev(LifeEventType.missing, const PartialDate.day(2025, 1, 1)),
        ev(LifeEventType.found, const PartialDate.day(2025, 1, 5)),
        ev(LifeEventType.missing, const PartialDate.day(2026, 2, 1)),
        ev(LifeEventType.found, const PartialDate.day(2026, 2, 5)),
      ]);
      expect(v.conflicts, isEmpty);
    });
  });

  group('after a death', () {
    final died = ev(LifeEventType.died, const PartialDate.day(2026, 3, 1));

    test('a sighting after it is a question, and overrides nothing', () {
      final v = life([died], [DateTime(2026, 3, 2, 14, 30)]);
      expect(v.state, LifeState.remembered);
      final c = v.conflicts.single;
      expect(c.kind, ConflictKind.sightingAfterDeath);
      expect(c.events, [died]);
      expect(c.sighting, DateTime(2026, 3, 2));
    });

    test('a sighting on the day or before is fine', () {
      expect(life([died], [DateTime(2026, 3, 1, 23)]).conflicts, isEmpty);
      expect(life([died], [DateTime(2025, 12, 1)]).conflicts, isEmpty);
    });

    test('"died in 2024" and a photo in March 2024 is no conflict', () {
      final v = life(
        [ev(LifeEventType.died, const PartialDate.year(2024))],
        [DateTime(2024, 3, 9)],
      );
      expect(v.conflicts, isEmpty);
      expect(
        life(
          [ev(LifeEventType.died, const PartialDate.year(2024))],
          [DateTime(2025, 1, 1)],
        ).conflicts.single.kind,
        ConflictKind.sightingAfterDeath,
      );
    });

    test('found after a death is a conflict, and the death stands', () {
      final found = ev(LifeEventType.found, const PartialDate.day(2026, 4, 1));
      final v = life([died, found]);
      expect(v.state, LifeState.remembered);
      final c = v.conflicts.single;
      expect(c.kind, ConflictKind.foundAfterDeath);
      expect(c.events, [died, found]);
    });

    test('found before a death is no conflict', () {
      final v = life([
        ev(LifeEventType.missing, const PartialDate.day(2026, 1, 1)),
        ev(LifeEventType.found, const PartialDate.day(2026, 1, 20)),
        died,
      ]);
      expect(v.conflicts, isEmpty);
    });
  });

  group('after missing', () {
    final missing = ev(
      LifeEventType.missing,
      const PartialDate.day(2026, 11, 3),
    );

    test('a later sighting is a nudge, not a conflict', () {
      final v = life([missing], [DateTime(2026, 11, 12, 9)]);
      expect(v.state, LifeState.missing);
      expect(v.conflicts, isEmpty);
      expect(v.nudge, DateTime(2026, 11, 12));
    });

    test('a sighting before or on the day is no nudge', () {
      expect(life([missing], [DateTime(2026, 11, 3, 20)]).nudge, isNull);
      expect(life([missing], [DateTime(2026, 10, 1)]).nudge, isNull);
    });

    test('once found, there is no nudge', () {
      final v = life(
        [missing, ev(LifeEventType.found, const PartialDate.day(2026, 11, 12))],
        [DateTime(2026, 11, 12)],
      );
      expect(v.nudge, isNull);
    });
  });

  group('the grid', () {
    test('missing first, remembered last, the rest by last seen', () {
      final ninja = cat('m', 'Ninja', [1000]).copyWith(
        events: [ev(LifeEventType.missing, const PartialDate.day(2026, 11, 3))],
      );
      final saibo = cat('r', 'Saibo', [9000]).copyWith(
        events: [ev(LifeEventType.died, const PartialDate.day(2026, 9, 3))],
      );
      final order = byLastSeen([
        saibo,
        cat('a', 'A', [2000]),
        ninja,
        cat('b', 'B', [4000]),
      ]).map((c) => c.id);
      expect(order, ['m', 'b', 'a', 'r']);
    });

    test('Cat.life derives from its events and encounters', () {
      final c = Cat(
        id: '1',
        encounters: cat('1', '', [
          DateTime(2026, 11, 12).millisecondsSinceEpoch,
        ]).encounters,
        events: [ev(LifeEventType.missing, const PartialDate.day(2026, 11, 3))],
      );
      expect(c.life.state, LifeState.missing);
      expect(c.life.nudge, isNotNull);
    });
  });
}
