import 'dart:developer' as developer;
import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

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
    final encounter = Encounter(
      id: id,
      photoId: id,
      time: photoTime(photo),
      type: sighting.type,
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

  void _log(Future<void> write) => write.catchError((Object e, StackTrace s) {
    developer.log('Write failed: $e', name: 'straycats', stackTrace: s);
  });
}
