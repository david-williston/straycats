import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../places/domain/coarse_area.dart';
import '../../places/domain/geohash.dart';
import '../domain/cat.dart';

part 'matching_service.g.dart';

/// Why a cat was ranked where it was, for a short line of text.
enum MatchReason {
  /// Met in the same neighbourhood-sized cell as the new photo.
  sameArea,

  /// Met in a cell next to it.
  nearbyArea,

  /// Nothing about where; it was simply met recently.
  recentlySeen,
}

/// One of the person's cats, scored for a new photo.
@immutable
class CatMatch {
  const CatMatch({
    required this.cat,
    required this.score,
    required this.reason,
  });

  final Cat cat;

  /// 0 to 100. Only meaningful compared with other matches of the same photo.
  final double score;
  final MatchReason reason;
}

/// Works out which of the person's cats a new photo might show.
///
/// Everything happens on the device and uses what is already known: where
/// the new photo was taken (a coarse area, if known), where and when each cat
/// was met, and how often. A cat's score is the sum of
///
/// * area, up to 60: 60 when the cat was met in the same cell as the new
///   photo, 35 when met in one of the 8 cells around it, otherwise 0;
/// * recency, up to 30: halves for every 14 days since the cat was last met;
/// * familiarity, up to 10: 2 for each encounter in that same cell (at most
///   5), only when an area is known.
///
/// Matching never merges or decides anything: it only orders the list and
/// offers a [suggestion], and the person always chooses. Comparing the photo
/// itself with the cats' photos is a v2 step: it will add another term to
/// [rank] using the `photo` that [findMatches] already receives.
class MatchingService {
  static const sameAreaPoints = 60.0;
  static const nearbyAreaPoints = 35.0;
  static const recencyPoints = 30.0;
  static const recencyHalfLife = Duration(days: 14);
  static const familiarityPerEncounter = 2.0;
  static const familiarityMaxEncounters = 5;

  /// A suggestion needs at least this score (so an area match)...
  static const suggestionMinScore = 45.0;

  /// ...and to lead the next cat by at least this much.
  static const suggestionLead = 15.0;

  /// The cats [photo] might show, best match first. [area] is where [photo]
  /// was taken, or null when that is not known (then recency decides).
  List<CatMatch> findMatches(
    File photo,
    List<Cat> cats, {
    CoarseArea? area,
    DateTime? now,
  }) => rank(cats, area: area, now: now);

  /// Scores and orders [cats], best first; ties go to the more recently met.
  List<CatMatch> rank(Iterable<Cat> cats, {CoarseArea? area, DateTime? now}) {
    final at = now ?? DateTime.now();
    final nearby = area == null ? <String>{} : geohashNeighbours(area.geohash);
    final matches = [for (final c in cats) _score(c, area, nearby, at)];
    matches.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      return byScore != 0 ? byScore : b.cat.lastSeen.compareTo(a.cat.lastSeen);
    });
    return matches;
  }

  CatMatch _score(Cat cat, CoarseArea? area, Set<String> nearby, DateTime now) {
    var areaPoints = 0.0;
    var reason = MatchReason.recentlySeen;
    var here = 0;
    if (area != null) {
      for (final e in cat.encounters) {
        final g = e.place?.area.geohash;
        if (g == area.geohash) {
          here++;
        } else if (g != null && nearby.contains(g) && here == 0) {
          areaPoints = math.max(areaPoints, nearbyAreaPoints);
        }
      }
      if (here > 0) {
        areaPoints = sameAreaPoints;
        reason = MatchReason.sameArea;
      } else if (areaPoints > 0) {
        reason = MatchReason.nearbyArea;
      }
    }
    var recency = 0.0;
    if (cat.encounters.isNotEmpty) {
      final age = now.difference(cat.lastSeen).inMinutes.clamp(0, 1 << 30);
      recency =
          recencyPoints *
          math.pow(0.5, age / recencyHalfLife.inMinutes).toDouble();
    }
    final familiarity =
        familiarityPerEncounter * math.min(here, familiarityMaxEncounters);
    return CatMatch(
      cat: cat,
      score: areaPoints + recency + familiarity,
      reason: reason,
    );
  }

  /// The match to offer as "This might be ...", or null when no cat is
  /// clearly ahead of the others. [matches] must be best first.
  CatMatch? suggestion(List<CatMatch> matches) {
    if (matches.isEmpty) return null;
    final top = matches.first;
    if (top.score < suggestionMinScore) return null;
    if (matches.length > 1 && top.score - matches[1].score < suggestionLead) {
      return null;
    }
    return top;
  }
}

@Riverpod(keepAlive: true)
MatchingService matchingService(Ref ref) => MatchingService();
