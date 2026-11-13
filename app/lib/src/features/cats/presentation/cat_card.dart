import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../common_widgets/cat_photo.dart';
import '../../../localization/app_localizations.dart';
import '../../../localization/encounter_labels.dart';
import '../../../theme/app_theme.dart';
import '../../admin/data/other_photo_cache.dart';
import '../data/local_photo_cache.dart';
import '../domain/cat.dart';
import '../domain/encounter.dart';
import 'cat_tile.dart';
import 'cats_controller.dart';
import 'encounter_details_form.dart';

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
    return PopScope(
      onPopInvokedWithResult: (_, _) {
        if (widget.readOnly) return;
        ref
            .read(catsControllerProvider.notifier)
            .rename(widget.cat.id, _name.text.trim());
      },
      child: Scaffold(
        appBar: AppBar(),
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
                        for (var i = 0; i < history.length; i++)
                          Padding(
                            padding: EdgeInsets.only(left: i == 0 ? 0 : 12),
                            child: Builder(
                              builder: (context) {
                                final e = history[i];
                                final selected = i == shown;
                                return SizedBox(
                                  width: 148,
                                  child: Card(
                                    color: selected
                                        ? theme
                                              .colorScheme
                                              .surfaceContainerHighest
                                        : null,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        catRadius,
                                      ),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: SizedBox(
                                                width: double.infinity,
                                                height: 72,
                                                child: CatPhoto(
                                                  _photo(e),
                                                  cacheWidth: 300,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              DateFormat.yMMMd(locale)
                                                  .format(e.time),
                                              style: theme.textTheme.labelLarge
                                                  ?.copyWith(
                                                    color: theme
                                                        .colorScheme
                                                        .onSurface,
                                                  ),
                                            ),
                                            if (e.details
                                                .summary(l10n)
                                                .isNotEmpty)
                                              Text(
                                                e.details.summary(l10n),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                      color: theme
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                              ),
                                            if (e.details.note.isNotEmpty)
                                              Text(
                                                e.details.note,
                                                maxLines: 4,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    theme.textTheme.bodySmall,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
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

enum _EditAction { save, delete }
