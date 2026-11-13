import 'package:flutter/foundation.dart';

import 'encounter_type.dart';

/// One sighting of a cat: a photo (a file name in the `cats` folder) and when.
@immutable
class Encounter {
  const Encounter({
    required this.id,
    required this.photo,
    required this.time,
    this.type,
  });

  final String id;
  final String photo;
  final DateTime time;
  final EncounterType? type;

  factory Encounter.fromJson(Map<String, dynamic> json) => Encounter(
    id: json['id'] as String,
    photo: json['photo'] as String,
    time: DateTime.fromMillisecondsSinceEpoch(json['time'] as int),
    type: EncounterType.parse(json['type'] as String?),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'photo': photo,
    'time': time.millisecondsSinceEpoch,
    if (type != null) 'type': type!.value,
  };

  @override
  bool operator ==(Object other) =>
      other is Encounter &&
      other.id == id &&
      other.photo == photo &&
      other.time == time &&
      other.type == type;

  @override
  int get hashCode => Object.hash(id, photo, time, type);
}
