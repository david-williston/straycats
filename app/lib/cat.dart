import 'dart:io';

/// What happened when a cat was seen. Stored as [value]; shown as [label].
enum EncounterType {
  seen('seen', 'Just saw it'),
  fed('fed', 'Fed it'),
  unwell('unwell', 'Looks unwell or injured'),
  kittens('kittens', 'With kittens'),
  earTipped('ear_tipped', 'Ear tipped');

  const EncounterType(this.value, this.label);

  final String value;
  final String label;

  /// The type stored as [value], or null if there is none (or it is unknown).
  static EncounterType? parse(String? value) {
    for (final type in values) {
      if (type.value == value) return type;
    }
    return null;
  }
}

/// One sighting of a cat: a photo (a file name in the `cats` folder) and when.
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
}

/// A cat and every time it has been seen. [name] is empty until given one.
class Cat {
  Cat({required this.id, this.name = '', List<Encounter>? encounters})
    : encounters = encounters ?? [];

  final String id;
  String name;
  final List<Encounter> encounters;

  /// Encounters, newest first.
  List<Encounter> get history =>
      [...encounters]..sort((a, b) => b.time.compareTo(a.time));

  Encounter? get latest => encounters.isEmpty ? null : history.first;

  DateTime get lastSeen =>
      latest?.time ?? DateTime.fromMillisecondsSinceEpoch(0);

  factory Cat.fromJson(Map<String, dynamic> json) => Cat(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    encounters: [
      for (final e in json['encounters'] as List<dynamic>)
        Encounter.fromJson(e as Map<String, dynamic>),
    ],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'encounters': [for (final e in encounters) e.toJson()],
  };
}

/// Cats, most recently seen first.
List<Cat> byLastSeen(Iterable<Cat> cats) =>
    [...cats]..sort((a, b) => b.lastSeen.compareTo(a.lastSeen));

/// The time a photo was taken, from its `<millis>.jpg` file name. Falls back
/// to the file's modified time if the name is not a number.
DateTime photoTime(File photo) {
  final stem = photoName(photo).split('.').first;
  final millis = int.tryParse(stem);
  if (millis != null) return DateTime.fromMillisecondsSinceEpoch(millis);
  try {
    return photo.lastModifiedSync();
  } catch (_) {
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}

/// A photo's file name, e.g. `1730.jpg`.
String photoName(File photo) => photo.uri.pathSegments.last;

/// Builds cats from the app's first version, where each photo stood alone and
/// `names.json` mapped photo file names to names: every photo becomes its own
/// cat with one encounter.
List<Cat> migrate(List<File> photos, Map<String, String> names) => [
  for (final photo in photos)
    Cat(
      id: photoName(photo).split('.').first,
      name: names[photoName(photo)]?.trim() ?? '',
      encounters: [
        Encounter(
          id: photoName(photo).split('.').first,
          photo: photoName(photo),
          time: photoTime(photo),
        ),
      ],
    ),
];
