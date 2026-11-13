import 'package:flutter/foundation.dart';

import 'encounter.dart';

/// A cat and every time it has been seen. [name] is empty until given one.
@immutable
class Cat {
  const Cat({required this.id, this.name = '', this.encounters = const []});

  final String id;
  final String name;
  final List<Encounter> encounters;

  Cat copyWith({String? name, List<Encounter>? encounters}) => Cat(
    id: id,
    name: name ?? this.name,
    encounters: encounters ?? this.encounters,
  );

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

  @override
  bool operator ==(Object other) =>
      other is Cat &&
      other.id == id &&
      other.name == name &&
      listEquals(other.encounters, encounters);

  @override
  int get hashCode => Object.hash(id, name, Object.hashAll(encounters));
}

/// Cats, most recently seen first.
List<Cat> byLastSeen(Iterable<Cat> cats) =>
    [...cats]..sort((a, b) => b.lastSeen.compareTo(a.lastSeen));
