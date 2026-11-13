import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/cat_repository.dart';
import '../data/photo_files.dart';
import '../domain/cat.dart';
import '../domain/encounter.dart';
import '../domain/sighting.dart';

part 'cats_controller.g.dart';

/// Every cat, loaded once; the screens show it and change it through here.
///
/// A failed load is an error state and nothing is saved after it, so a
/// failed load can never overwrite the stored cats.
@Riverpod(keepAlive: true)
class CatsController extends _$CatsController {
  @override
  Future<List<Cat>> build() => ref.watch(catRepositoryProvider).loadCats();

  /// Gives a cat its name. Does nothing if the name did not change.
  Future<void> rename(String catId, String name) async {
    final cats = state.value;
    if (cats == null) return;
    final cat = cats.where((c) => c.id == catId).firstOrNull;
    if (cat == null || cat.name == name) return;
    await _update([
      for (final c in cats) c.id == catId ? c.copyWith(name: name) : c,
    ]);
  }

  /// Records [photo] as an encounter with the cat in [sighting], or with a
  /// new cat when the sighting names none.
  Future<void> recordSighting(File photo, Sighting sighting) async {
    final cats = state.value;
    if (cats == null) return;
    final id = photoName(photo).split('.').first;
    final encounter = Encounter(
      id: id,
      photo: photoName(photo),
      time: photoTime(photo),
      type: sighting.type,
    );
    final catId = sighting.catId;
    await _update([
      if (catId == null) ...[
        ...cats,
        Cat(id: id, name: sighting.name, encounters: [encounter]),
      ] else
        for (final c in cats)
          c.id == catId
              ? c.copyWith(encounters: [...c.encounters, encounter])
              : c,
    ]);
  }

  /// Shows the change at once, then saves it.
  Future<void> _update(List<Cat> cats) async {
    state = AsyncData(cats);
    await ref.read(catRepositoryProvider).saveCats(cats);
  }
}
