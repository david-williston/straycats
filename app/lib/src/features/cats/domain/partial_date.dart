import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// How exactly a [PartialDate] is known.
enum DatePrecision { year, month, day }

/// A calendar date known only as far as the person knows it: a year ("2019"),
/// a month ("2019-03") or a day ("2019-03-14"), and for a bare year possibly
/// "around". Stored as the ISO prefix string, so it has no time zone and
/// sorts as text.
@immutable
class PartialDate {
  const PartialDate._(this.year, this.month, this.day, this.around);

  /// The first year the rules accept.
  static const minYear = 1980;

  /// Just a year. [around] means "around 2019".
  const PartialDate.year(int year, {bool around = false})
    : this._(year, null, null, around);

  const PartialDate.month(int year, int month)
    : this._(year, month, null, false);

  const PartialDate.day(int year, int month, int day)
    : this._(year, month, day, false);

  /// [date] kept to [precision]. [around] counts only for a year.
  factory PartialDate.fromDate(
    DateTime date,
    DatePrecision precision, {
    bool around = false,
  }) => switch (precision) {
    DatePrecision.year => PartialDate.year(date.year, around: around),
    DatePrecision.month => PartialDate.month(date.year, date.month),
    DatePrecision.day => PartialDate.day(date.year, date.month, date.day),
  };

  static final _shape = RegExp(r'^(\d{4})(?:-(\d{2})(?:-(\d{2}))?)?$');

  /// Reads "YYYY", "YYYY-MM" or "YYYY-MM-DD". Null for anything else, an
  /// impossible date (30 February), or a year before [minYear]. [around] is
  /// ignored unless it is a bare year.
  static PartialDate? tryParse(String? text, {bool around = false}) {
    final m = text == null ? null : _shape.firstMatch(text);
    if (m == null) return null;
    final year = int.parse(m[1]!);
    if (year < minYear) return null;
    if (m[2] == null) return PartialDate.year(year, around: around);
    final month = int.parse(m[2]!);
    if (month < 1 || month > 12) return null;
    if (m[3] == null) return PartialDate.month(year, month);
    final day = int.parse(m[3]!);
    final real = DateTime(year, month, day);
    if (real.month != month || real.day != day) return null;
    return PartialDate.day(year, month, day);
  }

  final int year;
  final int? month;
  final int? day;

  /// "Around 2019". Only ever true for a bare year.
  final bool around;

  DatePrecision get precision => day != null
      ? DatePrecision.day
      : month != null
      ? DatePrecision.month
      : DatePrecision.year;

  /// The stored string: "2019", "2019-03" or "2019-03-14".
  String get stored {
    String two(int n) => n.toString().padLeft(2, '0');
    return switch (precision) {
      DatePrecision.year => '$year',
      DatePrecision.month => '$year-${two(month!)}',
      DatePrecision.day => '$year-${two(month!)}-${two(day!)}',
    };
  }

  /// The first day of the period (local midnight).
  DateTime get start => DateTime(year, month ?? 1, day ?? 1);

  /// The last day of the period (local midnight).
  DateTime get end => switch (precision) {
    DatePrecision.year => DateTime(year, 12, 31),
    DatePrecision.month => DateTime(year, month! + 1, 0),
    DatePrecision.day => DateTime(year, month!, day!),
  };

  /// Whether the two periods share a day: they agree. Disjoint periods do not.
  bool overlaps(PartialDate other) =>
      !start.isAfter(other.end) && !other.start.isAfter(end);

  /// Whether any of it lies after [now]'s day.
  bool isInFuture(DateTime now) =>
      start.isAfter(DateTime(now.year, now.month, now.day));

  /// Which wording applies: `around`, `year`, `month` or `day`. Messages
  /// choose their preposition from it.
  String get kind => around ? 'around' : precision.name;

  /// The date as far as it is known, in [locale]: "Nov 3, 2026", "March
  /// 2021" or "2019". "Around" is left to the sentence around it.
  String format(String locale) => switch (precision) {
    DatePrecision.year => DateFormat.y(locale).format(start),
    DatePrecision.month => DateFormat.yMMMM(locale).format(start),
    DatePrecision.day => DateFormat.yMMMd(locale).format(start),
  };

  @override
  bool operator ==(Object other) =>
      other is PartialDate && other.stored == stored && other.around == around;

  @override
  int get hashCode => Object.hash(stored, around);

  @override
  String toString() => around ? '~$stored' : stored;
}
