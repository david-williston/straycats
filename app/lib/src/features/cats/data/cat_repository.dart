import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/firebase_providers.dart';
import '../../startup/application/app_startup.dart';
import '../domain/cat.dart';
import '../domain/encounter.dart';
import '../domain/life_event.dart';
import 'firestore_cat_repository.dart';

part 'cat_repository.g.dart';

/// Where the cats live. The app uses [FirestoreCatRepository]; tests override
/// [catRepository] with an in-memory one.
///
/// The write futures complete only when the server acknowledges, so offline
/// they wait. Callers do not await them (the listener in [watchCats] shows
/// local writes at once) and log errors instead.
abstract class CatRepository {
  /// Every cat with its encounters and story entries, again after each change.
  Stream<List<Cat>> watchCats();

  /// A new cat and its encounters, in one batch.
  Future<void> addCat(Cat cat);

  Future<void> addEncounter(String catId, Encounter encounter);

  /// Saves the edited details of an existing encounter of [catId].
  Future<void> updateEncounter(String catId, Encounter encounter);

  /// Removes one encounter. Its cat stays, even with none left.
  Future<void> deleteEncounter(String encounterId);

  Future<void> renameCat(String catId, String name);

  /// Adds an entry to the story of [catId].
  Future<void> addEvent(String catId, LifeEvent event);

  /// Saves the edited date, note or place of an existing entry of [catId].
  /// Its type and creation time stay.
  Future<void> updateEvent(String catId, LifeEvent event);

  /// Removes one entry. Its cat stays.
  Future<void> deleteEvent(String eventId);
}

@Riverpod(keepAlive: true)
CatRepository catRepository(Ref ref) => FirestoreCatRepository(
  ref.watch(firestoreProvider),
  ref.watch(uidProvider),
);
