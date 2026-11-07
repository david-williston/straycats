import 'dart:io';

import 'cat.dart';

/// The cats [photo] might show, best match first.
///
/// STUB: real image recognition will replace this. For now it ignores the
/// photo and returns every cat, most recently seen first.
List<Cat> findMatches(File photo, List<Cat> cats) => byLastSeen(cats);
