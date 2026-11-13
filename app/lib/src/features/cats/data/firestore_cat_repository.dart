import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import '../domain/cat.dart';
import '../domain/encounter.dart';
import '../domain/encounter_details.dart';
import 'cat_repository.dart';

/// Cats in `users/{uid}/cats` and their encounters in the flat
/// `users/{uid}/encounters`. The Firestore mapping lives here, not in the
/// domain.
class FirestoreCatRepository implements CatRepository {
  FirestoreCatRepository(this._db, this._uid);

  final FirebaseFirestore _db;
  final String _uid;

  /// Firestore limits a batch to 500 writes.
  static const _batchSize = 500;

  CollectionReference<Map<String, dynamic>> get _cats =>
      _db.collection('users').doc(_uid).collection('cats');

  CollectionReference<Map<String, dynamic>> get _encounters =>
      _db.collection('users').doc(_uid).collection('encounters');

  @override
  Stream<List<Cat>> watchCats() =>
      Rx.combineLatest2(_cats.snapshots(), _encounters.snapshots(), _combine);

  /// Encounters whose cat does not exist, and ones without a photo, are
  /// ignored.
  static List<Cat> _combine(
    QuerySnapshot<Map<String, dynamic>> cats,
    QuerySnapshot<Map<String, dynamic>> encounters,
  ) {
    final byCat = <String, List<Encounter>>{};
    for (final doc in encounters.docs) {
      final data = doc.data();
      final catId = data['catId'] as String?;
      final photoId = data['photoId'] as String?;
      final takenAt = data['takenAt'] as Timestamp?;
      if (catId == null || photoId == null || takenAt == null) continue;
      byCat
          .putIfAbsent(catId, () => [])
          .add(
            Encounter(
              id: doc.id,
              photoId: photoId,
              time: takenAt.toDate(),
              details: EncounterDetails.fromStored(
                activity: data['activity'] as String?,
                conditions: data['conditions'] as List<dynamic>?,
                care: data['care'] as List<dynamic>?,
                note: data['note'] as String?,
                legacyType: data['type'] as String?,
              ),
            ),
          );
    }
    return [
      for (final doc in cats.docs)
        Cat(
          id: doc.id,
          name: doc.data()['name'] as String? ?? '',
          encounters: byCat[doc.id] ?? const [],
        ),
    ];
  }

  Map<String, dynamic> _catData(String name) => {
    'name': name,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  Map<String, dynamic> _encounterData(String catId, Encounter e) => {
    'catId': catId,
    'photoId': e.photoId,
    'takenAt': Timestamp.fromDate(e.time),
    ...e.details.toStored(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  @override
  Future<void> addCat(Cat cat) {
    final batch = _db.batch();
    batch.set(_cats.doc(cat.id), _catData(cat.name));
    for (final e in cat.encounters) {
      batch.set(_encounters.doc(e.id), _encounterData(cat.id, e));
    }
    return batch.commit();
  }

  @override
  Future<void> addEncounter(String catId, Encounter encounter) =>
      _encounters.doc(encounter.id).set(_encounterData(catId, encounter));

  /// Replaces the whole document, so an old `type` field is dropped (its
  /// meaning was mapped into the new fields when read).
  @override
  Future<void> updateEncounter(String catId, Encounter encounter) =>
      _encounters.doc(encounter.id).set(_encounterData(catId, encounter));

  @override
  Future<void> deleteEncounter(String encounterId) =>
      _encounters.doc(encounterId).delete();

  @override
  Future<void> renameCat(String catId, String name) =>
      _cats.doc(catId).set(_catData(name));

  @override
  Future<void> importCats(List<Cat> cats) async {
    final writes =
        <(DocumentReference<Map<String, dynamic>>, Map<String, dynamic>)>[
          for (final cat in cats) ...[
            (_cats.doc(cat.id), _catData(cat.name)),
            for (final e in cat.encounters)
              (_encounters.doc(e.id), _encounterData(cat.id, e)),
          ],
        ];
    for (var i = 0; i < writes.length; i += _batchSize) {
      final batch = _db.batch();
      for (final (ref, data) in writes.skip(i).take(_batchSize)) {
        batch.set(ref, data);
      }
      await batch.commit();
    }
  }
}
