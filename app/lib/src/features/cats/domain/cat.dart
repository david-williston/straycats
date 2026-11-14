import 'package:flutter/foundation.dart';

import 'cat_traits.dart';
import 'encounter.dart';
import 'life.dart';
import 'life_event.dart';

/// A cat, every time it has been seen, and the entries of its story (born,
/// missing, found, sterilised, passed away). [name] is empty until given
/// one. What state the cat is in is not stored: [life] derives it.
@immutable
class Cat {
  const Cat({
    required this.id,
    this.name = '',
    this.encounters = const [],
    this.events = const [],
    this.sex,
    this.hair,
    this.colour,
  });

  final String id;
  final String name;
  final List<Encounter> encounters;
  final List<LifeEvent> events;

  /// Optional looks; null means not sure.
  final CatSex? sex;
  final CatHair? hair;
  final CatColour? colour;

  Cat copyWith({
    String? name,
    List<Encounter>? encounters,
    List<LifeEvent>? events,
  }) => Cat(
    id: id,
    name: name ?? this.name,
    encounters: encounters ?? this.encounters,
    events: events ?? this.events,
    sex: sex,
    hair: hair,
    colour: colour,
  );

  /// The same cat with these looks (null clears one).
  Cat withLooks({CatSex? sex, CatHair? hair, CatColour? colour}) => Cat(
    id: id,
    name: name,
    encounters: encounters,
    events: events,
    sex: sex,
    hair: hair,
    colour: colour,
  );

  /// What the app shows for this cat, derived from its entries and
  /// sightings.
  LifeView get life => lifeOf(events, [for (final e in encounters) e.time]);

  /// Encounters, newest first.
  List<Encounter> get history =>
      [...encounters]..sort((a, b) => b.time.compareTo(a.time));

  Encounter? get latest => encounters.isEmpty ? null : history.first;

  DateTime get lastSeen =>
      latest?.time ?? DateTime.fromMillisecondsSinceEpoch(0);

  /// When the cat was first met, if it has any encounter.
  DateTime? get firstMet => encounters.isEmpty
      ? null
      : encounters.map((e) => e.time).reduce((a, b) => a.isBefore(b) ? a : b);

  factory Cat.fromJson(Map<String, dynamic> json) => Cat(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    encounters: [
      for (final e in json['encounters'] as List<dynamic>)
        Encounter.fromJson(e as Map<String, dynamic>),
    ],
    sex: CatSex.fromStored(json['sex']),
    hair: CatHair.fromStored(json['hair']),
    colour: CatColour.fromStored(json['colour']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'encounters': [for (final e in encounters) e.toJson()],
    if (sex != null) 'sex': sex!.stored,
    if (hair != null) 'hair': hair!.stored,
    if (colour != null) 'colour': colour!.stored,
  };

  @override
  bool operator ==(Object other) =>
      other is Cat &&
      other.id == id &&
      other.name == name &&
      other.sex == sex &&
      other.hair == hair &&
      other.colour == colour &&
      listEquals(other.events, events) &&
      listEquals(other.encounters, encounters);

  @override
  int get hashCode => Object.hash(
    id,
    name,
    sex,
    hair,
    colour,
    Object.hashAll(events),
    Object.hashAll(encounters),
  );
}

/// Cats for the grid: missing ones first, remembered ones last, and in each
/// group the most recently seen first.
List<Cat> byLastSeen(Iterable<Cat> cats) {
  int rank(Cat c) => switch (c.life.state) {
    LifeState.missing => 0,
    LifeState.remembered => 2,
    _ => 1,
  };
  return [...cats]..sort((a, b) {
    final byRank = rank(a).compareTo(rank(b));
    return byRank != 0 ? byRank : b.lastSeen.compareTo(a.lastSeen);
  });
}
