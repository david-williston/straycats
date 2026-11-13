import 'package:flutter/foundation.dart';

import 'geohash.dart';

/// The only form in which a location reaches the data layer: a geohash of
/// at most [maxPrecision] characters (about 1.2 km by 0.6 km at 6). There
/// is no way to hold a latitude and longitude in one, so nothing finer can
/// be written by mistake.
@immutable
class CoarseArea {
  const CoarseArea._(this.geohash);

  /// Precision 6 is the finest ever kept.
  static const maxPrecision = 6;

  static final _valid = RegExp(r'^[0-9b-hjkmnp-z]{1,6}$');

  /// From a stored geohash. Throws [FormatException] if it is longer than
  /// [maxPrecision] or has characters outside the geohash alphabet.
  factory CoarseArea.fromGeohash(String geohash) {
    if (!_valid.hasMatch(geohash)) {
      throw FormatException(
        'Not a coarse area (geohash of 1 to $maxPrecision characters)',
        geohash,
      );
    }
    return CoarseArea._(geohash);
  }

  /// Like [CoarseArea.fromGeohash], but null instead of throwing.
  static CoarseArea? tryParse(String? geohash) {
    if (geohash == null || !_valid.hasMatch(geohash)) return null;
    return CoarseArea._(geohash);
  }

  /// Rounds a position to the precision-6 cell that holds it. The position
  /// is used for that and not kept: only the cell remains. Call this from
  /// the location service, as soon as the position is read.
  factory CoarseArea.fromPosition(double lat, double lng) =>
      CoarseArea._(encodeGeohash(lat, lng, precision: maxPrecision));

  final String geohash;

  /// The middle of the cell, for drawing the approximate area.
  ({double lat, double lng}) get center => decodeGeohashCenter(geohash);

  @override
  bool operator ==(Object other) =>
      other is CoarseArea && other.geohash == geohash;

  @override
  int get hashCode => geohash.hashCode;

  @override
  String toString() => 'CoarseArea($geohash)';
}
