import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:straycats/src/features/cats/application/matching_service.dart';
import 'package:straycats/src/features/places/domain/coarse_area.dart';
import 'package:straycats/src/features/places/domain/geohash.dart';

import '../../../helpers.dart';

const _here = 'ezs42e';

void main() {
  final now = DateTime.fromMillisecondsSinceEpoch(10 * 86400000);
  final dayAgo = now.millisecondsSinceEpoch - 86400000;
  final longAgo = 1000;
  final service = MatchingService();
  final area = CoarseArea.fromGeohash(_here);
  final near = geohashNeighbours(_here).first;

  List<String> order(List<CatMatch> m) => [for (final x in m) x.cat.id];

  group('geohash neighbours', () {
    test('a cell has 8 distinct neighbours of the same length', () {
      final n = geohashNeighbours(_here);
      expect(n, hasLength(8));
      expect(n, isNot(contains(_here)));
      expect(n.every((h) => h.length == 6), isTrue);
    });

    test('known neighbours of ezs42 (east, north, south)', () {
      final n = geohashNeighbours('ezs42');
      expect(n, containsAll(['ezs43', 'ezs48', 'ezs40']));
    });

    test('neighbourhood is symmetric', () {
      for (final n in geohashNeighbours(_here)) {
        expect(geohashNeighbours(n), contains(_here));
      }
    });

    test('wraps across the antimeridian', () {
      final east = encodeGeohash(0.0, 179.9999, precision: 5);
      final west = encodeGeohash(0.0, -179.9999, precision: 5);
      expect(geohashNeighbours(east), contains(west));
      expect(geohashNeighbours(west), contains(east));
    });

    test('has no cells beyond a pole', () {
      final top = encodeGeohash(89.99999, 10, precision: 5);
      expect(geohashNeighbours(top), hasLength(5));
      final bottom = encodeGeohash(-89.99999, 10, precision: 5);
      expect(geohashNeighbours(bottom), hasLength(5));
    });
  });

  group('ranking', () {
    test('same area beats nearby beats far beats unknown', () {
      final cats = [
        catAt('unknown', 'U', [(dayAgo, null)]),
        catAt('far', 'F', [(dayAgo, 'u4pruy')]),
        catAt('nearby', 'N', [(dayAgo, near)]),
        catAt('same', 'S', [(dayAgo, _here)]),
      ];
      final m = service.rank(cats, area: area, now: now);
      expect(order(m), ['same', 'nearby', 'unknown', 'far']);
      expect(m[0].reason, MatchReason.sameArea);
      expect(m[1].reason, MatchReason.nearbyArea);
      expect(m[2].reason, MatchReason.recentlySeen);
    });

    test('a cat met often here outranks one met once', () {
      final cats = [
        catAt('once', 'O', [(dayAgo, _here)]),
        catAt('often', 'F', [
          (dayAgo, _here),
          (dayAgo - 5, _here),
          (dayAgo - 9, _here),
        ]),
      ];
      expect(order(service.rank(cats, area: area, now: now)), [
        'often',
        'once',
      ]);
    });

    test('an old meeting here still beats a recent one far away', () {
      final cats = [
        catAt('far', 'F', [(dayAgo, 'u4pruy')]),
        catAt('old', 'O', [(longAgo, _here)]),
      ];
      expect(order(service.rank(cats, area: area, now: now)), ['old', 'far']);
    });

    test('without an area, the most recently seen comes first', () {
      final cats = [
        catAt('a', 'A', [(longAgo, _here)]),
        catAt('b', 'B', [(dayAgo, 'u4pruy')]),
      ];
      final m = service.rank(cats, now: now);
      expect(order(m), ['b', 'a']);
      expect(m.every((x) => x.reason == MatchReason.recentlySeen), isTrue);
    });

    test('findMatches ranks the same way and ignores the photo for now', () {
      final cats = [
        cat('1', 'A', [1000]),
        cat('2', 'B', [2000]),
      ];
      final m = service.findMatches(File('/cats/9.jpg'), cats, now: now);
      expect(order(m), ['2', '1']);
    });
  });

  group('suggestion', () {
    test('offered when one cat in this area is clearly ahead', () {
      final m = service.rank(
        [
          catAt('same', 'S', [(dayAgo, _here)]),
          catAt('far', 'F', [(dayAgo, 'u4pruy')]),
        ],
        area: area,
        now: now,
      );
      expect(service.suggestion(m)?.cat.id, 'same');
    });

    test('offered for a lone cat met here', () {
      final m = service.rank(
        [
          catAt('s', 'S', [(dayAgo, _here)]),
        ],
        area: area,
        now: now,
      );
      expect(service.suggestion(m)?.cat.id, 's');
    });

    test('not offered when two cats are close', () {
      final m = service.rank(
        [
          catAt('a', 'A', [(dayAgo, _here)]),
          catAt('b', 'B', [(dayAgo, _here)]),
        ],
        area: area,
        now: now,
      );
      expect(service.suggestion(m), isNull);
    });

    test('not offered without a place, or with no cats', () {
      final m = service.rank([
        catAt('a', 'A', [(dayAgo, _here)]),
      ], now: now);
      expect(service.suggestion(m), isNull);
      expect(service.suggestion(const []), isNull);
    });

    test('not offered when nothing was met here or nearby', () {
      final m = service.rank(
        [
          catAt('a', 'A', [(dayAgo, 'u4pruy')]),
        ],
        area: area,
        now: now,
      );
      expect(service.suggestion(m), isNull);
    });
  });
}
