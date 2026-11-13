import 'package:flutter/foundation.dart';

import '../../places/domain/place.dart';
import 'encounter_details.dart';

/// One sighting of a cat: a photo ([photoId], the stem of its file name in the
/// `cats` folder), when, and optional [details].
@immutable
class Encounter {
  const Encounter({
    required this.id,
    required this.photoId,
    required this.time,
    this.details = const EncounterDetails(),
    this.place,
  });

  final String id;
  final String photoId;
  final DateTime time;
  final EncounterDetails details;

  /// The neighbourhood-level place, if one was saved. Never exact.
  final Place? place;

  /// The local file name of the photo, e.g. `1730.jpg`.
  String get photoFile => '$photoId.jpg';

  Encounter withDetails(EncounterDetails details) => Encounter(
    id: id,
    photoId: photoId,
    time: time,
    details: details,
    place: place,
  );

  Encounter withPlace(Place? place) => Encounter(
    id: id,
    photoId: photoId,
    time: time,
    details: details,
    place: place,
  );

  /// Reads the legacy `cats.json` form, where the photo is a file name and
  /// the details are at most a single `type`.
  factory Encounter.fromJson(Map<String, dynamic> json) => Encounter(
    id: json['id'] as String,
    photoId: (json['photo'] as String).split('.').first,
    time: DateTime.fromMillisecondsSinceEpoch(json['time'] as int),
    details: EncounterDetails.fromStored(
      activity: json['activity'] as String?,
      conditions: json['conditions'] as List<dynamic>?,
      care: json['care'] as List<dynamic>?,
      note: json['note'] as String?,
      legacyType: json['type'] as String?,
    ),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'photo': photoFile,
    'time': time.millisecondsSinceEpoch,
    ...details.toStored(),
  };

  @override
  bool operator ==(Object other) =>
      other is Encounter &&
      other.id == id &&
      other.photoId == photoId &&
      other.time == time &&
      other.details == details &&
      other.place == place;

  @override
  int get hashCode => Object.hash(id, photoId, time, details, place);
}
