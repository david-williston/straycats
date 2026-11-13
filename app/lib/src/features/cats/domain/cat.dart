import 'package:flutter/foundation.dart';

import 'cat_status.dart';
import 'encounter.dart';

/// A cat and every time it has been seen. [name] is empty until given one.
///
/// [status] is [CatStatus.known] unless someone said otherwise. [statusSince]
/// is the date they chose (missing since, found on, died on) and [statusNote]
/// a few words (last seen near the market; in memory). A cat with a status
/// keeps its record open: encounters can still be added.
@immutable
class Cat {
  const Cat({
    required this.id,
    this.name = '',
    this.encounters = const [],
    this.status = CatStatus.known,
    this.statusSince,
    this.statusNote = '',
  });

  final String id;
  final String name;
  final List<Encounter> encounters;
  final CatStatus status;
  final DateTime? statusSince;
  final String statusNote;

  Cat copyWith({String? name, List<Encounter>? encounters}) => Cat(
    id: id,
    name: name ?? this.name,
    encounters: encounters ?? this.encounters,
    status: status,
    statusSince: statusSince,
    statusNote: statusNote,
  );

  /// The same cat with a new status. [CatStatus.known] clears the date and
  /// the note.
  Cat withStatus(CatStatus status, {DateTime? since, String note = ''}) {
    final known = status == CatStatus.known;
    return Cat(
      id: id,
      name: name,
      encounters: encounters,
      status: status,
      statusSince: known ? null : since,
      statusNote: known ? '' : note,
    );
  }

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
    status: CatStatus.fromStored(json['status'] as String?),
    statusSince: json['statusSince'] == null
        ? null
        : DateTime.parse(json['statusSince'] as String),
    statusNote: json['statusNote'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'encounters': [for (final e in encounters) e.toJson()],
    if (status != CatStatus.known) ...{
      'status': status.name,
      if (statusSince != null) 'statusSince': statusSince!.toIso8601String(),
      if (statusNote.isNotEmpty) 'statusNote': statusNote,
    },
  };

  @override
  bool operator ==(Object other) =>
      other is Cat &&
      other.id == id &&
      other.name == name &&
      other.status == status &&
      other.statusSince == statusSince &&
      other.statusNote == statusNote &&
      listEquals(other.encounters, encounters);

  @override
  int get hashCode => Object.hash(
    id,
    name,
    status,
    statusSince,
    statusNote,
    Object.hashAll(encounters),
  );
}

/// Cats for the grid: missing ones first, remembered ones last, and in each
/// group the most recently seen first.
List<Cat> byLastSeen(Iterable<Cat> cats) {
  int rank(Cat c) => switch (c.status) {
    CatStatus.missing => 0,
    CatStatus.remembered => 2,
    _ => 1,
  };
  return [...cats]..sort((a, b) {
    final byRank = rank(a).compareTo(rank(b));
    return byRank != 0 ? byRank : b.lastSeen.compareTo(a.lastSeen);
  });
}
