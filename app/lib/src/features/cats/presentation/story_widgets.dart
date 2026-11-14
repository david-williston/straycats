import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../localization/app_localizations.dart';
import '../../../localization/life_labels.dart';
import '../../../theme/app_theme.dart';
import '../data/offer_repository.dart';
import '../domain/cat.dart';
import '../domain/cat_traits.dart';
import '../domain/encounter_details.dart';
import '../domain/life.dart';
import '../domain/life_event.dart';
import '../domain/partial_date.dart';
import 'cats_controller.dart';
import 'life_badge.dart';
import 'story_actions.dart';

/// On the cat card, above the timeline: the badge derived from the story,
/// an "Add to story" button (unless [readOnly], as for an admin), and the
/// quiet notices: conflicts to check, "Seen on 12 Nov. Found?" and the
/// ear-tip offer. Notices that ask something are hidden when read only.
class StorySection extends ConsumerWidget {
  const StorySection({super.key, required this.cat, this.readOnly = false});

  final Cat cat;
  final bool readOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final life = cat.life;
    final hasBadge = life.state != LifeState.known;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The badge has the full width (a long sentence wraps); the button
          // sits on its own row below.
          if (hasBadge)
            Align(
              alignment: Alignment.centerLeft,
              child: LifeBadge(cat: cat),
            ),
          if (!readOnly)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => addToStory(context, ref, cat),
                icon: const Icon(Icons.edit_note),
                label: Text(l10n.storyAdd),
              ),
            ),
          if (life.conflicts.isNotEmpty) ConflictNotice(life: life),
          if (!readOnly && life.nudge != null)
            _NudgeFound(cat: cat, seen: life.nudge!),
          if (!readOnly) _EarTipOffer(cat: cat),
        ],
      ),
    );
  }
}

/// "Possible conflict — check these", and one gentle question per conflict.
/// Nothing is decided and nothing blocks: the entries involved wear a thin
/// outline in the timeline, and each can be edited or deleted.
class ConflictNotice extends StatelessWidget {
  const ConflictNotice({super.key, required this.life});

  final LifeView life;

  String _question(AppLocalizations l10n, LifeConflict c, String locale) =>
      switch (c.kind) {
        ConflictKind.duplicate => l10n.storyConflictDuplicate(
          c.type?.name ?? 'died',
        ),
        ConflictKind.sightingAfterDeath => l10n.storyConflictSighting(
          DateFormat.yMMMd(locale).format(c.sighting!),
        ),
        ConflictKind.foundAfterDeath => l10n.storyConflictFoundAfterDeath,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(catRadius),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.storyConflictTitle,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          for (final c in life.conflicts)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _question(l10n, c, locale),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// After a sighting of a cat recorded as missing: one tap records it as found
/// on the date it was seen. Never automatic.
class _NudgeFound extends ConsumerWidget {
  const _NudgeFound({required this.cat, required this.seen});

  final Cat cat;
  final DateTime seen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        icon: const Icon(Icons.visibility_outlined),
        label: Text(l10n.storyNudgeFound(DateFormat.MMMd(locale).format(seen))),
        onPressed: () {
          ref
              .read(catsControllerProvider.notifier)
              .addEvent(
                cat.id,
                LifeEventType.found,
                PartialDate.fromDate(seen, DatePrecision.day),
              );
          showDialog<void>(
            context: context,
            builder: (_) => FoundCelebration(name: cat.name),
          );
        },
      ),
    );
  }
}

/// "Ear-tipped: add sterilisation to the story?", offered once per cat when
/// an encounter says its ear is tipped and the story has no sterilisation.
/// Adding opens the usual dialog; nothing is created by itself.
class _EarTipOffer extends ConsumerWidget {
  const _EarTipOffer({required this.cat});

  final Cat cat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final answered = ref.watch(earTipAnsweredProvider).value;
    final evidence = cat.encounters.any(
      (e) => e.details.conditions.contains(Condition.earTipped),
    );
    if (answered == null ||
        answered.contains(cat.id) ||
        !evidence ||
        cat.life.ofType(LifeEventType.sterilised).isNotEmpty) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final notifier = ref.read(earTipAnsweredProvider.notifier);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.storyEarTipOffer,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => notifier.answer(cat.id),
            child: Text(l10n.storyEarTipNotNow),
          ),
          FilledButton.tonal(
            onPressed: () {
              notifier.answer(cat.id);
              addToStory(context, ref, cat, type: LifeEventType.sterilised);
            },
            child: Text(l10n.storyEarTipAdd),
          ),
        ],
      ),
    );
  }
}

/// One entry of the story in the card's timeline: a small icon, the sentence
/// with its date as precise as it was given, the note, the neighbourhood of
/// a last-seen place, and "You recorded this". A thin outline marks an entry
/// that is part of a conflict. Tapping offers Edit and Delete, unless
/// [onTap] is null (read only).
class StoryEventCard extends StatelessWidget {
  const StoryEventCard({
    super.key,
    required this.event,
    required this.conflicted,
    this.sex,
    this.onTap,
  });

  final LifeEvent event;

  /// The cat's sex, for "Neutered" or "Spayed" instead of "Sterilised".
  final CatSex? sex;
  final bool conflicted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final scheme = theme.colorScheme;
    final label = lifeEventLabel(l10n, event, locale, sex: sex);
    final hood = event.place?.neighbourhood;
    return SizedBox(
      width: 148,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(catRadius),
          side: BorderSide(
            width: conflicted ? 1.5 : 1,
            color: conflicted ? scheme.outline : scheme.outlineVariant,
          ),
        ),
        child: Semantics(
          button: onTap != null,
          hint: onTap == null ? null : l10n.storyEntryOptions,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    lifeTypeIcon(event.type),
                    size: 22,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(label, style: theme.textTheme.labelLarge),
                  if (hood != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          Icon(
                            Icons.place_outlined,
                            size: 14,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              hood,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (event.note.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        event.note,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      l10n.storyYouRecorded,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
