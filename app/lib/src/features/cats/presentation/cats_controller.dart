import 'dart:developer' as developer;
import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../places/data/place_service.dart';
import '../application/photo_uploader.dart';
import '../data/cat_repository.dart';
import '../data/photo_files.dart';
import '../domain/cat.dart';
import '../domain/encounter.dart';
import '../domain/sighting.dart';

part 'cats_controller.g.dart';

/// Every cat, kept up to date by the repository's listener; the screens show
/// it and change it through here.
///
/// Writes are not awaited: Firestore applies them locally at once (the
/// listener shows them) and syncs when it can. A failure is logged, since it
/// means a rules or app bug (`permission-denied`), not a missing connection.
@Riverpod(keepAlive: true)
class CatsController extends _$CatsController {
  @override
  Stream<List<Cat>> build() => ref.watch(catRepositoryProvider).watchCats();

  /// Gives a cat its name. Does nothing if the name did not change.
  Future<void> rename(String catId, String name) async {
    final cats = state.value;
    if (cats == null) return;
    final cat = cats.where((c) => c.id == catId).firstOrNull;
    if (cat == null || cat.name == name) return;
    _log(ref.read(catRepositoryProvider).renameCat(catId, name));
  }

  /// Records [photo] as an encounter with the cat in [sighting], or with a
  /// new cat when the sighting names none, and queues the photo for upload.
  Future<void> recordSighting(File photo, Sighting sighting) async {
    final cats = state.value;
    if (cats == null) return;
    final id = photoName(photo).split('.').first;
    // Found while the user chose the cat; null if denied, off or slow.
    final place = await ref.read(placeCaptureProvider).take(photo);
    final encounter = Encounter(
      id: id,
      photoId: id,
      time: photoTime(photo),
      details: sighting.details,
      place: place,
    );
    final repo = ref.read(catRepositoryProvider);
    final catId = sighting.catId;
    _log(
      catId == null
          ? repo.addCat(
              Cat(id: id, name: sighting.name, encounters: [encounter]),
            )
          : repo.addEncounter(catId, encounter),
    );
    await ref.read(photoUploaderProvider).enqueue(id);
  }

  /// Saves the edited details of one of [catId]'s encounters.
  Future<void> updateEncounter(String catId, Encounter encounter) async {
    _log(ref.read(catRepositoryProvider).updateEncounter(catId, encounter));
  }

  /// Clears the place of [encounter] (area and neighbourhood). Nothing else
  /// about it changes; no exact position was ever kept.
  Future<void> removePlace(String catId, Encounter encounter) async {
    _log(
      ref
          .read(catRepositoryProvider)
          .updateEncounter(catId, encounter.withPlace(null)),
    );
  }

  /// Deletes one encounter. The cat stays, with no photo if it was the last.
  Future<void> deleteEncounter(String encounterId) async {
    _log(ref.read(catRepositoryProvider).deleteEncounter(encounterId));
  }

  void _log(Future<void> write) => write.catchError((Object e, StackTrace s) {
    developer.log('Write failed: $e', name: 'straycats', stackTrace: s);
  });
}
