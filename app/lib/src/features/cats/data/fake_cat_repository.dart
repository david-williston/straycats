import 'dart:async';

import '../domain/cat.dart';
import '../domain/cat_status.dart';
import '../domain/encounter.dart';
import 'cat_repository.dart';

/// Keeps cats in memory, for tests. [watchCats] emits the current cats and
/// again after each change, like Firestore's listener. The calls are
/// recorded in [added], [addedEncounters], [updated], [deleted], [renamed]
/// and [statusChanges].
class FakeCatRepository implements CatRepository {
  FakeCatRepository([List<Cat> cats = const []]) : cats = [...cats];

  List<Cat> cats;
  final added = <Cat>[];
  final addedEncounters = <(String, Encounter)>[];
  final updated = <(String, Encounter)>[];
  final deleted = <String>[];
  final renamed = <(String, String)>[];
  final statusChanges = <(String, CatStatus, DateTime?, String)>[];

  /// When set, [watchCats] fails with it.
  Object? watchError;

  final _listeners = <StreamController<List<Cat>>>[];

  /// True once any write was made.
  bool get wroteAnything =>
      added.isNotEmpty ||
      addedEncounters.isNotEmpty ||
      updated.isNotEmpty ||
      deleted.isNotEmpty ||
      renamed.isNotEmpty ||
      statusChanges.isNotEmpty;

  void _emit() {
    for (final listener in _listeners) {
      listener.add([...cats]);
    }
  }

  @override
  Stream<List<Cat>> watchCats() {
    late final StreamController<List<Cat>> listener;
    listener = StreamController(
      onListen: () {
        final error = watchError;
        if (error != null) {
          listener.addError(error);
          return;
        }
        listener.add([...cats]);
        _listeners.add(listener);
      },
      onCancel: () => _listeners.remove(listener),
    );
    return listener.stream;
  }

  @override
  Future<void> addCat(Cat cat) async {
    added.add(cat);
    cats = [...cats, cat];
    _emit();
  }

  @override
  Future<void> addEncounter(String catId, Encounter encounter) async {
    addedEncounters.add((catId, encounter));
    cats = [
      for (final c in cats)
        c.id == catId
            ? c.copyWith(encounters: [...c.encounters, encounter])
            : c,
    ];
    _emit();
  }

  @override
  Future<void> updateEncounter(String catId, Encounter encounter) async {
    updated.add((catId, encounter));
    cats = [
      for (final c in cats)
        c.id == catId
            ? c.copyWith(
                encounters: [
                  for (final e in c.encounters)
                    e.id == encounter.id ? encounter : e,
                ],
              )
            : c,
    ];
    _emit();
  }

  @override
  Future<void> deleteEncounter(String encounterId) async {
    deleted.add(encounterId);
    cats = [
      for (final c in cats)
        c.copyWith(
          encounters: [
            for (final e in c.encounters)
              if (e.id != encounterId) e,
          ],
        ),
    ];
    _emit();
  }

  @override
  Future<void> renameCat(String catId, String name) async {
    renamed.add((catId, name));
    cats = [for (final c in cats) c.id == catId ? c.copyWith(name: name) : c];
    _emit();
  }

  @override
  Future<void> setStatus(
    String catId,
    CatStatus status, {
    DateTime? since,
    String note = '',
  }) async {
    statusChanges.add((catId, status, since, note));
    cats = [
      for (final c in cats)
        c.id == catId
            ? c.withStatus(status, since: since, note: note.trim())
            : c,
    ];
    _emit();
  }

}
