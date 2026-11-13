import 'package:flutter/foundation.dart';

import 'encounter_details.dart';

/// The answer from "Who is this?": an existing cat ([catId]), or a new cat
/// (null) with an optional [name]; and what was happening, if anything.
@immutable
class Sighting {
  const Sighting({
    this.catId,
    this.name = '',
    this.details = const EncounterDetails(),
  });

  final String? catId;
  final String name;
  final EncounterDetails details;
}
