import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../common_widgets/cat_photo.dart';
import '../../../localization/app_localizations.dart';
import '../../../localization/encounter_labels.dart';
import '../data/local_photo_cache.dart';
import '../domain/cat.dart';
import '../domain/encounter.dart';
import 'cats_controller.dart';
import 'encounter_details_form.dart';

/// The cat card: a photo large (pinch to zoom), its name, and every
/// encounter newest first with its details and note (tap one to show its
/// photo and edit or delete it). The trimmed name is
/// saved when the card closes; submitting the field closes it.
class CatCard extends ConsumerStatefulWidget {
  const CatCard({super.key, required this.cat});

  final Cat cat;

  @override
  ConsumerState<CatCard> createState() => _CatCardState();
}

class _CatCardState extends ConsumerState<CatCard> {
  late final _name = TextEditingController(text: widget.cat.name);
  int _shown = 0;

  /// The cat as it is now, so edits and deletes show at once.
  Cat get _cat =>
      ref
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
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      EncounterDetailsForm(
                        initial: e.details,
                        onChanged: (d) => details = d,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
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
      onPopInvokedWithResult: (_, _) => ref
          .read(catsControllerProvider.notifier)
          .rename(widget.cat.id, _name.text.trim()),
      child: Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Expanded(
              child: InteractiveViewer(
                child: CatPhoto(
                  history.isEmpty
                      ? null
                      : ref
                            .watch(photoFileProvider(history[shown].photoId))
                            .value,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: l10n.name,
                  hintText: l10n.giveCatAName,
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (_) => Navigator.of(context).pop(),
              ),
            ),
            SizedBox(
              height: 240,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: history.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final e = history[i];
                  return GestureDetector(
                    onTap: () {
                      setState(() => _shown = i);
                      _edit(cat, e);
                    },
                    child: SizedBox(
                      width: 120,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 120,
                            height: 72,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 2,
                                color: i == shown
                                    ? theme.colorScheme.primary
                                    : Colors.transparent,
                              ),
                            ),
                            child: CatPhoto(
                              ref.watch(photoFileProvider(e.photoId)).value,
                              cacheWidth: 200,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat.yMMMd(locale).format(e.time),
                            style: theme.textTheme.bodySmall,
                          ),
                          if (e.details.summary(l10n).isNotEmpty)
                            Text(
                              e.details.summary(l10n),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _EditAction { save, delete }
