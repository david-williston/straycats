import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../localization/app_localizations.dart';
import '../../../localization/life_labels.dart';
import '../domain/cat.dart';
import '../domain/life.dart';
import '../domain/life_event.dart';

/// What the story says about the cat, as a small label derived from its
/// entries: "Missing since `date`" in the accent colour, "Found `date`", or
/// a quiet heart and "Passed away `date`". Nothing at all for a cat with no
/// state. Only a date is ever shown, never a place.
///
/// With [compact] (on the grid tile) a remembered cat shows just
/// "Remembered"; the card adds its dates, "`first met` – `date`", on a line
/// below.
class LifeBadge extends StatelessWidget {
  const LifeBadge({super.key, required this.cat, this.compact = false});

  final Cat cat;
  final bool compact;

  /// "start – end" for a remembered cat. The start is its birth entry when
  /// there is one (as rough as it was given), else the first encounter. Two
  /// different deaths are said, not picked between.
  String? _range(
    AppLocalizations l10n,
    LifeView life,
    LifeEvent death,
    String locale,
  ) {
    final births = life.ofType(LifeEventType.born);
    final birthAgrees = !life.conflicts.any(
      (c) => c.kind == ConflictKind.duplicate && c.type == LifeEventType.born,
    );
    String? start;
    if (births.isNotEmpty && birthAgrees) {
      final b = births.last.on;
      final text = b.format(locale);
      start = b.around ? l10n.lifeRangeAround(text) : text;
    } else if (cat.firstMet != null) {
      start = DateFormat.yMMMd(locale).format(cat.firstMet!);
    }
    final twoDeaths = life.conflicts.any(
      (c) => c.kind == ConflictKind.duplicate && c.type == LifeEventType.died,
    );
    if (twoDeaths) {
      return start == null
          ? l10n.lifeRememberedConflictOnly
          : l10n.lifeRememberedConflict(start);
    }
    final end = death.on.format(locale);
    return start == null ? end : l10n.lifeRememberedDates(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final life = cat.life;
    final event = life.stateEvent;
    if (life.state == LifeState.known || event == null) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toString();
    final sentence = lifeEventLabel(l10n, event, locale, sex: cat.sex);
    final (
      String label,
      IconData icon,
      Color fg,
      Color bg,
      Color? border,
    ) = switch (life.state) {
      LifeState.missing => (
        sentence,
        Icons.search,
        scheme.primary,
        scheme.primary.withValues(alpha: 0.14),
        scheme.primary,
      ),
      LifeState.found => (
        sentence,
        Icons.check_circle_outline,
        scheme.onSecondaryContainer,
        scheme.secondaryContainer,
        null,
      ),
      _ => (
        compact ? l10n.lifeRemembered : sentence,
        Icons.favorite_border,
        scheme.onSurfaceVariant,
        Colors.transparent,
        null,
      ),
    };
    final dates = life.state == LifeState.remembered && !compact
        ? _range(l10n, life, event, locale)
        : null;
    final style = (compact ? textTheme.labelSmall : textTheme.labelLarge)
        ?.copyWith(color: fg, fontWeight: FontWeight.w600);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: border == null
                ? null
                : Border.all(color: border.withValues(alpha: 0.6)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8 : 12,
              vertical: compact ? 2 : 4,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: compact ? 12 : 16, color: fg),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    // The card lets a long sentence wrap; the tile keeps one line.
                    maxLines: compact ? 1 : null,
                    overflow: compact ? TextOverflow.ellipsis : null,
                    style: style,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (dates != null)
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 4),
            child: Text(
              dates,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}
