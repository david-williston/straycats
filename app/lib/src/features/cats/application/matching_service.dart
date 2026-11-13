import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/cat.dart';

part 'matching_service.g.dart';

/// Works out which cats a photo might show.
///
/// STUB: real image recognition will replace this. For now it ignores the
/// photo and returns every cat, most recently seen first.
class MatchingService {
  /// The cats [photo] might show, best match first.
  List<Cat> findMatches(File photo, List<Cat> cats) => byLastSeen(cats);
}

@Riverpod(keepAlive: true)
MatchingService matchingService(Ref ref) => MatchingService();
