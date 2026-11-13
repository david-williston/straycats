import 'package:flutter/foundation.dart';

import '../../places/domain/place.dart';
import 'partial_date.dart';

/// What happened in a cat's life. Said in the app as "Passed away", never
/// "died"; the name here is only for data and code.
enum LifeEventType {
  born,
  missing,
  found,
  sterilised,
  died;

  /// Happens once in a cat's life. More than one is shown, not refused.
  bool get onceOnly => this == born || this == sterilised || this == died;

  static LifeEventType? fromStored(String? value) {
    for (final t in values) {
      if (t.name == value) return t;
    }
    return null;
  }

  /// The longest note the rules allow.
  static const maxNoteLength = 1000;
}

/// One dated entry in a cat's story, written by one person. It says nothing
/// about the cat's state by itself: that is derived from all entries by
/// `lifeOf`.
@immutable
class LifeEvent {
  const LifeEvent({
    required this.id,
    required this.type,
    required this.on,
    this.note = '',
    this.place,
    this.createdAt,
  });

  /// Client-made (milliseconds), so events can be written offline.
  final String id;
  final LifeEventType type;
  final PartialDate on;
  final String note;

  /// Only for [LifeEventType.missing]: the last-seen neighbourhood-level
  /// place. Never exact.
  final Place? place;

  /// Server time; null until the server has answered. Breaks ties between
  /// entries on the same date.
  final DateTime? createdAt;

  LifeEvent copyWith({PartialDate? on, String? note}) => LifeEvent(
    id: id,
    type: type,
    on: on ?? this.on,
    note: note ?? this.note,
    place: place,
    createdAt: createdAt,
  );

  @override
  bool operator ==(Object other) =>
      other is LifeEvent &&
      other.id == id &&
      other.type == type &&
      other.on == on &&
      other.note == note &&
      other.place == place &&
      other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(id, type, on, note, place, createdAt);
}
