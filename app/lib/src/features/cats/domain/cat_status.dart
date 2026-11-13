/// Where a cat stands in the eyes of the people who know it. Most cats are
/// [known]: nothing to say, and nothing is stored.
enum CatStatus {
  known,
  missing,
  found,
  remembered;

  /// The stored value; a [known] cat has none.
  String? get stored => this == known ? null : name;

  static CatStatus fromStored(String? value) => switch (value) {
    'missing' => missing,
    'found' => found,
    'remembered' => remembered,
    _ => known,
  };

  /// The longest note the rules allow.
  static const maxNoteLength = 1000;
}
