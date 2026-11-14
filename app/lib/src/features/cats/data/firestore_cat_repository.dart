import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import 'package:flutter/foundation.dart' show visibleForTesting;

import '../../places/domain/coarse_area.dart';
import '../../places/domain/place.dart';
import '../domain/cat.dart';
import '../domain/cat_traits.dart';
import '../domain/encounter.dart';
import '../domain/encounter_details.dart';
import '../domain/life_event.dart';
import '../domain/partial_date.dart';
import 'cat_repository.dart';
import 'coarse_guard.dart';

/// Cats in `users/{uid}/cats`, their encounters in the flat
/// `users/{uid}/encounters` and the entries of their story in the flat
/// `users/{uid}/events`. The Firestore mapping lives here, not in the
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

  CollectionReference<Map<String, dynamic>> get _events =>
      _db.collection('users').doc(_uid).collection('events');

  @override
  Stream<List<Cat>> watchCats() => Rx.combineLatest3(
    _cats.snapshots(),
    _encounters.snapshots(),
    _events.snapshots(),
    _combine,
  );

  /// The same cats once, without a listener. For reading another person's
  /// cats as an admin.
  Future<List<Cat>> fetchCats() async =>
      _combine(await _cats.get(), await _encounters.get(), await _events.get());

  /// Encounters whose cat does not exist, and ones without a photo, are
  /// ignored; so are entries whose cat does not exist or that cannot be read.
  static List<Cat> _combine(
    QuerySnapshot<Map<String, dynamic>> cats,
    QuerySnapshot<Map<String, dynamic>> encounters,
    QuerySnapshot<Map<String, dynamic>> events,
  ) {
    final eventsByCat = <String, List<LifeEvent>>{};
    for (final doc in events.docs) {
      final data = doc.data();
      final catId = data['catId'] as String?;
      final type = LifeEventType.fromStored(data['type'] as String?);
      final on = PartialDate.tryParse(
        data['on'] as String?,
        around: data['around'] == true,
      );
      if (catId == null || type == null || on == null) continue;
      eventsByCat
          .putIfAbsent(catId, () => [])
          .add(
            LifeEvent(
              id: doc.id,
              type: type,
              on: on,
              note: data['note'] as String? ?? '',
              place: _placeFrom(data),
              kind: HealthKind.fromStored(data['kind'] as String?),
              createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
            ),
          );
    }
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
          events: eventsByCat[doc.id] ?? const [],
          sex: CatSex.fromStored(doc.data()['sex']),
          hair: CatHair.fromStored(doc.data()['hair']),
          colour: CatColour.fromStored(doc.data()['colour']),
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
    for (final e in cat.events) {
      final data = _eventData(cat.id, e, creating: true);
      assertCoarseEvent(data);
      batch.set(_events.doc(e.id), data);
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
  Future<void> renameCat(String catId, String name) => _cats.doc(catId).set({
    'name': name,
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

  /// A merge write, so the name and anything else on the document stays; a
  /// cleared look is deleted.
  @override
  Future<void> setCatLooks(
    String catId, {
    CatSex? sex,
    CatHair? hair,
    CatColour? colour,
  }) => _cats.doc(catId).set({
    'sex': sex?.stored ?? FieldValue.delete(),
    'hair': hair?.stored ?? FieldValue.delete(),
    'colour': colour?.stored ?? FieldValue.delete(),
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

  Map<String, dynamic> _eventData(
    String catId,
    LifeEvent e, {
    required bool creating,
  }) => {
    if (creating) 'catId': catId,
    if (creating) 'type': e.type.name,
    'on': e.on.stored,
    // An update leaves out what is not there, which would keep the old value,
    // so these are deleted explicitly when empty.
    if (e.on.around)
      'around': true
    else if (!creating)
      'around': FieldValue.delete(),
    if (e.note.isNotEmpty)
      'note': e.note
    else if (!creating)
      'note': FieldValue.delete(),
    // Only the neighbourhood-level place. No exact position exists to write.
    if (e.place != null)
      'area': e.place!.area.geohash
    else if (!creating)
      'area': FieldValue.delete(),
    if (e.place?.neighbourhood != null)
      'neighbourhood': e.place!.neighbourhood
    else if (!creating)
      'neighbourhood': FieldValue.delete(),
    if (e.kind != null) 'kind': e.kind!.name,
    if (creating) 'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  @override
  Future<void> addEvent(String catId, LifeEvent event) {
    final data = _eventData(catId, event, creating: true);
    assertCoarseEvent(data);
    return _events.doc(event.id).set(data);
  }

  /// An update, so the creation time stays (the rules require it). A cat or
  /// entry that does not exist makes it fail.
  @override
  Future<void> updateEvent(String catId, LifeEvent event) {
    final data = _eventData(catId, event, creating: false);
    assertCoarseEvent(data);
    return _events.doc(event.id).update(data);
  }

  @override
  Future<void> deleteEvent(String eventId) => _events.doc(eventId).delete();
}
