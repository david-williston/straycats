import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../places/domain/coarse_area.dart';
import '../../places/domain/place.dart';

/// An outgoing encounter would carry something finer than a coarse area.
class CoarseGuardException implements Exception {
  const CoarseGuardException(this.reason);

  final String reason;

  @override
  String toString() => 'CoarseGuardException: $reason';
}

const _allowedKeys = {
  'catId',
  'photoId',
  'takenAt',
  'activity',
  'conditions',
  'care',
  'note',
  'area',
  'neighbourhood',
  'updatedAt',
};

const _eventKeys = {
  'catId',
  'type',
  'on',
  'around',
  'note',
  'area',
  'neighbourhood',
  'createdAt',
  'updatedAt',
};

const _latLngKeys = {'lat', 'lng', 'lon', 'latitude', 'longitude', 'geo'};

/// Run just before every encounter write. Throws (after logging) unless the
/// map has only known keys, `area` is a geohash of at most 6 characters,
/// `neighbourhood` is a short string, and nothing in it is a GeoPoint, a
/// lat/lng field, or a pair of numbers that looks like a position.
void assertCoarse(Map<String, dynamic> data) => _assert(data, _allowedKeys);

/// The same check for a life event (a missing entry may carry the last-seen
/// area), run just before every event write.
void assertCoarseEvent(Map<String, dynamic> data) => _assert(data, _eventKeys);

void _assert(Map<String, dynamic> data, Set<String> allowedKeys) {
  try {
    for (final key in data.keys) {
      if (!allowedKeys.contains(key)) {
        throw CoarseGuardException('unexpected field "$key"');
      }
    }
    final area = data['area'];
    // A FieldValue (a delete, in an update) carries no value to check.
    if (area != null &&
        area is! FieldValue &&
        (area is! String || CoarseArea.tryParse(area) == null)) {
      throw const CoarseGuardException('area is not a geohash of 6 or fewer');
    }
    final name = data['neighbourhood'];
    if (name != null &&
        name is! FieldValue &&
        (name is! String || name.length > maxNeighbourhoodLength)) {
      throw const CoarseGuardException('neighbourhood is not a short string');
    }
    data.forEach((key, value) => _scan(key, value));
  } on CoarseGuardException catch (e) {
    developer.log('Refused write: $e', name: 'straycats');
    rethrow;
  }
}

void _scan(String path, Object? v) {
  if (v is GeoPoint) {
    throw CoarseGuardException('GeoPoint at $path');
  }
  if (v is Map) {
    v.forEach((k, x) {
      if (_latLngKeys.contains('$k'.toLowerCase())) {
        throw CoarseGuardException('lat/lng field at $path.$k');
      }
      _scan('$path.$k', x);
    });
  } else if (v is List) {
    if (v.length == 2 && v.every((x) => x is double)) {
      final a = v[0] as double, b = v[1] as double;
      if (a.abs() <= 180 && b.abs() <= 180) {
        throw CoarseGuardException('a pair of numbers at $path');
      }
    }
    for (var i = 0; i < v.length; i++) {
      _scan('$path[$i]', v[i]);
    }
  }
}
