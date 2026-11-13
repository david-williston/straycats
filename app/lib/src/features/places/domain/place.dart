import 'package:flutter/foundation.dart';

import 'coarse_area.dart';

/// The longest neighbourhood name kept (the rules allow 80).
const maxNeighbourhoodLength = 80;

/// Where an encounter happened, as much as is ever kept: a [CoarseArea] and,
/// when the phone could name it, a [neighbourhood]. The exact position is
/// never part of this and is never stored.
@immutable
class Place {
  Place({required this.area, String? neighbourhood})
    : neighbourhood = _clean(neighbourhood);

  final CoarseArea area;
  final String? neighbourhood;

  static String? _clean(String? name) {
    final t = name?.trim();
    if (t == null || t.isEmpty) return null;
    return t.length > maxNeighbourhoodLength
        ? t.substring(0, maxNeighbourhoodLength)
        : t;
  }

  @override
  bool operator ==(Object other) =>
      other is Place &&
      other.area == area &&
      other.neighbourhood == neighbourhood;

  @override
  int get hashCode => Object.hash(area, neighbourhood);
}
