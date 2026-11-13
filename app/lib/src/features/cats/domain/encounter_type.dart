/// What happened when a cat was seen. Stored as [value]; shown through the l10n labels.
enum EncounterType {
  seen('seen'),
  fed('fed'),
  unwell('unwell'),
  kittens('kittens'),
  earTipped('ear_tipped');

  const EncounterType(this.value);

  final String value;

  /// The type stored as [value], or null if there is none (or it is unknown).
  static EncounterType? parse(String? value) {
    for (final type in values) {
      if (type.value == value) return type;
    }
    return null;
  }
}
