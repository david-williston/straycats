import 'package:flutter/foundation.dart';

import 'encounter_type.dart';

/// One sighting of a cat: a photo ([photoId], the stem of its file name in the
/// `cats` folder) and when.
@immutable
class Encounter {
  const Encounter({
    required this.id,
    required this.photoId,
    required this.time,
    this.type,
  });

  final String id;
  final String photoId;
  final DateTime time;
  final EncounterType? type;

  /// The local file name of the photo, e.g. `1730.jpg`.
  String get photoFile => '$photoId.jpg';

  /// Reads the legacy `cats.json` form, where the photo is a file name.
  factory Encounter.fromJson(Map<String, dynamic> json) => Encounter(
    id: json['id'] as String,
    photoId: (json['photo'] as String).split('.').first,
    time: DateTime.fromMillisecondsSinceEpoch(json['time'] as int),
    type: EncounterType.parse(json['type'] as String?),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'photo': photoFile,
    'time': time.millisecondsSinceEpoch,
    if (type != null) 'type': type!.value,
  };

  @override
  bool operator ==(Object other) =>
      other is Encounter &&
      other.id == id &&
      other.photoId == photoId &&
      other.time == time &&
      other.type == type;

  @override
  int get hashCode => Object.hash(id, photoId, time, type);
}
