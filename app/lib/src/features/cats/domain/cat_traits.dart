// What a person may say about a cat's look, all optional: absent means
// "not sure". The stored value is [stored] (snake case), the same words the
// rules allow.

enum CatSex {
  male,
  female;

  String get stored => name;

  static CatSex? fromStored(Object? value) {
    for (final s in values) {
      if (s.stored == value) return s;
    }
    return null;
  }
}

enum CatHair {
  short,
  long;

  String get stored => name;

  static CatHair? fromStored(Object? value) {
    for (final h in values) {
      if (h.stored == value) return h;
    }
    return null;
  }
}

enum CatColour {
  black,
  white,
  grey,
  orange,
  tabby,
  calicoTortie,
  mixed;

  String get stored => switch (this) {
    calicoTortie => 'calico_tortie',
    _ => name,
  };

  static CatColour? fromStored(Object? value) {
    for (final c in values) {
      if (c.stored == value) return c;
    }
    return null;
  }
}
