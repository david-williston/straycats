import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:straycats/src/features/cats/domain/partial_date.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('es');
  });

  group('parsing and storing', () {
    test('the three precisions round trip as their ISO prefix', () {
      for (final text in ['2019', '2019-03', '2019-03-14']) {
        expect(PartialDate.tryParse(text)!.stored, text);
      }
      expect(PartialDate.tryParse('2019')!.precision, DatePrecision.year);
      expect(PartialDate.tryParse('2019-03')!.precision, DatePrecision.month);
      expect(PartialDate.tryParse('2019-03-14')!.precision, DatePrecision.day);
    });

    test('pads months and days', () {
      expect(const PartialDate.month(2019, 3).stored, '2019-03');
      expect(const PartialDate.day(2019, 3, 4).stored, '2019-03-04');
    });

    test('rejects what is not a real date from 1980', () {
      for (final bad in [
        null,
        '',
        '19',
        '1979',
        '2019-13',
        '2019-00',
        '2019-02-30',
        '2019-3-4',
        '2019/03/04',
        '2019-03-04T10:00',
        'around 2019',
      ]) {
        expect(PartialDate.tryParse(bad), isNull, reason: '$bad');
      }
      expect(PartialDate.tryParse('2020-02-29'), isNotNull);
      expect(PartialDate.tryParse('2019-02-29'), isNull);
    });

    test('around only goes with a bare year', () {
      expect(PartialDate.tryParse('2019', around: true)!.around, isTrue);
      expect(PartialDate.tryParse('2019-03', around: true)!.around, isFalse);
      expect(PartialDate.tryParse('2019-03-14', around: true)!.around, isFalse);
      expect(
        PartialDate.fromDate(
          DateTime(2019, 3, 14),
          DatePrecision.month,
          around: true,
        ).around,
        isFalse,
      );
      expect(
        PartialDate.fromDate(DateTime(2019, 3, 14), DatePrecision.year).stored,
        '2019',
      );
    });

    test('kind says which wording applies', () {
      expect(const PartialDate.year(2019, around: true).kind, 'around');
      expect(const PartialDate.year(2019).kind, 'year');
      expect(const PartialDate.month(2019, 3).kind, 'month');
      expect(const PartialDate.day(2019, 3, 4).kind, 'day');
    });
  });

  group('period and overlap', () {
    test('start and end are the first and last day', () {
      expect(const PartialDate.year(2019).start, DateTime(2019, 1, 1));
      expect(const PartialDate.year(2019).end, DateTime(2019, 12, 31));
      expect(const PartialDate.month(2020, 2).end, DateTime(2020, 2, 29));
      expect(const PartialDate.month(2019, 12).end, DateTime(2019, 12, 31));
      expect(const PartialDate.day(2019, 3, 4).start, DateTime(2019, 3, 4));
      expect(const PartialDate.day(2019, 3, 4).end, DateTime(2019, 3, 4));
    });

    test('overlapping periods agree, disjoint ones do not', () {
      const year = PartialDate.year(2019);
      expect(year.overlaps(const PartialDate.month(2019, 3)), isTrue);
      expect(year.overlaps(const PartialDate.day(2019, 12, 31)), isTrue);
      expect(year.overlaps(const PartialDate.year(2019, around: true)), isTrue);
      expect(year.overlaps(const PartialDate.year(2020)), isFalse);
      const march = PartialDate.month(2019, 3);
      expect(march.overlaps(const PartialDate.day(2019, 3, 14)), isTrue);
      expect(march.overlaps(const PartialDate.day(2019, 4, 1)), isFalse);
      expect(
        const PartialDate.day(
          2019,
          3,
          4,
        ).overlaps(const PartialDate.day(2019, 3, 5)),
        isFalse,
      );
    });

    test('a period is in the future only after today', () {
      final now = DateTime(2026, 11, 13, 15);
      expect(const PartialDate.year(2026).isInFuture(now), isFalse);
      expect(const PartialDate.month(2026, 11).isInFuture(now), isFalse);
      expect(const PartialDate.day(2026, 11, 13).isInFuture(now), isFalse);
      expect(const PartialDate.day(2026, 11, 14).isInFuture(now), isTrue);
      expect(const PartialDate.month(2026, 12).isInFuture(now), isTrue);
      expect(const PartialDate.year(2027).isInFuture(now), isTrue);
    });
  });

  group('formatting', () {
    test('as precisely as it was given, in English', () {
      expect(const PartialDate.year(2019).format('en'), '2019');
      expect(const PartialDate.month(2021, 3).format('en'), 'March 2021');
      expect(const PartialDate.day(2026, 9, 16).format('en'), 'Sep 16, 2026');
    });

    test('and in Spanish', () {
      expect(const PartialDate.year(2019).format('es'), '2019');
      expect(const PartialDate.month(2021, 3).format('es'), 'marzo de 2021');
      expect(const PartialDate.day(2026, 9, 16).format('es'), '16 sept 2026');
    });
  });

  test('equality includes around', () {
    expect(const PartialDate.year(2019), const PartialDate.year(2019));
    expect(
      const PartialDate.year(2019) ==
          const PartialDate.year(2019, around: true),
      isFalse,
    );
  });
}
