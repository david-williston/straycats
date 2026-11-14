import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../common_widgets/cat_photo.dart';
import '../../../localization/app_localizations.dart';
import '../../../localization/encounter_labels.dart';
import '../../../theme/app_theme.dart';
import '../../admin/data/other_photo_cache.dart';
import '../../places/domain/coarse_area.dart';
import '../../places/domain/place.dart';
import '../../places/presentation/place_map.dart';
import '../../share/presentation/share_card.dart';
import '../../share/presentation/share_card_page.dart';
import '../data/local_photo_cache.dart';
import '../domain/cat.dart';
import '../domain/encounter.dart';
import 'cat_tile.dart';
import 'cats_controller.dart';
import 'encounter_details_form.dart';
import 'story_widgets.dart';
import '../domain/life_event.dart';
import 'cat_looks.dart';
import 'story_actions.dart';

/// The cat card: a photo large (pinch to zoom), its name, and every
/// encounter newest first with its details and note (tap one to show its
/// photo and edit or delete it). The trimmed name is
/// saved when the card closes; submitting the field closes it.
///
/// With [ownerUid] it is another person's cat, shown to an admin: read only
/// (no rename, no editing or deleting) and with the owner's photos.
class CatCard extends ConsumerStatefulWidget {
  const CatCard({super.key, required this.cat, this.ownerUid});

  final Cat cat;
  final String? ownerUid;

  bool get readOnly => ownerUid != null;

  @override
  ConsumerState<CatCard> createState() => _CatCardState();
}

class _CatCardState extends ConsumerState<CatCard> {
  late final _name = TextEditingController(text: widget.cat.name);
  int _shown = 0;
  bool _showMap = false;

  /// The cat as it is now, so edits and deletes show at once.
  Cat get _cat => widget.readOnly
      ? widget.cat
      : ref
                .watch(catsControllerProvider)
                .value
                ?.where((c) => c.id == widget.cat.id)
                .firstOrNull ??
            widget.cat;

  Future<void> _edit(Cat cat, Encounter e) async {
    final l10n = AppLocalizations.of(context);
    var details = e.details;
    final action = await showModalBottomSheet<_EditAction>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.editEncounter,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (e.place != null)
                        _PlaceSection(
                          place: e.place!,
                          onRemove: () =>
                              Navigator.of(context)
                                  .pop(_EditAction.removePlace),
                        ),
                      EncounterDetailsForm(
                        initial: e.details,
                        onChanged: (d) => details = d,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () =>
                        Navigator.of(context).pop(_EditAction.delete),
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l10n.delete),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () =>
                        Navigator.of(context).pop(_EditAction.save),
                    child: Text(l10n.save),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || action == null) return;
    final controller = ref.read(catsControllerProvider.notifier);
    switch (action) {
      case _EditAction.save:
        if (details != e.details) {
          controller.updateEncounter(cat.id, e.withDetails(details));
        }
      case _EditAction.removePlace:
        // Keeps any other edits made in the sheet.
        controller.removePlace(cat.id, e.withDetails(details));
      case _EditAction.delete:
        final sure = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.deleteEncounterTitle),
            content: Text(l10n.deleteEncounterBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.delete),
              ),
            ],
          ),
        );
        if (sure == true) {
          setState(() => _shown = 0);
          controller.deleteEncounter(e.id);
        }
    }
  }

  /// The photo of [e], from this person's store or the owner's cache.
  File? _photo(Encounter e) => ref
      .watch(
        widget.ownerUid == null
            ? photoFileProvider(e.photoId)
            : ownerPhotoFileProvider(widget.ownerUid!, e.photoId),
      )
      .value;

  /// "Seen around X, Y" over the encounters; tap to show the approximate
  /// areas on a small map.
  Widget _seenAround(
    List<Encounter> history,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final places = [
      for (final e in history)
        if (e.place != null) e.place!,
    ];
    if (places.isEmpty) return const SizedBox.shrink();
    final names = <String>[];
    final areas = <CoarseArea>[];
    for (final p in places) {
      final n = p.neighbourhood;
      if (n != null && !names.contains(n)) names.add(n);
      if (!areas.contains(p.area)) areas.add(p.area);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _showMap = !_showMap),
            child: Row(
              children: [
                Icon(
                  Icons.place_outlined,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    names.isEmpty
                        ? l10n.placeAroundUnnamed
                        : l10n.seenAround(names.join(', ')),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(
                  _showMap ? Icons.expand_less : Icons.expand_more,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
          if (_showMap)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: PlaceMap(areas: areas, height: 160),
            ),
        ],
      ),
    );
  }

  /// The card image's content: the latest photo, the name as typed, the
  /// most recent neighbourhood and its area, and when the cat was first met.
  /// Null when there is no photo here to put on it.
  ShareCardData? _shareData(Cat cat) {
    final history = cat.history;
    if (history.isEmpty) return null;
    final photo = _photo(history.first);
    if (photo == null) return null;
    final place = history
        .map((e) => e.place)
        .where((p) => p?.neighbourhood != null)
        .firstOrNull;
    return ShareCardData(
      name: _name.text,
      photo: photo,
      firstMet: history.last.time,
      neighbourhood: place?.neighbourhood,
      area: place?.area,
    );
  }

  void _share(ShareCardData data) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => ShareCardPage(data: data)));
  }

  /// The entries of the story, newest first: encounters (by [index] into
  /// the cat's history) and the entries of its life, on one timeline.
  List<_StoryItem> _story(Cat cat, List<Encounter> history) {
    final items = [
      for (var i = 0; i < history.length; i++)
        _StoryItem(history[i].time, index: i),
      for (final e in cat.events) _StoryItem(e.on.start, event: e),
    ]..sort((a, b) => b.when.compareTo(a.when));
    return items;
  }

  Widget _storyCard(
    Cat cat,
    _StoryItem item,
    int shown,
    ThemeData theme,
    AppLocalizations l10n,
    String locale,
  ) {
    final ev = item.event;
    if (ev == null) {
      return _encounterCard(cat, item.index!, shown, theme, l10n, locale);
    }
    return StoryEventCard(
      event: ev,
      conflicted: cat.life.inConflict(ev),
      sex: cat.sex,
      onTap: widget.readOnly
          ? null
          : () => editStoryEntry(context, ref, cat, ev),
    );
  }

  /// One encounter of the timeline: its photo, date, place and details.
  Widget _encounterCard(
    Cat cat,
    int i,
    int shown,
    ThemeData theme,
    AppLocalizations l10n,
    String locale,
  ) {
    final e = cat.history[i];
    final selected = i == shown;
    return SizedBox(
      width: 148,
      child: Card(
        color: selected ? theme.colorScheme.surfaceContainerHighest : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(catRadius),
          side: BorderSide(
            width: selected ? 2 : 1,
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
          ),
        ),
        child: InkWell(
          onTap: () {
            setState(() => _shown = i);
            if (!widget.readOnly) _edit(cat, e);
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: double.infinity,
                    height: 72,
                    child: CatPhoto(_photo(e), cacheWidth: 300),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat.yMMMd(locale).format(e.time),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (e.place != null)
                  _PlaceLine(e.place!.neighbourhood ?? l10n.placeAroundUnnamed),
                if (e.details.summary(l10n).isNotEmpty)
                  Text(
                    e.details.summary(l10n),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                if (e.details.note.isNotEmpty)
                  Text(
                    e.details.note,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final cat = _cat;
    final history = cat.history;
    final shown = _shown < history.length ? _shown : 0;
    final story = _story(cat, history);
    return PopScope(
      onPopInvokedWithResult: (_, _) {
        if (widget.readOnly) return;
        ref
            .read(catsControllerProvider.notifier)
            .rename(widget.cat.id, _name.text.trim());
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            // Only your own cats: an admin's read-only view never shares.
            if (!widget.readOnly)
              if (_shareData(cat) case final data?)
                IconButton(
                  icon: const Icon(Icons.ios_share),
                  tooltip: l10n.shareCard,
                  onPressed: () => _share(data),
                ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(catRadius * 1.5),
                  child: ColoredBox(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Hero(
                      tag: CatTile.heroTag(widget.cat, widget.ownerUid),
                      child: InteractiveViewer(
                        child: CatPhoto(
                          history.isEmpty ? null : _photo(history[shown]),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _name,
                readOnly: widget.readOnly,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: l10n.name,
                  hintText: l10n.giveCatAName,
                ),
                onSubmitted: widget.readOnly
                    ? null
                    : (_) => Navigator.of(context).pop(),
              ),
            ),
            CatLooksLine(cat: cat, readOnly: widget.readOnly),
            StorySection(cat: cat, readOnly: widget.readOnly),
            _seenAround(history, l10n, theme),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.4,
              ),
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var n = 0; n < story.length; n++)
                          Padding(
                            padding: EdgeInsets.only(left: n == 0 ? 0 : 12),
                            child: _storyCard(
                              cat,
                              story[n],
                              shown,
                              theme,
                              l10n,
                              locale,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _EditAction { save, removePlace, delete }

/// An entry of the card's timeline: an encounter ([index] into the cat's
/// history) or a [event] of its story, at [when].
class _StoryItem {
  const _StoryItem(this.when, {this.index, this.event});

  final DateTime when;
  final int? index;
  final LifeEvent? event;
}

/// A small place icon and a neighbourhood name, on an encounter's tile.
class _PlaceLine extends StatelessWidget {
  const _PlaceLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          Icons.place_outlined,
          size: 14,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 2),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// In the edit sheet: where the encounter was, read only, as text and an
/// approximate-area map.
class _PlaceSection extends StatelessWidget {
  const _PlaceSection({required this.place, required this.onRemove});

  final Place place;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final name = place.neighbourhood;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.place_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name == null
                      ? l10n.placeAroundUnnamed
                      : l10n.placeAround(name),
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          PlaceMap(areas: [place.area], height: 160),
          const SizedBox(height: 4),
          Text(
            l10n.placePrivacyNote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onRemove,
              icon: const Icon(Icons.location_off_outlined),
              label: Text(l10n.removePlace),
            ),
          ),
        ],
      ),
    );
  }
}
