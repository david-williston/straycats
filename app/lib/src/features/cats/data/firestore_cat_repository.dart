import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import 'package:flutter/foundation.dart' show visibleForTesting;

import '../../places/domain/coarse_area.dart';
import '../../places/domain/place.dart';
import '../domain/cat.dart';
import '../domain/cat_status.dart';
import '../domain/encounter.dart';
import '../domain/encounter_details.dart';
import 'cat_repository.dart';
import 'coarse_guard.dart';

/// Cats in `users/{uid}/cats` and their encounters in the flat
/// `users/{uid}/encounters`. The Firestore mapping lives here, not in the
/// domain.
class FirestoreCatRepository implements CatRepository {
  FirestoreCatRepository(this._db, this._uid);

  final FirebaseFirestore _db;
  final String _uid;

  /// Firestore limits a batch to 500 writes.

  CollectionReference<Map<String, dynamic>> get _cats =>
      _db.collection('users').doc(_uid).collection('cats');

  CollectionReference<Map<String, dynamic>> get _encounters =>
      _db.collection('users').doc(_uid).collection('encounters');

  @override
  Stream<List<Cat>> watchCats() =>
      Rx.combineLatest2(_cats.snapshots(), _encounters.snapshots(), _combine);

  /// The same cats once, without a listener. For reading another person's
  /// cats as an admin.
  Future<List<Cat>> fetchCats() async =>
      _combine(await _cats.get(), await _encounters.get());

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
              place: _placeFrom(data),
            ),
          );
    }
    return [
      for (final doc in cats.docs)
        Cat(
          id: doc.id,
          name: doc.data()['name'] as String? ?? '',
          encounters: byCat[doc.id] ?? const [],
          status: CatStatus.fromStored(doc.data()['status'] as String?),
          statusSince: (doc.data()['statusSince'] as Timestamp?)?.toDate(),
          statusNote: doc.data()['statusNote'] as String? ?? '',
        ),
    ];
  }

  static Place? _placeFrom(Map<String, dynamic> data) {
    final area = CoarseArea.tryParse(data['area'] as String?);
    if (area == null) return null;
    return Place(area: area, neighbourhood: data['neighbourhood'] as String?);
  }

  Map<String, dynamic> _catData(Cat cat) => {
    'name': cat.name,
    if (cat.status != CatStatus.known) ...{
      'status': cat.status.name,
      if (cat.statusSince != null)
        'statusSince': Timestamp.fromDate(cat.statusSince!),
      if (cat.statusNote.isNotEmpty) 'statusNote': cat.statusNote,
    },
    'updatedAt': FieldValue.serverTimestamp(),
  };

  Map<String, dynamic> _encounterData(String catId, Encounter e) => {
    'catId': catId,
    'photoId': e.photoId,
    'takenAt': Timestamp.fromDate(e.time),
    ...e.details.toStored(),
    // Only the neighbourhood-level place. No exact position exists to write.
    if (e.place != null) 'area': e.place!.area.geohash,
    if (e.place?.neighbourhood != null) 'neighbourhood': e.place!.neighbourhood,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  /// Every encounter write goes through here, so the coarse-location check
  /// runs on exactly what is sent. A refused write fails the returned future.
  @visibleForTesting
  Future<void> writeEncounterMap(String id, Map<String, dynamic> data) async {
    assertCoarse(data);
    await _encounters.doc(id).set(data);
  }

  @override
  Future<void> addCat(Cat cat) async {
    final batch = _db.batch();
    batch.set(_cats.doc(cat.id), _catData(cat));
    for (final e in cat.encounters) {
      final data = _encounterData(cat.id, e);
      assertCoarse(data);
      batch.set(_encounters.doc(e.id), data);
    }
    await batch.commit();
  }

  @override
  Future<void> addEncounter(String catId, Encounter encounter) =>
      writeEncounterMap(encounter.id, _encounterData(catId, encounter));

  /// Replaces the whole document, so an old `type` field is dropped (its
  /// meaning was mapped into the new fields when read), and a removed place
  /// disappears.
  @override
  Future<void> updateEncounter(String catId, Encounter encounter) =>
      writeEncounterMap(encounter.id, _encounterData(catId, encounter));

  @override
  Future<void> deleteEncounter(String encounterId) =>
      _encounters.doc(encounterId).delete();

  @override
  Future<void> renameCat(String catId, String name) =>
      _cats.doc(catId)
      // Merged, so the cat's status stays.
      .set({
        'name': name,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

  /// An update, so the name and the encounters stay. A known cat has its
  /// status fields deleted. A cat that does not exist makes it fail.
  @override
  Future<void> setStatus(
    String catId,
    CatStatus status, {
    DateTime? since,
    String note = '',
  }) {
    final known = status == CatStatus.known;
    final trimmed = note.trim();
    return _cats.doc(catId).update({
      'status': known ? FieldValue.delete() : status.name,
      'statusSince': known || since == null
          ? FieldValue.delete()
          : Timestamp.fromDate(since),
      'statusNote': known || trimmed.isEmpty ? FieldValue.delete() : trimmed,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

}
