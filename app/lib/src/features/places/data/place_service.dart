import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/coarse_area.dart';
import '../domain/place.dart';

part 'place_service.g.dart';

/// A position read from the phone. Lives only in memory, for as long as it
/// takes to work out a [Place].
typedef Fix = ({double lat, double lng});

/// The phone's location, and a name for a position. Tests override
/// [placeService].
abstract class PlaceService {
  /// The current position, or null when permission is denied, location is
  /// off, or no fix arrives in time. Asks permission ("while in use") when
  /// it has not been decided. Never throws.
  Future<Fix?> locate();

  /// A neighbourhood name for [fix] (sub-locality, else locality), or null.
  Future<String?> neighbourhoodAt(Fix fix);
}

class DevicePlaceService implements PlaceService {
  static const fixTimeout = Duration(seconds: 5);

  @override
  Future<Fix?> locate() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          // Coarse only: the app never asks for a precise position.
          accuracy: LocationAccuracy.low,
          timeLimit: fixTimeout,
        ),
      ).timeout(fixTimeout);
      return (lat: p.latitude, lng: p.longitude);
    } catch (e) {
      developer.log('No location: $e', name: 'straycats');
      return null;
    }
  }

  @override
  Future<String?> neighbourhoodAt(Fix fix) async {
    try {
      return neighbourhoodFrom(
        await Geocoding()
            .placemarkFromCoordinates(fix.lat, fix.lng)
            .timeout(fixTimeout),
      );
    } catch (e) {
      developer.log('No neighbourhood name: $e', name: 'straycats');
      return null;
    }
  }
}

/// A neighbourhood name from geocoder results: the sub-locality, else the
/// locality. Never the street, name, postal code or house number, however
/// much the geocoder returns. At most [maxNeighbourhoodLength] characters.
String? neighbourhoodFrom(List<Placemark> marks) {
  String? pick(String? Function(Placemark) field) {
    for (final m in marks) {
      final v = field(m)?.trim();
      if (v != null && v.isNotEmpty) return v;
    }
    return null;
  }

  final name = pick((m) => m.subLocality) ?? pick((m) => m.locality);
  if (name == null) return null;
  return name.length > maxNeighbourhoodLength
      ? name.substring(0, maxNeighbourhoodLength)
      : name;
}

@Riverpod(keepAlive: true)
PlaceService placeService(Ref ref) => DevicePlaceService();

/// Works out the [Place] of a photo while the user is still choosing the
/// cat, so saving never waits long. The exact position is read once, turned
/// into a geohash and a name, and dropped: it is never written anywhere.
class PlaceCapture {
  PlaceCapture(this._service);

  final PlaceService _service;
  final _pending = <String, Future<Place?>>{};

  /// Starts for [photo]. Never throws.
  void start(File photo) {
    _pending[photo.path] = _capture().catchError((Object _) => null);
  }

  Future<Place?> _capture() async {
    final fix = await _service.locate();
    if (fix == null) return null;
    // From here on only the coarse cell is kept; `fix` is dropped.
    final area = CoarseArea.fromPosition(fix.lat, fix.lng);
    final name = await _service.neighbourhoodAt(fix);
    return Place(area: area, neighbourhood: name);
  }

  /// The place found for [photo], or null if there is none. Waits at most
  /// [wait] for one still being worked out.
  Future<Place?> take(
    File photo, {
    Duration wait = const Duration(seconds: 6),
  }) async {
    final pending = _pending.remove(photo.path);
    if (pending == null) return null;
    return pending.timeout(wait, onTimeout: () => null);
  }

  /// Forgets [photo] (it was not kept).
  void drop(File photo) => _pending.remove(photo.path);
}

@Riverpod(keepAlive: true)
PlaceCapture placeCapture(Ref ref) =>
    PlaceCapture(ref.watch(placeServiceProvider));
