import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../localization/app_localizations.dart';
import '../domain/cat.dart';
import '../domain/cat_status.dart';

/// What a cat's status says, as a small label: "Missing since `date`" in the
/// accent colour, "Found `date`", or a quiet heart and "Remembered". Nothing
/// at all for a known cat. Only a date is ever shown, never a place.
///
/// With [compact] (on the grid tile) a remembered cat shows just the word;
/// the card adds its dates, "`first met` – `date`", on a line below.
class CatStatusBadge extends StatelessWidget {
  const CatStatusBadge({super.key, required this.cat, this.compact = false});

  final Cat cat;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (cat.status == CatStatus.known) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final format = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    final since = cat.statusSince;
    final date = since == null ? '' : format.format(since);
    final (
      String label,
      IconData icon,
      Color fg,
      Color bg,
      Color? border,
    ) = switch (cat.status) {
      CatStatus.missing => (
        since == null ? l10n.statusMarkMissing : l10n.statusMissingSince(date),
        Icons.search,
        scheme.primary,
        scheme.primary.withValues(alpha: 0.14),
        scheme.primary,
      ),
      CatStatus.found => (
        since == null ? l10n.statusMarkFound : l10n.statusFoundOn(date),
        Icons.check_circle_outline,
        scheme.onSecondaryContainer,
        scheme.secondaryContainer,
        null,
      ),
      _ => (
        l10n.statusRemembered,
        Icons.favorite_border,
        scheme.onSurfaceVariant,
        Colors.transparent,
        null,
      ),
    };
    final first = cat.firstMet;
    final dates =
        cat.status == CatStatus.remembered && !compact && since != null
        ? (first == null
              ? date
              : l10n.statusRememberedDates(format.format(first), date))
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
