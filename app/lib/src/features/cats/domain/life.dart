import 'package:flutter/foundation.dart';

import 'life_event.dart';

/// What the app shows for a cat, derived from its entries.
enum LifeState { known, missing, found, remembered }

/// Why entries may not agree. Never blocks anything.
enum ConflictKind {
  /// Two entries of a once-only type with disjoint dates.
  duplicate,

  /// A sighting after the end of a recorded death.
  sightingAfterDeath,

  /// A "found" after the end of a recorded death.
  foundAfterDeath,
}

/// A gentle "check these": [events] are the entries involved, [sighting] the
/// date of the photo for [ConflictKind.sightingAfterDeath].
@immutable
class LifeConflict {
  const LifeConflict(this.kind, this.events, {this.type, this.sighting});

  final ConflictKind kind;
  final List<LifeEvent> events;

  /// The once-only type of a [ConflictKind.duplicate].
  final LifeEventType? type;
  final DateTime? sighting;
}

/// The derived view of a cat's story: [events] in date order, the [state]
/// that decides its badge and its place in the grid, the [conflicts] to
/// check and a [nudge] after a sighting of a missing cat.
@immutable
class LifeView {
  const LifeView({
    required this.events,
    required this.state,
    this.stateEvent,
    this.conflicts = const [],
    this.nudge,
  });

  /// Oldest first, by start of the date, ties by creation.
  final List<LifeEvent> events;
  final LifeState state;

  /// The entry that decides [state], if any.
  final LifeEvent? stateEvent;
  final List<LifeConflict> conflicts;

  /// The date of a sighting after the cat was recorded as missing: "Seen on
  /// 12 Nov. Found?". Null when there is none.
  final DateTime? nudge;

  List<LifeEvent> ofType(LifeEventType type) => [
    for (final e in events)
      if (e.type == type) e,
  ];

  /// The latest entry of [type], if any.
  LifeEvent? latestOf(LifeEventType type) => ofType(type).lastOrNull;

  /// Whether [event] is part of a conflict.
  bool inConflict(LifeEvent event) =>
      conflicts.any((c) => c.events.any((e) => e.id == event.id));
}

/// How long a "found" badge stays.
const foundBadgeDays = 30;

DateTime _dayOf(DateTime t) => DateTime(t.year, t.month, t.day);

int _byDate(LifeEvent a, LifeEvent b) {
  final byStart = a.on.start.compareTo(b.on.start);
  if (byStart != 0) return byStart;
  return (a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
    b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
  );
}

/// Works out what to show from [events] (the entries of one cat) and
/// [sightings] (the dates of its encounters). Pure: nothing is stored, and
/// nothing is decided for the people: disagreements come back as
/// [LifeView.conflicts], and a death is never overridden by a later sighting.
LifeView lifeOf(
  Iterable<LifeEvent> events,
  Iterable<DateTime> sightings, {
  DateTime? now,
}) {
  final today = _dayOf(now ?? DateTime.now());
  final sorted = [...events]..sort(_byDate);
  final days = [for (final s in sightings) _dayOf(s)]..sort();
  final conflicts = <LifeConflict>[];

  // Once-only types: overlapping periods agree, disjoint periods conflict.
  for (final type in LifeEventType.values.where((t) => t.onceOnly)) {
    final same = [
      for (final e in sorted)
        if (e.type == type) e,
    ];
    final disagree = [
      for (var i = 0; i < same.length; i++)
        for (var j = i + 1; j < same.length; j++)
          if (!same[i].on.overlaps(same[j].on)) true,
    ];
    if (disagree.isNotEmpty) {
      conflicts.add(LifeConflict(ConflictKind.duplicate, same, type: type));
    }
  }

  // After a death: a sighting or a "found" after the end of the period.
  final deaths = [
    for (final e in sorted)
      if (e.type == LifeEventType.died) e,
  ];
  for (final death in deaths) {
    final end = death.on.end;
    final late = days.where((d) => d.isAfter(end));
    if (late.isNotEmpty) {
      conflicts.add(
        LifeConflict(ConflictKind.sightingAfterDeath, [
          death,
        ], sighting: late.last),
      );
    }
    final found = [
      for (final e in sorted)
        if (e.type == LifeEventType.found && e.on.start.isAfter(end)) e,
    ];
    if (found.isNotEmpty) {
      conflicts.add(
        LifeConflict(ConflictKind.foundAfterDeath, [death, ...found]),
      );
    }
  }

  // State. Any death means remembered; else the later of missing and found.
  var state = LifeState.known;
  LifeEvent? stateEvent;
  DateTime? nudge;
  if (deaths.isNotEmpty) {
    state = LifeState.remembered;
    stateEvent = deaths.last;
  } else {
    final latest = sorted
        .where(
          (e) =>
              e.type == LifeEventType.missing || e.type == LifeEventType.found,
        )
        .lastOrNull;
    if (latest != null && latest.type == LifeEventType.missing) {
      state = LifeState.missing;
      stateEvent = latest;
      final seen = days.where((d) => d.isAfter(latest.on.end));
      if (seen.isNotEmpty) nudge = seen.last;
    } else if (latest != null &&
        today.difference(latest.on.end).inDays <= foundBadgeDays) {
      state = LifeState.found;
      stateEvent = latest;
    }
  }

  return LifeView(
    events: sorted,
    state: state,
    stateEvent: stateEvent,
    conflicts: conflicts,
    nudge: nudge,
  );
}
