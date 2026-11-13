import 'dart:async';

import '../domain/cat.dart';
import '../domain/encounter.dart';
import 'cat_repository.dart';

/// Keeps cats in memory, for tests. [watchCats] emits the current cats and
/// again after each change, like Firestore's listener. The calls are
/// recorded in [added], [addedEncounters], [renamed] and [imported].
class FakeCatRepository implements CatRepository {
  FakeCatRepository([List<Cat> cats = const []]) : cats = [...cats];

  List<Cat> cats;
  final added = <Cat>[];
  final addedEncounters = <(String, Encounter)>[];
  final renamed = <(String, String)>[];
  final imported = <Cat>[];

  /// When set, [watchCats] fails with it.
  Object? watchError;

  /// When set, [importCats] waits for it, like a write made offline.
  Completer<void>? importGate;

  final _listeners = <StreamController<List<Cat>>>[];

  /// True once any write was made.
  bool get wroteAnything =>
      added.isNotEmpty ||
      addedEncounters.isNotEmpty ||
      renamed.isNotEmpty ||
      imported.isNotEmpty;

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
  Future<void> renameCat(String catId, String name) async {
    renamed.add((catId, name));
    cats = [for (final c in cats) c.id == catId ? c.copyWith(name: name) : c];
    _emit();
  }

  @override
  Future<void> importCats(List<Cat> cats) async {
    imported.addAll(cats);
    await importGate?.future;
  }
}
