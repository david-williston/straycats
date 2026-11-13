import 'package:flutter/foundation.dart';

/// What the cat was doing. Stored as [value]; shown through the l10n labels.
enum Activity {
  eating('eating'),
  sleeping('sleeping'),
  resting('resting'),
  waitingAtDoor('waiting_at_door'),
  playing('playing'),
  walkingBy('walking_by');

  const Activity(this.value);

  final String value;

  /// The activity stored as [value], or null if there is none (or it is unknown).
  static Activity? parse(String? value) {
    for (final a in values) {
      if (a.value == value) return a;
    }
    return null;
  }
}

/// How the cat looked. Stored as [value]; shown through the l10n labels.
enum Condition {
  healthy('healthy'),
  thin('thin'),
  limping('limping'),
  unwellOrInjured('unwell_or_injured'),
  withKittens('with_kittens'),
  earTipped('ear_tipped');

  const Condition(this.value);

  final String value;

  static Condition? parse(String? value) {
    for (final c in values) {
      if (c.value == value) return c;
    }
    return null;
  }
}

/// What the person did for the cat. Stored as [value]; shown through the l10n
/// labels.
enum Care {
  fed('fed'),
  gaveWater('gave_water'),
  tookToVet('took_to_vet'),
  gaveMedicine('gave_medicine');

  const Care(this.value);

  final String value;

  static Care? parse(String? value) {
    for (final c in values) {
      if (c.value == value) return c;
    }
    return null;
  }
}

/// The longest story an encounter may carry (the Firestore rules enforce it).
const maxNoteLength = 1000;

/// The optional details of an encounter. Everything may be empty.
@immutable
class EncounterDetails {
  const EncounterDetails({
    this.activity,
    this.conditions = const [],
    this.care = const [],
    this.note = '',
  });

  final Activity? activity;
  final List<Condition> conditions;
  final List<Care> care;
  final String note;

  bool get isEmpty =>
      activity == null &&
      conditions.isEmpty &&
      care.isEmpty &&
      note.trim().isEmpty;

  /// Reads the stored codes. Unknown codes are dropped; lists come back in
  /// the enums' order, without repeats. Old documents had a single `type`
  /// (seen, fed, unwell, kittens, ear_tipped), which maps onto the new
  /// fields (`seen` onto nothing).
  factory EncounterDetails.fromStored({
    String? activity,
    List<dynamic>? conditions,
    List<dynamic>? care,
    String? note,
    String? legacyType,
  }) {
    final legacy = _legacy(legacyType);
    final cs = {
      ...?conditions?.map((c) => Condition.parse(c as String?)),
      ...legacy.conditions,
    };
    final cares = {
      ...?care?.map((c) => Care.parse(c as String?)),
      ...legacy.care,
    };
    return EncounterDetails(
      activity: Activity.parse(activity),
      conditions: [
        for (final c in Condition.values)
          if (cs.contains(c)) c,
      ],
      care: [
        for (final c in Care.values)
          if (cares.contains(c)) c,
      ],
      note: note ?? '',
    );
  }

  static ({List<Condition> conditions, List<Care> care}) _legacy(
    String? type,
  ) => switch (type) {
    'fed' => (conditions: const [], care: const [Care.fed]),
    'unwell' => (conditions: const [Condition.unwellOrInjured], care: const []),
    'kittens' => (conditions: const [Condition.withKittens], care: const []),
    'ear_tipped' => (conditions: const [Condition.earTipped], care: const []),
    _ => (conditions: const [], care: const []),
  };

  /// The stored fields: only the ones with something in them.
  Map<String, dynamic> toStored() => {
    if (activity != null) 'activity': activity!.value,
    if (conditions.isNotEmpty)
      'conditions': [for (final c in conditions) c.value],
    if (care.isNotEmpty) 'care': [for (final c in care) c.value],
    if (note.trim().isNotEmpty) 'note': note.trim(),
  };

  @override
  bool operator ==(Object other) =>
      other is EncounterDetails &&
      other.activity == activity &&
      listEquals(other.conditions, conditions) &&
      listEquals(other.care, care) &&
      other.note == note;

  @override
  int get hashCode => Object.hash(
    activity,
    Object.hashAll(conditions),
    Object.hashAll(care),
    note,
  );
}
